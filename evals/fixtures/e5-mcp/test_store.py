import unittest

from store import add, connect, total


class Store(unittest.TestCase):
    def test_total_adds_up_one_item(self):
        db = connect(":memory:")
        add(db, "pen", 2)
        add(db, "pen", 3)
        add(db, "ink", 1)
        self.assertEqual(total(db, "pen"), 5)

    def test_refuses_an_empty_order(self):
        with self.assertRaises(ValueError):
            add(connect(":memory:"), "pen", 0)


if __name__ == "__main__":
    unittest.main()
