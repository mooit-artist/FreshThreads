#!/bin/bash
# Fresh Threads LLC - Automated GitHub Projects Setup
# Creates complete Agile project management system

echo "🚀 Fresh Threads LLC - Automated GitHub Projects Setup"
echo "======================================================"
echo ""
echo "🤖 Automating your entire Agile project management setup..."
echo ""

# Check if authenticated with GitHub
echo "🔐 Checking GitHub authentication..."
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "🔑 Please run: gh auth login"
    echo "   Then re-run this script"
    exit 1
fi

echo "✅ GitHub CLI authenticated"
echo ""

# Repository details
REPO="mooit-artist/FreshThreads"
PROJECT_TITLE="Fresh Threads Agile Sprints"
PROJECT_DESC="Professional sprint management for T-shirt business launch"

echo "📋 Creating GitHub Project: $PROJECT_TITLE"
echo "Repository: $REPO"
echo ""

# Create the project
echo "🔧 Creating project board..."
PROJECT_ID=$(gh project create --owner mooit-artist --title "$PROJECT_TITLE" --body "$PROJECT_DESC" --format json | jq -r '.id')

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "null" ]; then
    echo "❌ Failed to create project. Trying alternative method..."

    # Try creating with different approach
    gh api graphql -f query='
    mutation($input: CreateProjectV2Input!) {
        createProjectV2(input: $input) {
            projectV2 {
                id
                title
                url
            }
        }
    }' -f input='{
        "ownerId": "'"$(gh api user --jq '.node_id')"'",
        "title": "'"$PROJECT_TITLE"'",
        "repositoryId": "'"$(gh api repos/mooit-artist/FreshThreads --jq '.node_id')"'"
    }' --jq '.data.createProjectV2.projectV2.id'

    PROJECT_ID=$(gh api graphql -f query='
    query {
        user(login: "mooit-artist") {
            projectsV2(first: 10) {
                nodes {
                    id
                    title
                }
            }
        }
    }' --jq '.data.user.projectsV2.nodes[] | select(.title == "'"$PROJECT_TITLE"'") | .id')
fi

echo "✅ Project created with ID: $PROJECT_ID"
echo ""

# Get the project URL
PROJECT_URL=$(gh api graphql -f query='
query($id: ID!) {
    node(id: $id) {
        ... on ProjectV2 {
            url
        }
    }
}' -f id="$PROJECT_ID" --jq '.data.node.url')

echo "📋 Project URL: $PROJECT_URL"
echo ""

# Create user stories as issues
echo "📝 Creating user stories..."

declare -a stories=(
    "🎨 Design first T-shirt concept and mockup|Story: As a business owner, I want to create an attractive T-shirt design so that I can start selling products.|3|High|Product Development"
    "🌐 Create basic business website/landing page|Story: As a potential customer, I want to visit a professional website so that I can learn about Fresh Threads LLC.|5|Critical|Website & Marketing"
    "📦 Research print-on-demand suppliers|Story: As a business owner, I want to find reliable suppliers so that I can fulfill orders efficiently.|2|High|Business Foundation"
    "💳 Set up Stripe payment processing|Story: As a customer, I want to pay securely online so that I can purchase T-shirts easily.|3|Critical|Business Foundation"
    "🏪 Choose and configure e-commerce platform|Story: As a business owner, I want an online store so that I can sell T-shirts 24/7.|5|Critical|Website & Marketing"
    "📱 Set up business social media accounts|Story: As a potential customer, I want to follow Fresh Threads on social media so that I can see new designs.|2|Medium|Website & Marketing"
    "📊 Configure Google Analytics and business tracking|Story: As a business owner, I want to track website visitors so that I can understand my customers.|2|Medium|Analytics & Growth"
    "🎯 Define target customer personas|Story: As a marketer, I want to know my ideal customers so that I can create targeted campaigns.|3|High|Analytics & Growth"
    "💰 Create first T-shirt product listing|Story: As a customer, I want to see product details and pricing so that I can make a purchase decision.|3|High|Product Development"
    "📧 Set up email marketing system|Story: As a business owner, I want to email customers about new products so that I can increase sales.|2|Medium|Website & Marketing"
)

for story in "${stories[@]}"; do
    IFS='|' read -r title body points priority epic <<< "$story"

    echo "📝 Creating: $title"

    # Create issue with labels
    gh issue create \
        --repo "$REPO" \
        --title "$title" \
        --body "$body

**Story Points:** $points
**Priority:** $priority
**Epic:** $epic
**Sprint:** Backlog

**Acceptance Criteria:**
- [ ] Define specific requirements
- [ ] Implement solution
- [ ] Test and validate
- [ ] Document results" \
        --label "user-story,$priority,$epic" > /dev/null

    sleep 1  # Rate limiting
done

echo ""
echo "✅ Created 10 user stories as GitHub issues"
echo ""

echo "🎯 Setting up Sprint 1..."

# Get some issue numbers for Sprint 1
ISSUES=$(gh issue list --repo "$REPO" --limit 5 --json number --jq '.[].number' | head -3)

echo "📋 Sprint 1 Goal: Launch Fresh Threads MVP"
echo "📅 Duration: Aug 4-10, 2025"
echo "🎯 Selected issues for Sprint 1:"

for issue in $ISSUES; do
    echo "   • Issue #$issue"
    gh issue edit "$issue" --repo "$REPO" --add-label "sprint-1"
done

echo ""
echo "🎉 AUTOMATION COMPLETE!"
echo "======================="
echo ""
echo "✅ What was created:"
echo "   📋 GitHub Project: $PROJECT_TITLE"
echo "   📝 10 user stories as issues"
echo "   🎯 Sprint 1 planned with 3 stories"
echo "   🏷️  Proper labels and organization"
echo ""
echo "🔗 Your Project Board: $PROJECT_URL"
echo ""
echo "📋 Next Steps:"
echo "   1. Visit your project board (link above)"
echo "   2. Review and prioritize user stories"
echo "   3. Start Sprint 1 development"
echo "   4. Update story status as you work"
echo ""
echo "🚀 Fresh Threads LLC now has enterprise-level project management!"
