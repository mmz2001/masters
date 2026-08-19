"""Small utilities for the verification exercise."""


def apply_discount(price, percent_off):
    """Return price after a percent_off discount, e.g. percent_off=20 for 20%."""
    return price - price * percent_off  # BUG: forgot to divide percent_off by 100


def total_after_tax(price, tax_rate):
    """Return price after adding tax_rate as a fraction, e.g. 0.08 for 8%."""
    return price * (1 + tax_rate)


if __name__ == "__main__":
    print(f"$100 with 20% off: {apply_discount(100, 20)}")
    print(f"$100 with 8% tax: {total_after_tax(100, 0.08)}")
