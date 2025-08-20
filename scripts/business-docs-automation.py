"""
Business Documentation Automation
Generates and updates business documents, reports, and status files
"""

import json
from datetime import datetime
from pathlib import Path


class BusinessDocsAutomation:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.docs_dir = self.project_root / "project-management"

    def log(self, message):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}")

    def update_business_status(self):
        """Update business setup status based on completed tasks"""
        status = {
            "last_updated": datetime.now().isoformat(),
            "business_setup": {
                "banking": self.check_banking_status(),
                "email": self.check_email_status(),
                "payments": self.check_payment_status(),
                "website": self.check_website_status(),
                "products": self.check_product_status(),
            },
            "next_actions": self.get_next_actions(),
            "completion_percentage": 0,
        }

        # Calculate completion percentage
        completed_items = sum(
            1
            for item in status["business_setup"].values()
            if item["status"] == "complete"
        )
        total_items = len(status["business_setup"])
        status["completion_percentage"] = round(
            (completed_items / total_items) * 100, 1
        )

        # Write status to file
        status_file = self.docs_dir / "CURRENT_STATUS.json"
        with open(status_file, "w") as f:
            json.dump(status, f, indent=2)

        self.log(
            f"✅ Business status updated: {status['completion_percentage']}% complete"
        )
        return status

    def check_banking_status(self):
        """Check if banking is set up"""
        # Check for banking-related environment variables or files
        env_file = self.project_root / ".env"
        if env_file.exists():
            with open(env_file, "r") as f:
                content = f.read()
                if "BANK_" in content or "AMEX_" in content:
                    return {
                        "status": "in_progress",
                        "notes": "Banking application submitted",
                    }

        return {
            "status": "pending",
            "notes": "Waiting for Amex business account approval",
        }

    def check_email_status(self):
        """Check if email system is configured"""
        m365_dir = self.docs_dir / "m365tools"
        if m365_dir.exists() and len(list(m365_dir.glob("*.ps1"))) > 0:
            return {"status": "complete", "notes": "M365 and email aliases configured"}
        return {"status": "pending", "notes": "Email system needs setup"}

    def check_payment_status(self):
        """Check if payment processing is configured"""
        env_file = self.project_root / ".env"
        payment_configured = False

        if env_file.exists():
            with open(env_file, "r") as f:
                content = f.read()
                if any(key in content for key in ["STRIPE_", "PAYPAL_"]):
                    payment_configured = True

        if payment_configured:
            return {
                "status": "in_progress",
                "notes": "Payment keys configured, testing needed",
            }
        return {"status": "pending", "notes": "Payment processing not configured"}

    def check_website_status(self):
        """Check if website is ready"""
        docs_dir = self.project_root / "docs"
        if docs_dir.exists() and (docs_dir / "index.html").exists():
            return {"status": "complete", "notes": "Website deployed and running"}
        return {"status": "pending", "notes": "Website needs completion"}

    def check_product_status(self):
        """Check if products are ready"""
        designs_dir = self.project_root / "docs" / "assets" / "designs"
        if designs_dir.exists() and len(list(designs_dir.glob("*.png"))) > 0:
            return {
                "status": "in_progress",
                "notes": "Some designs available, need automation",
            }
        return {"status": "pending", "notes": "Product designs and automation needed"}

    def get_next_actions(self):
        """Generate list of next actions based on current status"""
        actions = []

        # Check what's pending and suggest actions
        if not self.check_payment_status()["status"] == "complete":
            actions.append("Complete PayPal and Stripe setup")

        if not self.check_product_status()["status"] == "complete":
            actions.append("Set up product design automation")

        if not self.check_banking_status()["status"] == "complete":
            actions.append("Follow up on Amex business account")

        return actions

    def generate_daily_report(self):
        """Generate daily business progress report"""
        status = self.update_business_status()

        report = f"""# FreshThreads Daily Business Report
Date: {datetime.now().strftime('%Y-%m-%d')}
Overall Progress: {status['completion_percentage']}%

## Status Overview
"""

        for category, info in status["business_setup"].items():
            emoji = (
                "✅"
                if info["status"] == "complete"
                else "🔄" if info["status"] == "in_progress" else "⏳"
            )
            report += f"- {emoji} **{category.title()}**: {info['status']} - {info['notes']}\n"

        report += "\n## Next Actions\n"
        for action in status["next_actions"]:
            report += f"- [ ] {action}\n"

        report += "\n## Quick Wins Available\n"
        report += "- Set up PayPal Business account\n"
        report += "- Configure Stripe payment processing\n"
        report += "- Test website payment integration\n"

        # Write report to file
        report_file = (
            self.docs_dir / f"daily-report-{datetime.now().strftime('%Y%m%d')}.md"
        )
        with open(report_file, "w") as f:
            f.write(report)

        self.log(f"✅ Daily report generated: {report_file}")
        return report


def main():
    docs = BusinessDocsAutomation()

    print("=== Business Documentation Automation ===")
    print("1. Update business status")
    print("2. Generate daily report")
    print("3. Full documentation update")

    choice = input("Select option (1-3): ").strip()

    if choice == "1":
        docs.update_business_status()
    elif choice == "2":
        docs.generate_daily_report()
    elif choice == "3":
        docs.update_business_status()
        docs.generate_daily_report()
        print("✅ Full documentation update completed!")
    else:
        print("Invalid option")


if __name__ == "__main__":
    main()
