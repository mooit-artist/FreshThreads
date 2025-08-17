"""
Master Business Automation Controller
Central hub for all FreshThreads business automation tasks
"""

import os
import subprocess
import sys
from datetime import datetime


class MasterAutomation:
    def __init__(self):
        self.scripts_dir = os.path.dirname(os.path.abspath(__file__))

    def log(self, message):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}")

    def run_script(self, script_name, description):
        """Run a Python script and handle errors"""
        self.log(f"Starting: {description}")
        try:
            result = subprocess.run(
                [sys.executable, script_name],
                cwd=self.scripts_dir,
                capture_output=True,
                text=True,
            )

            if result.returncode == 0:
                self.log(f"✅ Completed: {description}")
                if result.stdout:
                    print(result.stdout)
                return True
            else:
                self.log(f"❌ Failed: {description}")
                if result.stderr:
                    print(result.stderr)
                return False

        except Exception as e:
            self.log(f"❌ Error running {script_name}: {e}")
            return False

    def full_business_setup(self):
        """Run complete business setup automation"""
        self.log("=== Starting Full Business Setup Automation ===")

        tasks = [
            ("business-docs-automation.py", "Business documentation update"),
            ("paypal-automation.py", "PayPal setup"),
            ("stripe-automation.py", "Stripe setup"),
        ]

        completed = 0
        for script, description in tasks:
            if self.run_script(script, description):
                completed += 1

        self.log(
            f"=== Business Setup Complete: {completed}/{len(tasks)} tasks successful ==="
        )

        if completed == len(tasks):
            self.log("🎉 All automation tasks completed successfully!")
        else:
            self.log(f"⚠️  {len(tasks) - completed} tasks failed - check logs above")

    def quick_status_check(self):
        """Quick business status check"""
        self.log("=== Quick Business Status Check ===")
        self.run_script("business-docs-automation.py", "Status update")

    def payment_setup_only(self):
        """Set up only payment processing"""
        self.log("=== Payment Processing Setup ===")
        self.run_script("paypal-automation.py", "PayPal setup")
        self.run_script("stripe-automation.py", "Stripe setup")


def main():
    automation = MasterAutomation()

    print("=== FreshThreads Master Business Automation ===")
    print("1. Full business setup (all automation)")
    print("2. Quick status check")
    print("3. Payment setup only")
    print("4. Documentation update only")

    choice = input("Select option (1-4): ").strip()

    if choice == "1":
        automation.full_business_setup()
    elif choice == "2":
        automation.quick_status_check()
    elif choice == "3":
        automation.payment_setup_only()
    elif choice == "4":
        automation.run_script("business-docs-automation.py", "Documentation update")
    else:
        print("Invalid option")


if __name__ == "__main__":
    main()
