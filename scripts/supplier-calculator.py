#!/usr/bin/env python3
"""
Fresh Threads LLC - Supplier Cost Calculator
Helps compare profit margins across different suppliers
"""


def calculate_profit_margins():
    """Calculate profit margins for different suppliers"""

    suppliers = {
        "Printful": {
            "base_cost": 11.95,
            "shipping": 4.99,
            "quality_score": 9
        },
        "Printify": {
            "base_cost": 6.99,
            "shipping": 3.99,
            "quality_score": 7
        },
        "Gooten": {
            "base_cost": 8.50,
            "shipping": 4.49,
            "quality_score": 8
        }
    }

    retail_prices = [19.99, 22.99, 24.99]

    print("🧮 Fresh Threads LLC - Supplier Profit Analysis")
    print("=" * 60)

    for retail_price in retail_prices:
        print(f"\n💰 Retail Price: ${retail_price}")
        print("-" * 40)

        for supplier, data in suppliers.items():
            total_cost = data["base_cost"] + data["shipping"]
            profit = retail_price - total_cost
            margin = (profit / retail_price) * 100

            print(
                f"{supplier:10} | Cost: ${total_cost:5.2f} | Profit: ${profit:5.2f} | Margin: {margin:4.1f}% | Quality: {data['quality_score']}/10")

    print("\n🎯 Recommendation:")
    print("• Printful at $24.99: Premium positioning, best quality")
    print("• Printify at $19.99: Competitive pricing, good margins")
    print("• Dual strategy: Both suppliers for different market segments")


if __name__ == "__main__":
    calculate_profit_margins()
