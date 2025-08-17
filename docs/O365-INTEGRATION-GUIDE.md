# Office 365 Email Integration Setup Guide

This guide will help you set up Office 365 integration for your FreshThreads contact form. The integration supports both Microsoft Graph API (recommended) and SMTP fallback methods.

## Overview

The O365 integration provides:

- Direct email sending through your Office 365 account
- Professional email formatting with your business branding
- Automatic logging and error handling
- Fallback SMTP support if Graph API is unavailable
- Secure API endpoints with CORS support

## Prerequisites

1. **Office 365 Business Account** - You need an active O365 subscription
2. **Azure Active Directory Access** - For Graph API setup (recommended)
3. **Python 3.8+** - For the backend API
4. **Domain Email Address** - Your business email (e.g., hello@freshthreadsllc.com)

## Setup Options

### Option 1: Microsoft Graph API (Recommended)

This is the modern, secure way to integrate with Office 365.

#### Step 1: Create Azure App Registration

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **App registrations**
3. Click **New registration**
4. Fill in the details:
   - **Name**: `FreshThreads Contact Form`
   - **Supported account types**: `Accounts in this organizational directory only`
   - **Redirect URI**: Leave blank for now
5. Click **Register**

#### Step 2: Configure API Permissions

1. In your new app registration, go to **API permissions**
2. Click **Add a permission**
3. Select **Microsoft Graph**
4. Choose **Application permissions**
5. Add these permissions:
   - `Mail.Send` - Send mail as any user
   - `User.Read.All` - Read all users' profiles (optional)
6. Click **Grant admin consent** (requires admin privileges)

#### Step 3: Create Client Secret

1. Go to **Certificates & secrets**
2. Click **New client secret**
3. Add description: `FreshThreads API Secret`
4. Choose expiration: `24 months` (recommended)
5. Click **Add**
6. **Copy the secret value immediately** - you won't see it again!

#### Step 4: Get Configuration Values

From your Azure app registration, collect:

- **Application (client) ID** - From the Overview page
- **Directory (tenant) ID** - From the Overview page
- **Client secret** - From the previous step

### Option 2: SMTP Authentication (Fallback)

If you can't use Graph API, you can use SMTP with app passwords.

#### Step 1: Enable App Passwords

1. Go to [Microsoft Account Security](https://account.microsoft.com/security)
2. Enable **Two-step verification** if not already enabled
3. Go to **App passwords**
4. Create new app password for "FreshThreads Website"
5. Copy the generated password

#### Step 2: SMTP Settings

Use these settings:

- **Server**: `smtp-mail.outlook.com`
- **Port**: `587`
- **Security**: `STARTTLS`
- **Username**: Your full email address
- **Password**: The app password from Step 1

## Installation

### Step 1: Install Python Dependencies

```bash
cd /Users/bryanjorgensen/Documents/GitHub/CodeProjects/WEB/FreshThreads
pip install -r config/requirements-o365.txt
```

### Step 2: Configure Environment Variables

1. Copy the configuration template:

```bash
cp config/o365-config.env.template config/o365-config.env
```

2. Edit the configuration file:

```bash
nano config/o365-config.env
```

3. Fill in your values:

**For Graph API:**

```env
O365_CLIENT_ID=your_client_id_from_azure
O365_CLIENT_SECRET=your_client_secret_from_azure
O365_TENANT_ID=your_tenant_id_from_azure
O365_FROM_EMAIL=hello@freshthreadsllc.com
O365_TO_EMAIL=hello@freshthreadsllc.com
```

**For SMTP (additional/fallback):**

```env
O365_SMTP_USERNAME=hello@freshthreadsllc.com
O365_SMTP_PASSWORD=your_app_password_here
```

### Step 3: Create Logs Directory

```bash
mkdir -p logs
touch logs/o365_email.log
touch logs/contact_api.log
touch logs/contact_submissions.log
```

## Testing

### Step 1: Test Configuration

```bash
python scripts/o365_email_handler.py test
```

This will check your configuration and verify connectivity.

### Step 2: Test Email Sending

```bash
python scripts/o365_email_handler.py send
```

This will send a test email to verify the integration works.

### Step 3: Start the API Server

```bash
python contact_api.py
```

The API will start on `http://localhost:5001`

### Step 4: Test the API Endpoint

```bash
curl -X POST http://localhost:5001/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "subject": "Test Message",
    "message": "This is a test message from the API."
  }'
```

## Production Deployment

### Step 1: Environment Variables

Set environment variables in your production environment:

```bash
export O365_CLIENT_ID="your_client_id"
export O365_CLIENT_SECRET="your_client_secret"
export O365_TENANT_ID="your_tenant_id"
export O365_FROM_EMAIL="hello@freshthreadsllc.com"
export O365_TO_EMAIL="hello@freshthreadsllc.com"
export FLASK_ENV="production"
export PORT="5001"
```

### Step 2: Start Production Server

```bash
# Using Gunicorn (recommended)
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5001 contact_api:app

# Or using Python directly
python contact_api.py
```

### Step 3: Configure Reverse Proxy

Add to your nginx/Apache configuration:

**Nginx:**

```nginx
location /api/ {
    proxy_pass http://localhost:5001/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Step 4: Update Frontend

The contact form is already configured to use:

- `http://localhost:5001/contact` for development
- `/api/contact` for production

## Security Considerations

### API Security

- Client secrets should be stored securely and rotated regularly
- Use HTTPS in production
- Implement rate limiting if needed
- Monitor API usage and logs

### Email Security

- Validate all input data
- Sanitize email content to prevent injection
- Log all email attempts for audit purposes
- Set up monitoring for failed email attempts

### Azure Security

- Use least-privilege permissions
- Enable conditional access if available
- Monitor app registration usage
- Set up alerts for suspicious activity

## Troubleshooting

### Common Issues

**Graph API Token Errors:**

- Check client ID, secret, and tenant ID
- Verify API permissions are granted
- Ensure admin consent was provided

**SMTP Authentication Errors:**

- Verify app password is correct
- Check that 2FA is enabled
- Ensure SMTP is not blocked by firewall

**Permission Errors:**

- Check that the app has Mail.Send permission
- Verify admin consent was granted
- Try re-creating the client secret

### Logs and Monitoring

Check these log files for debugging:

- `logs/o365_email.log` - Email handler logs
- `logs/contact_api.log` - API server logs
- `logs/contact_submissions.log` - Form submission backup

### Testing Commands

```bash
# Test configuration
python scripts/o365_email_handler.py test

# Test email sending
python scripts/o365_email_handler.py send

# Check API health
curl http://localhost:5001/health

# Test contact endpoint
curl -X POST http://localhost:5001/contact -H "Content-Type: application/json" -d '{"name":"Test","email":"test@example.com","subject":"Test","message":"Test message"}'
```

## Support

If you encounter issues:

1. Check the logs for error messages
2. Verify your configuration settings
3. Test with the provided test commands
4. Review Azure app registration settings
5. Check Office 365 admin center for any restrictions

For additional help, refer to:

- [Microsoft Graph Documentation](https://docs.microsoft.com/en-us/graph/)
- [Azure App Registration Guide](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
- [Office 365 SMTP Settings](https://docs.microsoft.com/en-us/exchange/mail-flow-best-practices/how-to-set-up-a-multifunction-device-or-application-to-send-email-using-microsoft-365-or-office-365)

## Migration from Formspree

Your contact form has been updated to use the new O365 backend. The changes include:

1. **Form Action**: Changed from Formspree URL to `/contact`
2. **JavaScript**: Updated to use JSON API instead of form submission
3. **Hidden Fields**: Replaced Formspree fields with metadata fields
4. **Error Handling**: Enhanced error messages and validation

The form will automatically:

- Use `localhost:5001` during development
- Use `/api/contact` in production
- Provide better error messages
- Log submissions for backup

All existing styling and functionality is preserved.
