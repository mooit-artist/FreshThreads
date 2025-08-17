# Feature Request: Extract M365 Automation Tools to Separate Repository

## 📋 Summary

Extract the generic Microsoft 365 automation tools from the FreshThreads repository into a dedicated, reusable M365 automation toolkit repository.

## 🎯 Background

During the FreshThreads O365 contact form integration (completed Aug 17, 2025), we developed a comprehensive set of M365 automation tools. While these tools are currently FreshThreads-specific, many have generic utility and could benefit other projects.

## 📊 Current State Analysis

### Tools in `scripts/` Directory:

#### 🔄 **Generic Tools (Reusable)**

- `find-azure-apps.ps1` - Find Azure App Registrations in tenant
- `find-azure-apps-modern.ps1` - Modern Graph API version of app finder
- `enable-smtp-auth.ps1` - Enable SMTP authentication at tenant level
- `grant-admin-consent.ps1` - Grant admin consent for app permissions
- `fix-azure-app.ps1` - Add redirect URIs to fix consent flow
- `check-azure-config.sh` - Check Azure app configuration status

#### 🏢 **FreshThreads-Specific Tools (Need Parameterization)**

- `create-azure-app.ps1` - Creates "FreshThreads O365 Integration" app
- `generate-app-password.ps1` - Uses procurement@freshthreadsllc.com
- `create-business-user-graph.ps1` - FreshThreads business setup
- `update-smtp-password.ps1` - Updates FreshThreads config
- `o365_email_handler.py` - Python email integration

#### 🔧 **Supporting Files**

- `config/o365-config.env` - Configuration template
- `contact_api.py` - Flask integration (FreshThreads-specific)

## 🚀 Proposed Future Repository Structure

```
m365-automation-toolkit/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── docs/
│   ├── setup-guide.md
│   ├── azure-app-registration.md
│   ├── smtp-configuration.md
│   └── troubleshooting.md
├── scripts/
│   ├── azure/
│   │   ├── create-app-registration.ps1
│   │   ├── find-app-registrations.ps1
│   │   ├── grant-admin-consent.ps1
│   │   ├── fix-redirect-uris.ps1
│   │   └── delete-app-registration.ps1
│   ├── exchange/
│   │   ├── enable-smtp-auth.ps1
│   │   ├── create-app-password.ps1
│   │   └── test-smtp-config.ps1
│   ├── users/
│   │   ├── create-business-user.ps1
│   │   ├── create-bulk-users.ps1
│   │   └── manage-aliases.ps1
│   ├── integration/
│   │   ├── o365_email_handler.py
│   │   └── flask_contact_api.py
│   └── utilities/
│       ├── check-config.sh
│       └── test-integration.py
├── templates/
│   ├── config-templates/
│   │   ├── o365-config.env.template
│   │   └── azure-app-config.json.template
│   └── examples/
│       ├── basic-contact-form/
│       └── advanced-email-integration/
├── tests/
│   ├── unit/
│   └── integration/
└── .github/
    ├── workflows/
    │   └── test-scripts.yml
    └── ISSUE_TEMPLATE/
```

## 🎯 Goals for New Repository

### Primary Objectives:

- [ ] **Parameterize all hardcoded values** (tenant IDs, email addresses, app names)
- [ ] **Create comprehensive documentation** with setup guides
- [ ] **Add error handling and logging** to all scripts
- [ ] **Implement configuration management** system
- [ ] **Add automated testing** for PowerShell scripts
- [ ] **Create example integrations** and templates

### Advanced Features:

- [ ] **Multi-tenant support** for managing multiple 365 environments
- [ ] **CI/CD pipeline** for testing scripts across different environments
- [ ] **Package manager integration** (PowerShell Gallery, npm, pip)
- [ ] **Interactive setup wizard** for first-time configuration
- [ ] **Monitoring and alerting** for automation health

## 📅 Migration Timeline

### Phase 1: Preparation (When 2nd Domain Added)

- [ ] Identify all FreshThreads-specific values to parameterize
- [ ] Create configuration management system
- [ ] Write comprehensive documentation
- [ ] Add automated tests

### Phase 2: Repository Creation

- [ ] Create new public repository
- [ ] Migrate and refactor scripts
- [ ] Set up CI/CD pipeline
- [ ] Publish initial release

### Phase 3: Integration

- [ ] Update FreshThreads to use new toolkit as dependency
- [ ] Create example integrations
- [ ] Community outreach and documentation

## 🔄 Current Decision: Stay in FreshThreads

### Rationale:

- ✅ FreshThreads is currently the only 365-onboarded domain
- ✅ Tools are actively used and under development
- ✅ Integration context is valuable for testing
- ✅ Rapid iteration is more important than abstraction right now

### Success Metrics for Migration Trigger:

- [ ] Second domain/tenant to manage
- [ ] Tools are stable and well-tested
- [ ] Clear need for sharing with other projects
- [ ] FreshThreads repo becomes too cluttered

## 🏷️ Labels

- `enhancement`
- `future-planning`
- `m365-automation`
- `refactoring`
- `tooling`

## 📝 Additional Notes

- This issue serves as a tracking mechanism for future extraction
- Current O365 integration in FreshThreads is complete and functional
- Decision to extract should be revisited when managing multiple 365 tenants
- All tools should maintain backward compatibility during migration

---

**Created:** August 17, 2025
**Status:** Planned for Future
**Priority:** Low (until 2nd domain added)
**Effort:** Large (3-5 days of refactoring work)
