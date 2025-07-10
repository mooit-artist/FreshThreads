# FreshThreads# 🧾 Fresh Threads LLC — Session Summary (July 9, 2025)

## 🏢 Business Setup
- Selected **Member-managed LLC** structure, modeled after your handyman business
- Company purpose (≤50 characters):  
  `Custom apparel via print-on-demand services`
- Registered domain via Namecheap (with promo code help)
- Phone branding explored with 402-252-7XXX — ultimately selected a random number for simplicity

---

## 🌐 Website Strategy
- Hosting on **GitHub Pages** with Jekyll for full control and no cost
- Submitted slogans (e.g., "The Shitter is Full !!!") via private form
- Desired workflow:  
  `Submit slogan → Mockup → Approval → Printify publish`
- Frontend form will live on your site, not via Google Forms

---

## 🔄 Backend Integration Plan (AWS)
Using **AWS Free Tier** to avoid SaaS fees until revenue begins

### Services:
- **API Gateway + Lambda**: Form submission handler
- **DynamoDB**: Stores slogans, approval status
- **S3**: Hosts mockup images
- **SES** (optional): Email approvals or notifications

### Flow:
1. Submit slogan via form
2. Lambda stores submission in DynamoDB
3. Mockup auto-generated or uploaded to S3
4. Dashboard shows pending slogans for approval
5. Approval triggers Printify product creation + Shopify sync

---

## 💰 Cost Strategy
- No SaaS subscriptions until Fresh Threads generates revenue
- Will front **QuickBooks Online** for accounting integrity
- Future automation stack (once scaled): $75–$165/month
- Start lean using AWS Free Tier, GitHub, and manual mockups via Canva

---

## 📣 Social Media Workflow
- Campaign flow mapped:  
  `New slogan → Instagram Post → Shopify Listing → QuickBooks`
- Optional social post triggered via approval
- Discussed integration via storefront (e.g., Shopify + Meta Pixel)

---

## ✅ Action Items
- Build custom HTML form on GitHub Pages
- Set up Lambda + API Gateway to handle submissions
- Design DynamoDB schema for slogan tracking
- Create mockup system (manual or automated)
- Prepare approval dashboard to trigger Printify API

