import unittest

from clean import clean


class Clean(unittest.TestCase):
    def test_drops_blank_rows_and_trims(self):
        self.assertEqual(clean([[" a ", "b"], ["", " "]]), [["a", "b"]])


if __name__ == "__main__":
    unittest.main()
