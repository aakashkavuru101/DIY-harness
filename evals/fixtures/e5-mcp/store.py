"""Keep orders in a local SQLite database (orders.db)."""
import sqlite3


def connect(path="orders.db"):
    db = sqlite3.connect(path)
    db.execute("CREATE TABLE IF NOT EXISTS orders (id INTEGER PRIMARY KEY, item TEXT NOT NULL, qty INTEGER NOT NULL)")
    return db


def add(db, item, qty):
    if qty < 1:
        raise ValueError("qty must be at least 1")
    db.execute("INSERT INTO orders (item, qty) VALUES (?, ?)", (item, qty))
    db.commit()


def total(db, item):
    return db.execute("SELECT COALESCE(SUM(qty), 0) FROM orders WHERE item = ?", (item,)).fetchone()[0]
