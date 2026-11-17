#!/usr/bin/env python3
"""Run DIY-harness eval cases in Claude Code and grade them (ticket 09; docs/spec/06 sections 4 and 5).

Each trial copies its fixture into a throwaway folder and runs `claude -p` there with only this plugin loaded, in a
throwaway HOME and config folder, over one or more turns of one session. One cost ceiling covers the whole run.
Code graders check what happened, never the wording; a judge call covers what only the wording can show.
Adapted from ayghri/i-have-adhd scripts/run_evals.py and scripts/run_scenario_eval.py (MIT, pin 1ecea19).

Usage: python3 evals/run_evals.py [--case ID]... [--trials N] [--ceiling-usd USD] [--cases FILE]
It needs CLAUDE_CODE_OAUTH_TOKEN in the environment (evals/README.md).
"""
import argparse
import datetime
import fnmatch
import hashlib
import json
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
import uuid
from pathlib import Path

sys.dont_write_bytecode = True  # no bytecode cache in the repo, nor in the developer's home (macOS Python)
sys.path.insert(0, str(Path(__file__).resolve().parent))
import judge  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
MAX_CEILING_USD = 5.0  # Aakash, 2026-11-16 (PLAN.md Q2): at most 5 USD per run
CALL_TIMEOUT_S = 600
TEXT_CAP = 100_000  # a file up to this many bytes is kept as text in a snapshot
TOKEN = "CLAUDE_CODE_OAUTH_TOKEN"
REMOVED = "[CLAUDE_CODE_OAUTH_TOKEN removed]"
# The only variables a trial inherits: the developer's API key, DIY_HARNESS_OFF and CLAUDE_* settings stay out
PASS_ENV = ("PATH", "LANG", "LC_ALL", "LC_CTYPE", "TERM", "TMPDIR", "USER", "LOGNAME", "SHELL", "HTTP_PROXY",
            "HTTPS_PROXY", "NO_PROXY", "http_proxy", "https_proxy", "no_proxy", "NODE_EXTRA_CA_CERTS")
CHECK_FIELDS = {"changed": ("path",), "contains": ("path", "pattern"), "tool": ("name",),
                "writes_only": ("allowed", "before_turn"), "judge": ("condition",)}
FIXTURE_NAME = re.compile(r"^[a-z0-9][a-z0-9-]*$")
EDIT_TOOLS = ("Edit", "Write", "MultiEdit", "NotebookEdit")
# Tools a trial gets that act outside its folder: the cloud, schedules, other sessions on this machine
REACHES_OUT = ("RemoteTrigger", "CronCreate", "CronDelete", "ScheduleWakeup", "Workflow", "SendMessage", "ListAgents")
RESULTS_HEAD = """# Eval results

One line per run of `evals/run_evals.py`. Cost is Claude Code's own estimate (`total_cost_usd`) in US dollars;
on a claude.ai plan it is plan usage, not a bill.

| Date | Claude Code | Model | Cases | Trials | Cost | Outcome |
| --- | --- | --- | --- | --- | --- | --- |
"""


class Stop(Exception):
    """The run cannot go on: the ceiling is reached, or a call's cost is unknown."""


# Cases

def check_errors(check):
    """What is wrong with one check, found before any paid call rather than after."""
    if not isinstance(check, dict) or check.get("check") not in CHECK_FIELDS:
        return [f"unknown check {check!r}"]
    kind = check["check"]
    missing = [field for field in CHECK_FIELDS[kind] if field not in check]
    if missing:
        return [f"a {kind} check needs {', '.join(missing)}"]
    errors, given = [], check.get("input", {})
    if not isinstance(given, dict):
        errors.append("input must map fields to patterns")
        given = {}
    patterns = [check[field] for field in ("pattern", "name") if field in check] + list(given.values())
    if not all(isinstance(text, str) and text.strip()
               for text in patterns + [check[field] for field in ("path", "condition") if field in check]):
        errors.append(f"a {kind} check needs non-empty strings for its paths, patterns and condition")
    else:
        for pattern in patterns:
            try:
                re.compile(pattern)
            except re.error as exc:
                errors.append(f"bad pattern {pattern!r}: {exc}")
    if kind == "writes_only":
        if not isinstance(check["allowed"], list) or not all(isinstance(glob, str) for glob in check["allowed"]):
            errors.append("allowed must be a list of globs")
        if type(check["before_turn"]) is not int or check["before_turn"] < 1:
            errors.append("before_turn must be a whole number, at least 1")
    if not isinstance(check.get("not", False), bool):
        errors.append("not must be true or false")
    return errors


def case_errors(case, fixtures):
    if not isinstance(case, dict):
        return ["not a JSON object"]
    errors = [f"{key} must be a non-empty string" for key in ("id", "fixture", "prompt", "passes")
              if not isinstance(case.get(key), str) or not case[key].strip()]
    errors += [f"{key} must be a list" for key in ("pass_checks", "block_checks", "turns", "allow")
               if not isinstance(case.get(key, []), list)]
    if errors:
        return errors
    if not FIXTURE_NAME.match(case["fixture"]) or not (fixtures / case["fixture"]).is_dir():
        errors.append(f"no fixture folder {fixtures / case['fixture']}")
    if not case.get("pass_checks"):
        errors.append("pass_checks must name at least one check")
    for check in case.get("pass_checks", []) + case.get("block_checks", []):
        errors += check_errors(check)
    for turn in case.get("turns", []):
        if not isinstance(turn, dict) or not isinstance(turn.get("say"), str):
            errors.append("each follow-up turn needs say")
        elif "until" in turn:
            errors += check_errors(turn["until"])
            if isinstance(turn["until"], dict) and turn["until"].get("check") == "judge":
                errors.append("until cannot be a judge check")
            if type(turn.get("max")) is not int or turn["max"] < 1:
                errors.append("a repeated turn needs max, at least 1")
        elif "max" in turn:
            errors.append("max needs until; a turn without until is sent once")
    if not isinstance(case.get("git", True), bool):
        errors.append("git must be true or false")
    for rule in case.get("allow", []):
        # Edit rules are the runner's alone (this copy only); an option here would reach the command line
        if not isinstance(rule, str) or rule.startswith("-") or rule.split("(")[0] in EDIT_TOOLS:
            errors.append(f"allow cannot hold {rule!r}: list tool rules such as Bash(env), never options or edits")
    return errors


def load_cases(path):
    """The cases in a JSON-lines file; their fixtures are in fixtures/ next to it."""
    cases = []
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        try:
            case = json.loads(line)
        except json.JSONDecodeError as exc:
            raise ValueError(f"{path}:{number}: {exc.msg}") from exc
        errors = case_errors(case, path.parent / "fixtures")
        if errors:
            raise ValueError(f"{path}:{number}: " + "; ".join(errors))
        cases.append(case)
    ids = [case["id"] for case in cases]
    repeated = sorted({case_id for case_id in ids if ids.count(case_id) > 1})
    if repeated:
        raise ValueError(f"{path}: repeated case IDs: {', '.join(repeated)}")
    return cases


# Snapshots and graders

def snapshot(folder):
    """{path: {sha256, text}} for every file under folder but .git/. A symlink is recorded, never followed."""
    snap = {}
    for top, dirs, files in os.walk(folder):
        if top == str(folder):
            dirs[:] = [name for name in dirs if name != ".git"]
        for name in files + [d for d in dirs if os.path.islink(os.path.join(top, d))]:
            path = Path(top, name)
            if not path.is_symlink() and not path.is_file():
                continue  # a FIFO or socket: reading it could block
            try:
                data = ("symlink -> " + os.readlink(path)).encode() if path.is_symlink() else path.read_bytes()
            except OSError:
                data = b"(unreadable)"
            text = None
            if len(data) <= TEXT_CAP:
                try:
                    text = data.decode("utf-8")
                except UnicodeDecodeError:
                    pass
            snap[path.relative_to(folder).as_posix()] = {"sha256": hashlib.sha256(data).hexdigest(), "text": text}
    return snap


def changed(before, after):
    return {path for path in before.keys() | after.keys() if before.get(path) != after.get(path)}


def as_text(value):
    return value if isinstance(value, str) else json.dumps(value)


def holds(check, record, ask=None):
    """Whether a check holds for a trial record; "not": true inverts it. ask(condition, record) is the judge.
    Paths are globs, where * also matches /."""
    kind, start, turns = check["check"], record["start"], record["turns"]
    last = turns[-1]["snapshot"] if turns else start
    if kind == "changed":
        result = any(fnmatch.fnmatchcase(path, check["path"]) for path in changed(start, last))
    elif kind == "contains":
        file = last.get(check["path"])
        result = bool(file and file["text"] is not None and re.search(check["pattern"], file["text"], re.M))
    elif kind == "tool":
        result = any(re.fullmatch(check["name"], call["name"] or "") and all(
            re.search(pattern, as_text(call["input"].get(field))) for field, pattern in check.get("input", {}).items())
            for turn in turns for call in turn["tools"])
    elif kind == "writes_only":
        written = set().union(*(changed(start, turn["snapshot"]) for turn in turns[:check["before_turn"] - 1]))
        result = all(any(fnmatch.fnmatchcase(path, glob) for glob in check["allowed"]) for path in written)
    else:
        result = ask(check["condition"], record)
    return result != bool(check.get("not"))


def tool_calls(events):
    """Every tool call in a stream-json transcript, a subagent's included, each once."""
    calls, seen = [], set()
    for event in events:
        message = event.get("message") if event.get("type") == "assistant" else None
        for block in (message.get("content") or []) if isinstance(message, dict) else []:
            if isinstance(block, dict) and block.get("type") == "tool_use" and block.get("id", id(block)) not in seen:
                seen.add(block.get("id", id(block)))
                given = block.get("input")
                calls.append({"name": block.get("name"), "input": given if isinstance(given, dict) else {}})
    return calls


def grade(case, record, ask):
    """Code checks first; the judge's pass checks run only when those leave the trial passing."""
    def named(checks):
        return [json.dumps(check, ensure_ascii=False) for check in checks]
    passes = case.get("pass_checks", [])
    failed = [record["error"]] if record.get("error") else []
    failed += named(c for c in passes if c["check"] != "judge" and not holds(c, record, ask))
    blocked = named(c for c in case.get("block_checks", []) if holds(c, record, ask))
    if not failed and not blocked:
        failed = named(c for c in passes if c["check"] == "judge" and not holds(c, record, ask))
    return {"pass": not failed and not blocked, "failed": failed, "blocked": blocked}


def case_passes(grades, trials):
    """PLAN.md Q2: every trial ran, at least two thirds of them passed, and none hit a blocking behaviour."""
    return (len(grades) == trials and not any(g["blocked"] for g in grades)
            and 3 * sum(g["pass"] for g in grades) >= 2 * trials)


def run_turns(case, record, send):
    """The prompt, then each follow-up: a fixed message once, or repeated until its check holds, at most max
    times. send(prompt) returns the turn's record. A turn that ends in an error ends the trial."""
    plan = [(case["prompt"], None, 1)] + [(t["say"], t.get("until"), t.get("max", 1)) for t in case.get("turns", [])]
    for say, until, most in plan:
        for _ in range(most):
            if until and holds(until, record):
                break
            record["turns"].append(send(say))
            if record["turns"][-1].get("error"):
                return


# Running

def base_env(home):
    env = {key: os.environ[key] for key in PASS_ENV if key in os.environ}
    env["HOME"] = str(home)
    return env


class Run:
    def __init__(self, args, token):
        self.args, self.token = args, token
        self.spent, self.dearest, self.models, self.leaks, self.cut = 0.0, 0.0, set(), [], False
        self.fixtures = args.cases.parent / "fixtures"
        self.results = args.cases.parent / "RESULTS.md"
        self.folder = args.cases.parent / "runs" / datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
        self.folder.mkdir(parents=True)

    def redact(self, text, where="output"):
        if self.token not in text:
            return text
        self.leaks.append(where)
        return text.replace(self.token, REMOVED)

    def save(self, name, data):
        (self.folder / name).write_text(self.redact(json.dumps(data, ensure_ascii=False, indent=1), name), "utf-8")

    def env(self, home):
        env = base_env(home)
        env.update({
            "CLAUDE_CONFIG_DIR": str(home / ".claude"),
            TOKEN: self.token,
            # Strips the token from the agent's Bash and hooks. It strips CLAUDE_CONFIG_DIR from them too, which is
            # why HOME is throwaway as well: a hook that falls back to ~/.claude still lands in this trial's folder.
            "CLAUDE_CODE_SUBPROCESS_ENV_SCRUB": "1",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
        })
        return env

    def ceiling(self):
        return Stop(f"stopped at the cost ceiling (${self.spent:.4f} of ${self.args.ceiling_usd:.2f}; "
                    f"the dearest call so far cost ${self.dearest:.4f})")

    def call(self, prompt, cwd, home, session, prior, extra, on_stdin=False):
        """One claude -p call. prior: the session's total cost so far, or None to start the session. on_stdin sends
        the prompt on stdin, for a long one (Linux caps one argument at 128 KiB)."""
        remaining = math.floor((self.args.ceiling_usd - self.spent) * 1_000_000) / 1_000_000
        # Claude Code checks --max-budget-usd only after each API call (docs/adr/0003 R4), so a call needs room.
        # shortcut: the dearest call so far stands in for the next one; a dearer call can still overshoot by part of
        # itself. Upgrade to a per-case estimate if RESULTS.md shows a run above its ceiling.
        if remaining <= 0 or remaining < self.dearest:
            raise self.ceiling()
        command = ["claude", "-p", "--verbose", "--output-format", "stream-json", "--strict-mcp-config",
                   "--max-budget-usd", f"{remaining:.6f}", "--session-id" if prior is None else "--resume", session, *extra]
        feed = {"input": prompt} if on_stdin else {"stdin": subprocess.DEVNULL}
        try:
            done = subprocess.run(command if on_stdin else [*command, "--", prompt], cwd=cwd, env=self.env(home),
                                  capture_output=True, text=True, timeout=CALL_TIMEOUT_S, **feed)
        except subprocess.TimeoutExpired:
            raise Stop(f"claude ran past {CALL_TIMEOUT_S} s and its cost is unknown, so the run stops") from None
        events = []
        for line in done.stdout.splitlines():
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                event = None
            events.append(event if isinstance(event, dict) else {"type": "unparsed", "text": line})
        result = next((event for event in reversed(events) if event.get("type") == "result"), {})
        total = result.get("total_cost_usd")
        if isinstance(total, bool) or not isinstance(total, (int, float)) or not math.isfinite(total) or total < 0:
            detail = self.redact(done.stderr.strip()[-500:] or done.stdout.strip()[-500:])
            raise Stop(f"claude reported no cost (exit {done.returncode}), so the run stops: {detail}")
        # After --resume, total_cost_usd covers the whole session, while --max-budget-usd holds this call alone
        # (docs/adr/0003 R4). A total below the prior one cannot be split, so all of it counts.
        cost = total - prior if prior is not None and total >= prior else total
        self.spent += cost
        self.dearest = max(self.dearest, cost)
        self.models.update(e["model"] for e in events if e.get("subtype") == "init" and isinstance(e.get("model"), str))
        turn = {"prompt": prompt, "result": as_text(result.get("result", "")), "tools": tool_calls(events),
                "cost_usd": cost, "session_cost_usd": total, "events": events}
        if result.get("is_error") or done.returncode:
            turn["error"] = f"claude ended with {result.get('subtype')} (exit {done.returncode})"
        self.cut = self.cut or "budget" in str(result.get("subtype"))  # --max-budget-usd cut this call short
        return turn

    def git(self, work, home):
        env = {**base_env(home), "GIT_CONFIG_NOSYSTEM": "1"}
        for args in (["init", "-q", "-b", "main"], ["add", "-A"],
                     ["-c", "user.name=diy-eval", "-c", "user.email=diy-eval@localhost", "-c", "commit.gpgsign=false",
                      "commit", "-q", "--allow-empty", "-m", "fixture"]):
            subprocess.run(["git", *args], cwd=work, env=env, check=True, capture_output=True)

    def ask(self, condition, record):
        folder = Path(tempfile.mkdtemp(prefix="diy-eval-judge-"))
        try:
            (folder / "home" / ".claude").mkdir(parents=True)
            (folder / "work").mkdir()
            asked = judge.prompt(condition, [(t["prompt"], t["result"]) for t in record["turns"]])
            turn = self.call(self.redact(asked, "a judge prompt"), folder / "work", folder / "home",
                             str(uuid.uuid4()), None, ["--setting-sources", "", "--tools", ""], on_stdin=True)
        finally:
            shutil.rmtree(folder, ignore_errors=True)
        try:
            passed, reason = judge.verdict(turn["result"])
        except ValueError as exc:
            passed, reason = False, f"unusable judge reply: {exc}"
        record.setdefault("judged", []).append({"condition": condition, "pass": passed, "reason": reason})
        return passed

    def trial(self, case, number):
        base = Path(tempfile.mkdtemp(prefix="diy-eval-")).resolve()  # the real path (/private/var on macOS) the allow rule names
        work, home = base / "work", base / "home"
        record = {"case": case["id"], "trial": number, "turns": []}
        try:
            shutil.copytree(self.fixtures / case["fixture"], work, symlinks=True)
            (home / ".claude").mkdir(parents=True)
            if case.get("git", True):
                self.git(work, home)
            record["start"] = snapshot(work)
            session = str(uuid.uuid4())
            # Edits in this copy only, through an allow rule: under the scrub Claude Code ignores --permission-mode
            # acceptEdits (docs/adr/0003 R5). Anything else that would ask is refused. shortcut: the copy's .claude/
            # is read-only, because the next --resume would load settings the agent wrote there; lift it for a case
            # that must build settings (an M3 guard) once a probe shows how Claude Code guards them.
            extra = ["--plugin-dir", str(ROOT), "--setting-sources", "project,local", "--permission-prompts", "none",
                     "--allowedTools", f"Edit(/{work}/**)", *case.get("allow", []),
                     "--disallowedTools", *REACHES_OUT, f"Edit(/{work}/.claude/**)"]

            def send(prompt):
                prior = record["turns"][-1]["session_cost_usd"] if record["turns"] else None
                turn = self.call(prompt, work, home, session, prior, extra)
                turn["snapshot"] = snapshot(work)
                # The deny rule above is Claude Code's; this check is ours, in any letter case (macOS disks ignore it)
                for path in sorted(changed(record["start"], turn["snapshot"])):
                    if path.split("/")[0].lower() == ".claude":
                        turn["error"] = f"the agent wrote {path}; the next --resume would load it, so the trial stops"
                return turn

            run_turns(case, record, send)
            record["error"] = next((t["error"] for t in record["turns"] if t.get("error")), None)
            record["grade"] = grade(case, record, self.ask)
            record["grade"]["judged"] = record.get("judged", [])
            if self.cut:
                raise self.ceiling()  # a trial cut short does not count
            return record["grade"]
        finally:
            self.save(f"{case['id']}-trial{number}.json", record)
            # Claude Code's own session files live in the throwaway config: check them before they go
            if any(self.holds_token(Path(top, name)) for top, _, names in os.walk(base) for name in names):
                self.leaks.append(f"the throwaway folder of {case['id']} trial {number}")
            shutil.rmtree(base, ignore_errors=True)

    def holds_token(self, path):
        try:
            return path.is_file() and not path.is_symlink() and self.token.encode() in path.read_bytes()
        except OSError:
            return False

    def finish(self, version, chosen, verdicts, stopped):
        outcome = f"{sum(verdicts)} of {len(chosen)} cases passed"
        if stopped:
            outcome += "; " + stopped.splitlines()[0].replace("|", "/")[:160]
        models = ", ".join(sorted(self.models)) or "unknown"
        line = (f"| {datetime.date.today()} | {version} | {models} | {', '.join(c['id'] for c in chosen)} | "
                f"{self.args.trials} | ${self.spent:.4f} | {outcome} |\n")
        head = "" if self.results.exists() else RESULTS_HEAD
        with self.results.open("a", encoding="utf-8") as results:
            results.write(head + self.redact(line, str(self.results)))
        # The last guard: no saved file may hold the token, whatever wrote it
        for path in [*self.folder.rglob("*"), self.results]:
            if path.is_file():
                text = path.read_text(encoding="utf-8", errors="replace")
                if self.token in text:
                    path.write_text(self.redact(text, str(path)), "utf-8")


def main(argv=None):
    parser = argparse.ArgumentParser(description="Run DIY-harness eval cases in Claude Code (evals/README.md).")
    parser.add_argument("--cases", type=Path, default=ROOT / "evals" / "cases.jsonl")
    parser.add_argument("--case", action="append", help="run only this case ID; repeatable")
    parser.add_argument("--trials", type=int, default=3)
    parser.add_argument("--ceiling-usd", type=float, default=MAX_CEILING_USD)
    args = parser.parse_args(argv)
    try:
        cases = load_cases(args.cases)
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    unknown = sorted(set(args.case or []) - {case["id"] for case in cases})
    if unknown:
        parser.error(f"no such case: {', '.join(unknown)}")
    chosen = [case for case in cases if not args.case or case["id"] in args.case]
    if not chosen:
        parser.error("no cases to run")
    if not 0 < args.ceiling_usd <= MAX_CEILING_USD:
        parser.error(f"--ceiling-usd must be above 0 and at most {MAX_CEILING_USD:g} (PLAN.md Q2)")
    if args.trials < 1:
        parser.error("--trials must be at least 1")
    token = os.environ.get(TOKEN, "")
    if not token:
        parser.error(f"{TOKEN} is not set: run `claude setup-token` once in your own terminal and export the "
                     "token (evals/README.md)")

    run = Run(args, token)
    home = tempfile.mkdtemp(prefix="diy-eval-version-")  # even this call stays out of the developer's home
    try:
        version = subprocess.run(["claude", "--version"], env=base_env(home), capture_output=True,
                                 text=True).stdout.strip() or "unknown"
    finally:
        shutil.rmtree(home, ignore_errors=True)
    stopped, verdicts = None, []
    try:
        for case in chosen:
            grades = []
            try:
                for number in range(1, args.trials + 1):
                    grades.append(run.trial(case, number))
            except Stop as exc:
                stopped = str(exc)
            verdicts.append(case_passes(grades, args.trials))
            print(f"{'PASS' if verdicts[-1] else 'FAIL'} {case['id']}: {sum(g['pass'] for g in grades)} of "
                  f"{args.trials} trials passed")
            for number, g in enumerate(grades, 1):
                for item in g["failed"]:
                    print(f"  trial {number} failed: {run.redact(item)}")
                for item in g["blocked"]:
                    print(f"  trial {number} blocked: {run.redact(item)}")
                for judged in g["judged"]:
                    print(f"  trial {number} judge: {'pass' if judged['pass'] else 'fail'}: "
                          f"{run.redact(judged['reason'])}")
            if stopped:
                print(stopped)
                break
    except BaseException as exc:  # Ctrl-C or a crash: RESULTS.md must not read like a finished run
        stopped = stopped or f"interrupted by {type(exc).__name__}; a call in flight is not counted"
        raise
    finally:
        run.finish(version, chosen, verdicts, stopped)  # a crash still records what the run cost
    print(f"Cost: ${run.spent:.4f} of the ${args.ceiling_usd:.2f} ceiling. Transcripts: {run.folder}")
    if run.leaks:
        print(f"TOKEN LEAK: the sign-in token reached {', '.join(sorted(set(run.leaks)))}. It was removed before "
              "saving, but treat it as exposed: run `claude setup-token` again for a new one.", file=sys.stderr)
    return 0 if all(verdicts) and len(verdicts) == len(chosen) and not stopped and not run.leaks else 1


if __name__ == "__main__":
    raise SystemExit(main())
