#!/usr/bin/env python3
"""
PayPal Express Checkout Integration - FreshThreads LLC
Handles PayPal payment processing for e-commerce orders
"""

import os
from datetime import datetime
from pathlib import Path

import paypalrestsdk
from dotenv import load_dotenv

# Load environment variables
env_file = Path(__file__).parent.parent / "config" / "paypal-config.env"
load_dotenv(env_file)


class FreshThreadsPayPalCheckout:
    def __init__(self):
        self.environment = os.getenv("PAYPAL_ENVIRONMENT", "sandbox")

        # Configure PayPal SDK
        paypalrestsdk.configure(
            {
                "mode": self.environment,
                "client_id": os.getenv("PAYPAL_CLIENT_ID"),
                "client_secret": os.getenv("PAYPAL_CLIENT_SECRET"),
            }
        )

        self.business_info = {
            "name": os.getenv("BUSINESS_NAME", "FreshThreads LLC"),
            "website": os.getenv("BUSINESS_WEBSITE"),
            "email": os.getenv("PAYPAL_BUSINESS_EMAIL"),
            "phone": os.getenv("BUSINESS_PHONE"),
        }

        print(f"🛍️ FreshThreads PayPal Checkout initialized in {self.environment} mode")

    def create_payment(
        self, items: list, description: str = "FreshThreads Purchase"
    ) -> dict:
        """Create a PayPal payment for clothing items"""

        try:
            # Format items for PayPal
            paypal_items = []
            for item in items:
                paypal_items.append(
                    {
                        "name": item.get("name", "FreshThreads Item"),
                        "sku": item.get("sku", ""),
                        "price": str(item.get("price", 0)),
                        "currency": "USD",
                        "quantity": item.get("quantity", 1),
                        "description": item.get("description", ""),
                    }
                )

            # Calculate amounts
            subtotal = sum(
                float(item.get("price", 0)) * item.get("quantity", 1) for item in items
            )
            shipping = float(os.getenv("SHIPPING_COST", 9.99))
            tax_rate = float(os.getenv("TAX_RATE", 0.08))
            tax = round(subtotal * tax_rate, 2)
            total = round(subtotal + shipping + tax, 2)

            payment = paypalrestsdk.Payment(
                {
                    "intent": "sale",
                    "payer": {"payment_method": "paypal"},
                    "redirect_urls": {
                        "return_url": os.getenv("PAYPAL_SUCCESS_URL"),
                        "cancel_url": os.getenv("PAYPAL_CANCEL_URL"),
                    },
                    "transactions": [
                        {
                            "item_list": {"items": paypal_items},
                            "amount": {
                                "total": str(total),
                                "currency": "USD",
                                "details": {
                                    "subtotal": str(subtotal),
                                    "tax": str(tax),
                                    "shipping": str(shipping),
                                },
                            },
                            "description": description,
                            "invoice_number": f"FT-{datetime.now().strftime('%Y%m%d%H%M%S')}",
                            "soft_descriptor": "FRESHTHREADS",
                        }
                    ],
                }
            )

            if payment.create():
                print(f"✅ Payment created successfully: {payment.id}")

                # Get approval URL
                for link in payment.links:
                    if link.rel == "approval_url":
                        approval_url = str(link.href)
                        print(f"🔗 Approval URL: {approval_url}")
                        return {
                            "success": True,
                            "payment_id": payment.id,
                            "approval_url": approval_url,
                            "total": total,
                        }
            else:
                print(f"❌ Payment creation failed: {payment.error}")
                return {"success": False, "error": payment.error}

        except Exception as e:
            print(f"❌ Error creating payment: {str(e)}")
            return {"success": False, "error": str(e)}

    def execute_payment(self, payment_id: str, payer_id: str) -> dict:
        """Execute approved PayPal payment"""

        try:
            payment = paypalrestsdk.Payment.find(payment_id)

            if payment.execute({"payer_id": payer_id}):
                print(f"✅ Payment executed successfully: {payment_id}")

                # Extract transaction details
                transaction = payment.transactions[0]
                return {
                    "success": True,
                    "payment_id": payment_id,
                    "transaction_id": transaction.related_resources[0].sale.id,
                    "amount": transaction.amount.total,
                    "currency": transaction.amount.currency,
                    "status": "completed",
                }
            else:
                print(f"❌ Payment execution failed: {payment.error}")
                return {"success": False, "error": payment.error}

        except Exception as e:
            print(f"❌ Error executing payment: {str(e)}")
            return {"success": False, "error": str(e)}


# Example usage and testing
if __name__ == "__main__":
    print("🛍️ FreshThreads PayPal Express Checkout Test")

    checkout = FreshThreadsPayPalCheckout()

    # Test payment creation
    test_items = [
        {
            "name": "Premium Cotton T-Shirt",
            "sku": "FT-TEE-001",
            "price": 29.99,
            "quantity": 2,
            "description": "100% organic cotton, premium quality",
        },
        {
            "name": "Designer Jeans",
            "sku": "FT-JEAN-002",
            "price": 89.99,
            "quantity": 1,
            "description": "Slim fit, premium denim",
        },
    ]

    print("\n📦 Creating test payment...")
    result = checkout.create_payment(test_items, description="FreshThreads Test Order")

    if result["success"]:
        print(f"💳 Payment ID: {result['payment_id']}")
        print(f"💰 Total: ${result['total']}")
        print(f"🔗 Approval URL: {result['approval_url']}")
        print("\n🎯 Next: Customer approves payment, then call execute_payment()")
    else:
        print(f"❌ Payment failed: {result['error']}")
