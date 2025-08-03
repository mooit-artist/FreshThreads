#!/bin/bash

# GitHub Issues Creation Script for Business Setup
# Run this script to create GitHub issues from the business setup checklist

REPO="mooit-artist/FreshThreads"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Creating GitHub Issues for Business Setup...${NC}"

# Issue 1: Business Banking Setup
gh issue create \
  --title "🏦 Setup Business Banking - American Express Business Checking" \
  --body "## Goal
Set up professional business banking to separate personal and business finances.

## Tasks
- [ ] Gather EIN or SSN documentation
- [ ] Confirm business name & structure (LLC, etc.)
- [ ] Provide business address & contact information
- [ ] Apply online: [Amex Business Checking](https://www.americanexpress.com/en-us/banking/business-checking/)

## Acceptance Criteria
- [ ] Business checking account is opened and active
- [ ] Account is linked to business EIN
- [ ] Initial funding is deposited
- [ ] Account details are documented securely

## Priority
High - Required for all other payment integrations

## Dependencies
- Business registration/EIN
- Business address verification" \
  --label "business-setup,banking,high-priority" \
  --assignee "@me"

echo -e "${GREEN}✓ Created: Business Banking Setup${NC}"

# Issue 2: Payment Platforms
gh issue create \
  --title "💳 Setup Payment Processing - Stripe & PayPal Business" \
  --body "## Goal
Establish payment processing capabilities for customer transactions.

## Stripe Setup
- [ ] Create Stripe account
- [ ] Add business information
- [ ] Link Amex Business Checking account
- [ ] Complete identity verification
- [ ] Set up products or connect to storefront

## PayPal Business Setup
- [ ] Create PayPal Business account
- [ ] Link Amex Business Checking account
- [ ] Enable PayPal Checkout
- [ ] Enable Venmo payments
- [ ] Enable PayPal Credit option

## Acceptance Criteria
- [ ] Both Stripe and PayPal accounts are verified and active
- [ ] Test transactions can be processed
- [ ] Bank accounts are properly linked
- [ ] All payment methods are configured

## Priority
High - Critical for revenue generation

## Dependencies
- Business banking account (#1)" \
  --label "business-setup,payments,high-priority" \
  --assignee "@me"

echo -e "${GREEN}✓ Created: Payment Platforms Setup${NC}"

# Issue 3: Accounting System
gh issue create \
  --title "🧾 Setup Accounting System - QuickBooks Online" \
  --body "## Goal
Implement professional accounting system for financial tracking and tax preparation.

## Tasks
- [ ] Sign up for QuickBooks Online
- [ ] Choose plan: Simple Start (\$38) or Essentials (\$75)
- [ ] Add business information and settings
- [ ] Link Amex Business Checking account
- [ ] Set up chart of accounts categories:
  - [ ] Income categories
  - [ ] Expense categories
  - [ ] Fee tracking
  - [ ] Software subscriptions
  - [ ] Marketing expenses
  - [ ] Product costs
  - [ ] Payment processing fees

## Acceptance Criteria
- [ ] QuickBooks account is active and configured
- [ ] Bank account is linked and syncing
- [ ] Chart of accounts is properly structured
- [ ] Initial expenses are logged
- [ ] Monthly/quarterly reporting is set up

## Priority
High - Required for tax compliance and financial management

## Dependencies
- Business banking account (#1)" \
  --label "business-setup,accounting,high-priority" \
  --assignee "@me"

echo -e "${GREEN}✓ Created: Accounting System Setup${NC}"

# Issue 4: Payment Integration
gh issue create \
  --title "🔄 Setup Stripe → QuickBooks Integration" \
  --body "## Goal
Automate financial data flow from Stripe to QuickBooks for accurate bookkeeping.

## Research Integration Options
- [ ] Evaluate Acodei Scale100 (\$12/month) - [acodei.com](https://acodei.com)
- [ ] Evaluate Synder Basic (\$52/month) - [synder.com](https://synder.com)
- [ ] Compare features and pricing
- [ ] Choose best integration tool

## Implementation
- [ ] Sign up for chosen integration service
- [ ] Connect Stripe account to integration tool
- [ ] Connect QuickBooks account to integration tool
- [ ] Configure auto-sync settings:
  - [ ] Transactions
  - [ ] Processing fees
  - [ ] Refunds
  - [ ] Payouts
- [ ] Test integration with sample data
- [ ] Set up monitoring and alerts

## Acceptance Criteria
- [ ] Stripe transactions automatically sync to QuickBooks
- [ ] All fees and refunds are properly categorized
- [ ] Integration runs reliably without manual intervention
- [ ] Financial reports are accurate and up-to-date

## Priority
Medium - Important for automation but not blocking

## Dependencies
- Stripe account setup (#2)
- QuickBooks setup (#3)" \
  --label "business-setup,integration,automation,medium-priority" \
  --assignee "@me"

echo -e "${GREEN}✓ Created: Payment Integration Setup${NC}"

# Issue 5: Storefront Platform
gh issue create \
  --title "📦 Setup E-commerce Storefront Platform" \
  --body "## Goal
Launch customer-facing storefront for product sales.

## Platform Selection
- [ ] Research options: Shopify, WooCommerce, Etsy, Gumroad
- [ ] Compare features, costs, and integration capabilities
- [ ] Choose platform based on print-on-demand needs
- [ ] Set up account on chosen platform

## Payment Integration
- [ ] Connect Stripe payment processing
- [ ] Connect PayPal payment processing
- [ ] Test payment flows

## Product Setup
- [ ] Add first products with mockups
- [ ] Write product descriptions
- [ ] Set competitive pricing
- [ ] Configure product variants (sizes, colors)

## Business Configuration
- [ ] Set up shipping profiles
- [ ] Configure tax settings
- [ ] Set up return/refund policies
- [ ] Configure order fulfillment

## Launch Preparation
- [ ] Test complete customer journey
- [ ] Set up order notifications
- [ ] Configure inventory tracking
- [ ] Set up customer support

## Acceptance Criteria
- [ ] Storefront is live and functional
- [ ] Payments process correctly
- [ ] Products are properly displayed
- [ ] Order fulfillment works end-to-end
- [ ] Mobile responsiveness is verified

## Priority
High - Required for revenue generation

## Dependencies
- Payment platforms setup (#2)" \
  --label "business-setup,storefront,e-commerce,high-priority" \
  --assignee "@me"

echo -e "${GREEN}✓ Created: Storefront Platform Setup${NC}"

# Issue 6: Financial Tracking System
gh issue create \
  --title "📈 Implement Financial Tracking & Reporting System" \
  --body "## Goal
Establish comprehensive financial tracking for business performance monitoring.

## Initial Setup
- [ ] Log all initial business expenses in QuickBooks
- [ ] Set up recurring expense tracking
- [ ] Configure automated categorization rules

## Expense Categories
- [ ] Software subscriptions
- [ ] Marketing and advertising
- [ ] Product costs and materials
- [ ] Payment processing fees
- [ ] Business banking fees
- [ ] Professional services
- [ ] Office supplies and equipment

## Reporting Setup
- [ ] Configure monthly P&L reports
- [ ] Set up cash flow tracking
- [ ] Create expense analysis dashboards
- [ ] Set up tax preparation reports

## Monitoring & Alerts
- [ ] Set up budget alerts
- [ ] Configure expense thresholds
- [ ] Set up monthly financial review process

## Acceptance Criteria
- [ ] All expenses are properly categorized
- [ ] Monthly reports generate automatically
- [ ] Financial performance is clearly visible
- [ ] Tax preparation data is organized
- [ ] Budget tracking is active

## Priority
Medium - Important for business management

## Dependencies
- QuickBooks setup (#3)
- Payment integration (#4)" \
  --label "business-setup,financial-tracking,reporting,medium-priority" \
  --assignee "@me"

echo -e "${GREEN}✓ Created: Financial Tracking System${NC}"

# Issue 7: Loan Readiness (Optional)
gh issue create \
  --title "🧠 Prepare for Future Business Financing Options" \
  --body "## Goal
Establish financial practices that support future loan applications or business credit.

## Banking Best Practices
- [ ] Maintain consistent funding in Amex Business Checking
- [ ] Avoid mixing personal and business funds
- [ ] Document all business transactions properly
- [ ] Maintain minimum balance requirements

## Financial Documentation
- [ ] Ensure all revenue is tracked in QuickBooks
- [ ] Maintain detailed expense records
- [ ] Generate monthly financial statements
- [ ] Track business growth metrics

## Credit Building
- [ ] Research business credit cards
- [ ] Consider Amex business credit products
- [ ] Monitor business credit score
- [ ] Establish vendor payment history

## Future Expansion
- [ ] Open Amex High-Yield Business Savings once revenue starts
- [ ] Research SBA loan options
- [ ] Document business plan and projections
- [ ] Maintain clean financial records

## Acceptance Criteria
- [ ] Business finances are completely separate from personal
- [ ] Financial records are accurate and up-to-date
- [ ] Banking relationships are established
- [ ] Credit building strategies are in place

## Priority
Low - Future planning, not immediate need

## Dependencies
- All other business setup items (#1-6)" \
  --label "business-setup,financing,future-planning,low-priority" \
  --assignee "@me"

echo -e "${GREEN}✓ Created: Loan Readiness Planning${NC}"

echo -e "${BLUE}All GitHub issues have been created successfully!${NC}"
echo -e "${BLUE}Visit your repository to view and manage the issues.${NC}"
