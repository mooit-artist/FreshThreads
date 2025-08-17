#!/usr/bin/env python3
"""
Office 365 Email Handler for FreshThreads Contact Form
Integrates contact form submissions with Office 365 using Microsoft Graph API
"""

import os
import sys
import json
import smtplib
import logging
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from typing import Dict, Any, Optional

import requests
from msal import ConfidentialClientApplication
from dotenv import load_dotenv

# Load environment variables from config file
config_path = os.path.join(os.path.dirname(
    os.path.dirname(__file__)), 'config', 'o365-config.env')
load_dotenv(config_path)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(
            '/Users/bryanjorgensen/Documents/GitHub/CodeProjects/WEB/FreshThreads/logs/o365_email.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class O365EmailHandler:
    """Handle email operations using Office 365 / Microsoft Graph API"""

    def __init__(self):
        """Initialize O365 email handler with environment variables"""
        self.client_id = os.getenv('O365_CLIENT_ID')
        self.client_secret = os.getenv('O365_CLIENT_SECRET')
        self.tenant_id = os.getenv('O365_TENANT_ID')
        self.from_email = os.getenv(
            'O365_FROM_EMAIL', 'hello@freshthreadsllc.com')
        self.to_email = os.getenv('O365_TO_EMAIL', 'hello@freshthreadsllc.com')

        # Alternative SMTP configuration for fallback
        self.smtp_server = os.getenv(
            'O365_SMTP_SERVER', 'smtp-mail.outlook.com')
        self.smtp_port = int(os.getenv('O365_SMTP_PORT', '587'))
        self.smtp_username = os.getenv('O365_SMTP_USERNAME')
        self.smtp_password = os.getenv('O365_SMTP_PASSWORD')

        self.authority = f"https://login.microsoftonline.com/{self.tenant_id}"
        self.scope = ["https://graph.microsoft.com/.default"]

        # Initialize MSAL app
        self.app = None
        if self.client_id and self.client_secret and self.tenant_id:
            self.app = ConfidentialClientApplication(
                client_id=self.client_id,
                client_credential=self.client_secret,
                authority=self.authority
            )

    def get_access_token(self) -> Optional[str]:
        """Get access token for Microsoft Graph API"""
        if not self.app:
            logger.error(
                "MSAL app not initialized. Check your O365 credentials.")
            return None

        try:
            result = self.app.acquire_token_silent(self.scope, account=None)

            if not result:
                result = self.app.acquire_token_for_client(scopes=self.scope)

            if "access_token" in result:
                logger.info("Successfully acquired access token")
                return result["access_token"]
            else:
                logger.error(
                    f"Failed to acquire token: {result.get('error_description', 'Unknown error')}")
                return None

        except Exception as e:
            logger.error(f"Error acquiring access token: {str(e)}")
            return None

    def send_email_graph_api(self, subject: str, body: str, form_data: Dict[str, Any]) -> bool:
        """Send email using Microsoft Graph API"""
        access_token = self.get_access_token()
        if not access_token:
            logger.error("No access token available")
            return False

        # Format email body with form data
        formatted_body = self._format_email_body(form_data, body)

        message = {
            "subject": subject,
            "body": {
                "contentType": "HTML",
                "content": formatted_body
            },
            "toRecipients": [
                {
                    "emailAddress": {
                        "address": self.to_email
                    }
                }
            ],
            "from": {
                "emailAddress": {
                    "address": self.from_email
                }
            }
        }

        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }

        try:
            response = requests.post(
                f"https://graph.microsoft.com/v1.0/users/{self.from_email}/sendMail",
                headers=headers,
                json={"message": message}
            )

            if response.status_code == 202:
                logger.info(
                    f"Email sent successfully via Graph API: {subject}")
                return True
            else:
                logger.error(
                    f"Failed to send email via Graph API: {response.status_code} - {response.text}")
                return False

        except Exception as e:
            logger.error(f"Error sending email via Graph API: {str(e)}")
            return False

    def send_email_smtp(self, subject: str, body: str, form_data: Dict[str, Any]) -> bool:
        """Send email using SMTP (fallback method)"""
        if not self.smtp_username or not self.smtp_password:
            logger.error("SMTP credentials not configured")
            return False

        try:
            # Create message
            msg = MIMEMultipart('alternative')
            msg['Subject'] = subject
            msg['From'] = self.from_email
            msg['To'] = self.to_email
            msg['Reply-To'] = form_data.get('email', self.from_email)

            # Format email body
            formatted_body = self._format_email_body(form_data, body)

            # Create HTML part
            html_part = MIMEText(formatted_body, 'html')
            msg.attach(html_part)

            # Create plain text version
            plain_text = self._html_to_text(formatted_body)
            text_part = MIMEText(plain_text, 'plain')
            msg.attach(text_part)

            # Send email
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                server.starttls()
                server.login(self.smtp_username, self.smtp_password)
                server.send_message(msg)

            logger.info(f"Email sent successfully via SMTP: {subject}")
            return True

        except Exception as e:
            logger.error(f"Error sending email via SMTP: {str(e)}")
            return False

    def _format_email_body(self, form_data: Dict[str, Any], original_body: str = "") -> str:
        """Format email body with form data"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        html_body = f"""
        <html>
        <head>
            <style>
                body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }}
                .header {{ background-color: #f8f9fa; padding: 20px; margin-bottom: 20px; }}
                .field {{ margin-bottom: 15px; }}
                .label {{ font-weight: bold; color: #333; }}
                .value {{ margin-top: 5px; padding: 10px; background-color: #f8f9fa; border-radius: 4px; }}
                .footer {{ margin-top: 30px; padding-top: 20px; border-top: 1px solid #dee2e6; font-size: 12px; color: #6c757d; }}
            </style>
        </head>
        <body>
            <div class="header">
                <h2 style="margin: 0; color: #007bff;">New Contact Form Submission - FreshThreads LLC</h2>
                <p style="margin: 5px 0 0 0; color: #6c757d;">Received: {timestamp}</p>
            </div>

            <div class="field">
                <div class="label">Name:</div>
                <div class="value">{form_data.get('name', 'Not provided')}</div>
            </div>

            <div class="field">
                <div class="label">Email:</div>
                <div class="value"><a href="mailto:{form_data.get('email', '')}">{form_data.get('email', 'Not provided')}</a></div>
            </div>

            <div class="field">
                <div class="label">Subject:</div>
                <div class="value">{form_data.get('subject', 'Not provided')}</div>
            </div>

            <div class="field">
                <div class="label">Message:</div>
                <div class="value">{form_data.get('message', 'Not provided')}</div>
            </div>

            <div class="footer">
                <p>This email was automatically generated from the FreshThreads website contact form.</p>
                <p>Reply directly to this email to respond to the customer.</p>
            </div>
        </body>
        </html>
        """
        return html_body

    def _html_to_text(self, html_content: str) -> str:
        """Convert HTML to plain text"""
        # Simple HTML to text conversion
        import re
        text = re.sub('<[^<]+?>', '', html_content)
        text = re.sub(r'\s+', ' ', text)
        return text.strip()

    def send_contact_form_email(self, form_data: Dict[str, Any]) -> Dict[str, Any]:
        """Main method to send contact form email"""
        try:
            # Validate required fields
            required_fields = ['name', 'email', 'subject', 'message']
            missing_fields = [
                field for field in required_fields if not form_data.get(field)]

            if missing_fields:
                return {
                    'success': False,
                    'error': f"Missing required fields: {', '.join(missing_fields)}"
                }

            # Create subject line
            subject = f"[FreshThreads Contact] {form_data['subject']} - {form_data['name']}"

            # Try Graph API first, then fall back to SMTP
            success = False
            method_used = None

            if self.app:
                success = self.send_email_graph_api(subject, "", form_data)
                method_used = "Microsoft Graph API"

            if not success and self.smtp_username:
                success = self.send_email_smtp(subject, "", form_data)
                method_used = "SMTP"

            if success:
                return {
                    'success': True,
                    'message': f"Email sent successfully via {method_used}",
                    'method': method_used
                }
            else:
                return {
                    'success': False,
                    'error': "Failed to send email via both Graph API and SMTP"
                }

        except Exception as e:
            logger.error(f"Error in send_contact_form_email: {str(e)}")
            return {
                'success': False,
                'error': f"Internal error: {str(e)}"
            }


def main():
    """Test the email handler"""
    if len(sys.argv) < 2:
        print("Usage: python o365_email_handler.py <test|send>")
        return

    action = sys.argv[1]

    if action == "test":
        # Test configuration
        handler = O365EmailHandler()

        print("Testing O365 Email Handler Configuration...")
        print(f"Client ID: {'✓' if handler.client_id else '✗'}")
        print(f"Client Secret: {'✓' if handler.client_secret else '✗'}")
        print(f"Tenant ID: {'✓' if handler.tenant_id else '✗'}")
        print(f"From Email: {handler.from_email}")
        print(f"To Email: {handler.to_email}")
        print(f"SMTP Username: {'✓' if handler.smtp_username else '✗'}")
        print(f"SMTP Password: {'✓' if handler.smtp_password else '✗'}")

        # Test token acquisition
        if handler.app:
            token = handler.get_access_token()
            print(f"Graph API Token: {'✓' if token else '✗'}")

    elif action == "send":
        # Test email sending
        handler = O365EmailHandler()

        test_data = {
            'name': 'Test User',
            'email': 'test@example.com',
            'subject': 'Test Contact Form',
            'message': 'This is a test message from the O365 email handler.'
        }

        result = handler.send_contact_form_email(test_data)
        print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
