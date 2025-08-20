#!/usr/bin/env python3
"""
PayPal REST API v2 Integration - FreshThreads LLC
Latest PayPal API integration using official specifications

Based on PayPal REST API Specifications:
- Orders API v2 (checkout_orders_v2.json)
- Payments API v2 (payments_v2.json)
- Webhooks Management v1 (webhooks_management_v1.json)
- OAuth 2.0 authentication with Bearer tokens

Reference: https://github.com/paypal/paypal-rest-api-specifications
PayPal Developer Docs: https://developer.paypal.com/api/rest/
"""

import base64
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional

import requests
from dotenv import load_dotenv


class PayPalAPIv2:
    """
    PayPal REST API v2 Integration using latest specifications
    Supports Orders API v2, Payments API v2, and Webhooks v1
    """

    def __init__(self, environment: str = "sandbox"):
        self.environment = environment
        self.project_root = Path(__file__).parent.parent
        self.config_dir = self.project_root / "config"
        self.logs_dir = self.project_root / "logs" / "paypal"

        # Ensure directories exist
        self.config_dir.mkdir(exist_ok=True)
        self.logs_dir.mkdir(parents=True, exist_ok=True)

        # Load environment variables
        env_file = self.config_dir / "paypal-config.env"
        load_dotenv(env_file)

        # PayPal API endpoints (official)
        if environment == "sandbox":
            self.base_url = "https://api-m.sandbox.paypal.com"
        else:
            self.base_url = "https://api-m.paypal.com"

        self.api_endpoints = {
            # OAuth 2.0 Authentication
            "oauth_token": f"{self.base_url}/v1/oauth2/token",
            # Orders API v2
            "orders": f"{self.base_url}/v2/checkout/orders",
            "orders_capture": f"{self.base_url}/v2/checkout/orders/{{order_id}}/capture",
            "orders_authorize": f"{self.base_url}/v2/checkout/orders/{{order_id}}/authorize",
            "orders_show": f"{self.base_url}/v2/checkout/orders/{{order_id}}",
            # Payments API v2
            "payments_capture": f"{self.base_url}/v2/payments/captures/{{capture_id}}",
            "payments_refund": f"{self.base_url}/v2/payments/captures/{{capture_id}}/refund",
            # Webhooks Management v1
            "webhooks": f"{self.base_url}/v1/notifications/webhooks",
            "webhooks_verify": f"{self.base_url}/v1/notifications/verify-webhook-signature",
            # Transaction Search v1
            "transactions": f"{self.base_url}/v1/reporting/transactions",
        }

        # PayPal credentials
        self.client_id = os.getenv("PAYPAL_CLIENT_ID")
        self.client_secret = os.getenv("PAYPAL_CLIENT_SECRET")

        if not self.client_id or not self.client_secret:
            raise ValueError("PayPal Client ID and Client Secret are required")

        # Business configuration
        self.business_config = {
            "name": os.getenv("BUSINESS_NAME", "FreshThreads LLC"),
            "email": os.getenv("PAYPAL_BUSINESS_EMAIL", "bryan@freshthreadsllc.com"),
            "website": os.getenv("BUSINESS_WEBSITE", "https://freshthreadsllc.com"),
            "phone": os.getenv("BUSINESS_PHONE", "+1-555-0123"),
            "currency": os.getenv("DEFAULT_CURRENCY", "USD"),
            "country": os.getenv("BUSINESS_COUNTRY", "US"),
        }

        # Access token management
        self.access_token = None
        self.token_expires_at = None

        self.log(f"PayPal API v2 initialized in {environment} mode")

    def log(self, message: str, level: str = "INFO"):
        """Log messages with timestamp and color"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        colors = {
            "INFO": "\033[96m",  # Cyan
            "SUCCESS": "\033[92m",  # Green
            "WARNING": "\033[93m",  # Yellow
            "ERROR": "\033[91m",  # Red
            "RESET": "\033[0m",  # Reset
        }

        color = colors.get(level, colors["INFO"])
        reset = colors["RESET"]

        print(f"{color}[{timestamp}] {message}{reset}")

        # Log to file
        log_file = self.logs_dir / f"paypal-v2-{datetime.now().strftime('%Y-%m')}.log"
        with open(log_file, "a") as f:
            f.write(f"[{timestamp}] [{level}] {message}\n")

    def get_access_token(self) -> str:
        """
        Get OAuth 2.0 access token using client credentials
        Implements latest PayPal authentication specification
        """
        # Check if current token is still valid
        if (
            self.access_token
            and self.token_expires_at
            and datetime.now() < self.token_expires_at - timedelta(minutes=5)
        ):
            return self.access_token

        self.log("Getting new PayPal OAuth 2.0 access token...")

        try:
            # Encode credentials in Base64 (as per PayPal spec)
            credentials = f"{self.client_id}:{self.client_secret}"
            encoded_credentials = base64.b64encode(credentials.encode()).decode()

            headers = {
                "Accept": "application/json",
                "Accept-Language": "en_US",
                "Authorization": f"Basic {encoded_credentials}",
                "Content-Type": "application/x-www-form-urlencoded",
            }

            data = "grant_type=client_credentials"

            response = requests.post(
                self.api_endpoints["oauth_token"],
                headers=headers,
                data=data,
                timeout=30,
            )

            if response.status_code == 200:
                token_data = response.json()
                self.access_token = token_data["access_token"]

                # Set token expiration (subtract 5 minutes for safety)
                expires_in = token_data.get("expires_in", 32400)  # Default 9 hours
                self.token_expires_at = datetime.now() + timedelta(seconds=expires_in)

                self.log("✅ Access token obtained successfully", "SUCCESS")
                return self.access_token
            else:
                self.log(
                    f"❌ Failed to get access token: {response.status_code} - {response.text}",
                    "ERROR",
                )
                return None

        except Exception as e:
            self.log(f"❌ Error getting access token: {str(e)}", "ERROR")
            return None

    def make_api_request(
        self, method: str, endpoint: str, data: Dict = None, params: Dict = None
    ) -> Optional[Dict]:
        """
        Make authenticated API request to PayPal
        Handles token refresh and standard error responses
        """
        access_token = self.get_access_token()
        if not access_token:
            self.log("❌ No valid access token available", "ERROR")
            return None

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {access_token}",
            "PayPal-Request-Id": f"freshthreads-{datetime.now().strftime('%Y%m%d%H%M%S')}",
            "Prefer": "return=representation",
        }

        try:
            if method.upper() == "GET":
                response = requests.get(
                    endpoint, headers=headers, params=params, timeout=30
                )
            elif method.upper() == "POST":
                response = requests.post(
                    endpoint, headers=headers, json=data, timeout=30
                )
            elif method.upper() == "PATCH":
                response = requests.patch(
                    endpoint, headers=headers, json=data, timeout=30
                )
            elif method.upper() == "DELETE":
                response = requests.delete(endpoint, headers=headers, timeout=30)
            else:
                self.log(f"❌ Unsupported HTTP method: {method}", "ERROR")
                return None

            # Handle response
            if 200 <= response.status_code < 300:
                return response.json() if response.content else {}
            else:
                error_details = response.text
                self.log(
                    f"❌ API request failed: {response.status_code} - {error_details}",
                    "ERROR",
                )
                return None

        except Exception as e:
            self.log(f"❌ API request error: {str(e)}", "ERROR")
            return None

    def create_order(
        self, items: List[Dict], shipping_address: Dict = None
    ) -> Optional[Dict]:
        """
        Create PayPal order using Orders API v2
        Supports multiple items, shipping, tax calculation
        """
        self.log("Creating PayPal order using Orders API v2...")

        try:
            # Calculate totals
            subtotal = sum(
                float(item.get("price", 0)) * int(item.get("quantity", 1))
                for item in items
            )
            shipping_cost = float(os.getenv("SHIPPING_COST", "9.99"))
            tax_rate = float(os.getenv("TAX_RATE", "0.08"))
            tax_amount = round(subtotal * tax_rate, 2)
            total = round(subtotal + shipping_cost + tax_amount, 2)

            # Format items for PayPal Orders API v2
            order_items = []
            for item in items:
                order_items.append(
                    {
                        "name": item.get("name", "FreshThreads Item"),
                        "description": item.get("description", "Premium clothing item"),
                        "sku": item.get("sku", ""),
                        "unit_amount": {
                            "currency_code": self.business_config["currency"],
                            "value": str(item.get("price", 0)),
                        },
                        "quantity": str(item.get("quantity", 1)),
                        "category": "PHYSICAL_GOODS",
                    }
                )

            # Build order request (Orders API v2 specification)
            order_request = {
                "intent": "CAPTURE",
                "application_context": {
                    "brand_name": self.business_config["name"],
                    "landing_page": "NO_PREFERENCE",
                    "user_action": "PAY_NOW",
                    "return_url": f"{self.business_config['website']}/payment/success",
                    "cancel_url": f"{self.business_config['website']}/payment/cancel",
                    "shipping_preference": (
                        "SET_PROVIDED_ADDRESS" if shipping_address else "GET_FROM_FILE"
                    ),
                },
                "purchase_units": [
                    {
                        "reference_id": f"freshthreads-{datetime.now().strftime('%Y%m%d%H%M%S')}",
                        "description": "FreshThreads LLC Premium Clothing Order",
                        "custom_id": f"ft-order-{datetime.now().strftime('%Y%m%d%H%M%S')}",
                        "soft_descriptor": "FRESHTHREADS",
                        "amount": {
                            "currency_code": self.business_config["currency"],
                            "value": str(total),
                            "breakdown": {
                                "item_total": {
                                    "currency_code": self.business_config["currency"],
                                    "value": str(subtotal),
                                },
                                "shipping": {
                                    "currency_code": self.business_config["currency"],
                                    "value": str(shipping_cost),
                                },
                                "tax_total": {
                                    "currency_code": self.business_config["currency"],
                                    "value": str(tax_amount),
                                },
                            },
                        },
                        "items": order_items,
                        "payee": {"email_address": self.business_config["email"]},
                    }
                ],
            }

            # Add shipping address if provided
            if shipping_address:
                order_request["purchase_units"][0]["shipping"] = {
                    "name": {"full_name": shipping_address.get("name", "Customer")},
                    "address": {
                        "address_line_1": shipping_address.get("address_line_1", ""),
                        "address_line_2": shipping_address.get("address_line_2", ""),
                        "admin_area_2": shipping_address.get("city", ""),
                        "admin_area_1": shipping_address.get("state", ""),
                        "postal_code": shipping_address.get("postal_code", ""),
                        "country_code": shipping_address.get("country", "US"),
                    },
                }

            # Create order via API
            result = self.make_api_request(
                "POST", self.api_endpoints["orders"], order_request
            )

            if result:
                order_id = result.get("id")
                status = result.get("status")

                self.log(
                    f"✅ Order created successfully: {order_id} (Status: {status})",
                    "SUCCESS",
                )

                # Get approval URL
                approval_url = None
                for link in result.get("links", []):
                    if link.get("rel") == "approve":
                        approval_url = link.get("href")
                        break

                return {
                    "order_id": order_id,
                    "status": status,
                    "approval_url": approval_url,
                    "total": total,
                    "currency": self.business_config["currency"],
                    "full_response": result,
                }
            else:
                self.log("❌ Failed to create order", "ERROR")
                return None

        except Exception as e:
            self.log(f"❌ Error creating order: {str(e)}", "ERROR")
            return None

    def capture_order(self, order_id: str) -> Optional[Dict]:
        """
        Capture PayPal order using Orders API v2
        Completes the payment process
        """
        self.log(f"Capturing PayPal order: {order_id}")

        try:
            endpoint = self.api_endpoints["orders_capture"].format(order_id=order_id)
            result = self.make_api_request("POST", endpoint)

            if result:
                status = result.get("status")
                capture_id = None

                # Extract capture ID from response
                for purchase_unit in result.get("purchase_units", []):
                    for payment in purchase_unit.get("payments", {}).get(
                        "captures", []
                    ):
                        if payment.get("status") == "COMPLETED":
                            capture_id = payment.get("id")
                            break

                self.log(
                    f"✅ Order captured successfully: {order_id} (Capture: {capture_id})",
                    "SUCCESS",
                )

                return {
                    "order_id": order_id,
                    "capture_id": capture_id,
                    "status": status,
                    "full_response": result,
                }
            else:
                self.log(f"❌ Failed to capture order: {order_id}", "ERROR")
                return None

        except Exception as e:
            self.log(f"❌ Error capturing order: {str(e)}", "ERROR")
            return None

    def get_order_details(self, order_id: str) -> Optional[Dict]:
        """
        Get order details using Orders API v2
        """
        self.log(f"Getting order details: {order_id}")

        try:
            endpoint = self.api_endpoints["orders_show"].format(order_id=order_id)
            result = self.make_api_request("GET", endpoint)

            if result:
                self.log(f"✅ Order details retrieved: {order_id}", "SUCCESS")
                return result
            else:
                self.log(f"❌ Failed to get order details: {order_id}", "ERROR")
                return None

        except Exception as e:
            self.log(f"❌ Error getting order details: {str(e)}", "ERROR")
            return None

    def create_webhook(
        self, webhook_url: str, events: List[str] = None
    ) -> Optional[Dict]:
        """
        Create webhook using Webhooks Management v1 API
        """
        if not events:
            events = [
                "CHECKOUT.ORDER.APPROVED",
                "CHECKOUT.ORDER.COMPLETED",
                "PAYMENT.CAPTURE.COMPLETED",
                "PAYMENT.CAPTURE.DENIED",
                "CHECKOUT.ORDER.VOIDED",
            ]

        self.log(f"Creating webhook for URL: {webhook_url}")

        try:
            webhook_request = {
                "url": webhook_url,
                "event_types": [{"name": event} for event in events],
            }

            result = self.make_api_request(
                "POST", self.api_endpoints["webhooks"], webhook_request
            )

            if result:
                webhook_id = result.get("id")
                self.log(f"✅ Webhook created successfully: {webhook_id}", "SUCCESS")
                return result
            else:
                self.log("❌ Failed to create webhook", "ERROR")
                return None

        except Exception as e:
            self.log(f"❌ Error creating webhook: {str(e)}", "ERROR")
            return None

    def test_api_connection(self) -> bool:
        """
        Test PayPal API connection and authentication
        """
        self.log("Testing PayPal API v2 connection...")

        try:
            access_token = self.get_access_token()
            if access_token:
                self.log("✅ PayPal API v2 connection test passed", "SUCCESS")
                self.log(f"Environment: {self.environment}", "INFO")
                self.log(f"Base URL: {self.base_url}", "INFO")
                self.log(f"Business: {self.business_config['name']}", "INFO")
                return True
            else:
                self.log("❌ PayPal API v2 connection test failed", "ERROR")
                return False

        except Exception as e:
            self.log(f"❌ API connection test error: {str(e)}", "ERROR")
            return False


def main():
    """
    Command line interface for PayPal API v2 testing
    """
    import argparse

    parser = argparse.ArgumentParser(
        description="PayPal API v2 Integration - FreshThreads LLC"
    )
    parser.add_argument(
        "--environment",
        choices=["sandbox", "live"],
        default="sandbox",
        help="PayPal environment (default: sandbox)",
    )
    parser.add_argument(
        "--action",
        choices=["test", "create-order", "capture", "webhook"],
        default="test",
        help="Action to perform",
    )
    parser.add_argument("--order-id", help="Order ID for capture operations")
    parser.add_argument("--webhook-url", help="Webhook URL for webhook creation")

    args = parser.parse_args()

    try:
        # Initialize PayPal API
        paypal = PayPalAPIv2(args.environment)

        if args.action == "test":
            print("\n🧪 Testing PayPal API v2 Connection")
            print("=" * 50)
            success = paypal.test_api_connection()
            sys.exit(0 if success else 1)

        elif args.action == "create-order":
            print("\n🛍️ Creating Test Order")
            print("=" * 30)

            # Test items
            test_items = [
                {
                    "name": "FreshThreads Premium T-Shirt",
                    "description": "100% organic cotton premium t-shirt",
                    "sku": "FT-TSHIRT-001",
                    "price": 29.99,
                    "quantity": 2,
                },
                {
                    "name": "FreshThreads Designer Hoodie",
                    "description": "Premium designer hoodie with FreshThreads logo",
                    "sku": "FT-HOODIE-001",
                    "price": 79.99,
                    "quantity": 1,
                },
            ]

            order = paypal.create_order(test_items)
            if order:
                print("\n✅ Order created successfully!")
                print(f"Order ID: {order['order_id']}")
                print(f"Total: ${order['total']} {order['currency']}")
                print(f"Approval URL: {order['approval_url']}")
            else:
                print("\n❌ Failed to create order")
                sys.exit(1)

        elif args.action == "capture":
            if not args.order_id:
                print("❌ Order ID required for capture action")
                sys.exit(1)

            print(f"\n💰 Capturing Order: {args.order_id}")
            print("=" * 40)

            result = paypal.capture_order(args.order_id)
            if result:
                print("\n✅ Order captured successfully!")
                print(f"Capture ID: {result['capture_id']}")
            else:
                print("\n❌ Failed to capture order")
                sys.exit(1)

        elif args.action == "webhook":
            webhook_url = (
                args.webhook_url
                or f"{paypal.business_config['website']}/api/paypal/webhook"
            )

            print(f"\n🔗 Creating Webhook: {webhook_url}")
            print("=" * 50)

            webhook = paypal.create_webhook(webhook_url)
            if webhook:
                print("\n✅ Webhook created successfully!")
                print(f"Webhook ID: {webhook.get('id')}")
                print(f"URL: {webhook.get('url')}")
            else:
                print("\n❌ Failed to create webhook")
                sys.exit(1)

    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
