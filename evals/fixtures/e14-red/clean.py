"""Drop blank rows from a CSV file and trim every cell."""
import csv
import sys


def clean(rows):
    return [[cell.strip() for cell in row] for row in rows]


if __name__ == "__main__":
    csv.writer(sys.stdout).writerows(clean(csv.reader(sys.stdin)))
