#!/bin/bash
# Fresh Threads LLC - Simple Automated Issues Creation

echo "🚀 Fresh Threads LLC - Creating User Stories"
echo "============================================"
echo ""

REPO="mooit-artist/FreshThreads"

# Create labels first
echo "🏷️  Creating labels..."
gh label create "user-story" --color "0E8A16" --description "User story for feature development" --repo "$REPO" 2>/dev/null || echo "   Label 'user-story' already exists"
gh label create "sprint-1" --color "1D76DB" --description "Sprint 1 items" --repo "$REPO" 2>/dev/null || echo "   Label 'sprint-1' already exists"
gh label create "Product Development" --color "D93F0B" --description "Product development epic" --repo "$REPO" 2>/dev/null || echo "   Label 'Product Development' already exists"
gh label create "Website & Marketing" --color "0052CC" --description "Website and marketing epic" --repo "$REPO" 2>/dev/null || echo "   Label 'Website & Marketing' already exists"
gh label create "Business Foundation" --color "5319E7" --description "Business foundation epic" --repo "$REPO" 2>/dev/null || echo "   Label 'Business Foundation' already exists"
gh label create "Analytics & Growth" --color "F9D0C4" --description "Analytics and growth epic" --repo "$REPO" 2>/dev/null || echo "   Label 'Analytics & Growth' already exists"

echo "✅ Labels created"
echo ""

echo "📝 Creating user stories..."

# Create user stories
stories=(
    "🎨 Design first T-shirt concept and mockup|Product Development|3"
    "🌐 Create basic business website/landing page|Website & Marketing|5"
    "📦 Research print-on-demand suppliers|Business Foundation|2"
    "💳 Set up Stripe payment processing|Business Foundation|3"
    "🏪 Choose and configure e-commerce platform|Website & Marketing|5"
    "📱 Set up business social media accounts|Website & Marketing|2"
    "📊 Configure Google Analytics|Analytics & Growth|2"
    "🎯 Define target customer personas|Analytics & Growth|3"
    "💰 Create first T-shirt product listing|Product Development|3"
    "📧 Set up email marketing system|Website & Marketing|2"
)

for story in "${stories[@]}"; do
    IFS='|' read -r title epic points <<< "$story"

    echo "📝 Creating: $title"

    # Create issue
    issue_body="**Epic:** $epic
**Story Points:** $points
**Status:** Backlog

**User Story:**
As a business owner/customer, I want to $title so that I can achieve business goals.

**Acceptance Criteria:**
- [ ] Define specific requirements
- [ ] Research and plan implementation
- [ ] Implement solution
- [ ] Test functionality
- [ ] Document and deploy

**Definition of Done:**
- [ ] Functionality works as expected
- [ ] Code/content is reviewed
- [ ] Documentation is updated
- [ ] Ready for customer use"

    gh issue create \
        --repo "$REPO" \
        --title "$title" \
        --body "$issue_body" \
        --label "user-story,$epic" > /dev/null

    sleep 1
done

echo ""
echo "✅ Created 10 user stories!"
echo ""

# Show created issues
echo "📋 Your Fresh Threads User Stories:"
gh issue list --repo "$REPO" --label "user-story" --limit 10

echo ""
echo "🎯 To create your project board:"
echo "1. Go to: https://github.com/mooit-artist/FreshThreads/projects"
echo "2. Click 'New project'"
echo "3. Choose 'Table' view"
echo "4. Name: 'Fresh Threads Agile Sprints'"
echo "5. Add your issues to the project"
echo ""
echo "🚀 Ready to start your first sprint!"
