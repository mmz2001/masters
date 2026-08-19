import unittest

from calc import apply_discount, total_after_tax


class TestCalc(unittest.TestCase):
    def test_apply_discount(self):
        # $100 with 20% off should be $80.
        self.assertEqual(apply_discount(100, 20), 80)

    def test_total_after_tax(self):
        self.assertAlmostEqual(total_after_tax(100, 0.08), 108)


if __name__ == "__main__":
    unittest.main()
