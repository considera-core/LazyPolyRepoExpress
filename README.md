# LazyPolyRepoExpress / LePREchaun

A command-line framework for managing multiple related repositories (poly-repo) with ease.

## Quick Links
**_These guides are written by Claude, I need to manually simplify them at some point._**
- **New to setup?** → [Quick Start Guide](tenants/QUICK_START.md) (5 minutes)
- **Need details?** → [Complete Tenant Setup Guide](TENANT_SETUP_GUIDE.md)
- **Using existing tenants?** → [Tenants Directory](tenants/README.md)

## Quick Roadmap
- **_Bash variant_**
- More control over launching and running apps (including support for Java and other langs)
- Multi-organization support
- Code-coverage tools
- Jira / Atlassian CLI support (to pipe with `ai claude` and `git story`)
- Fix and expand the `ai` module, claude currently doesn't contain its' window state properly.
- GH Actions for pulling the latest upstream commits (for private forks)
- More actions for all of the IDEs, and more IDEs to support
- **_Important: I'm probably going to move the project argument closer to the start, and handle the command arg shift in the fn-dispatch (ex: `sample-org sample-tenant sample-project git pull` vs `sample-org sample-tenant git pull sample-project`)_**
- Front-end app

## What is LePREchaun?

LePREchaun helps you manage multiple related projects (tenants) where each tenant contains multiple modules (repositories). It provides:

- **CSV-based configuration** for module definitions
- **Batch dispatchers** for routing commands to modules
- **Consistent CLI interface** across all tenants
- **Easy tenant onboarding** with templates and guides

## Getting Started

### Forking the LePREchaun

**For public usage:**
- Fork the repository

**For private usage:**
- First, visit https://github.com/new/import
- Then, set the URL to https://github.com/considera-core/LazyPolyRepoExpress.git
- Set your new repositories details and "Begin Import"
- Clone on your local machine
- Cmd and cd to your repo
- Add upstream remote to sync with the root repository: git remote add upstream https://github.com/considera-core/LazyPolyRepoExpress.git
- Verify: git remote -v
- Fetch: git fetch upstream
- Any changes in the upstream master are highly recommended to be merged into your origin master.

## Usage Examples
Once tenants are configured, use them like this:

```batch
# General format:
# {tenant_alias} {module} {command} {...args}

# Examples
# Org-level:
sample-org npm i ; sample-org npx knip # npm install and then npx -y knip for all repositories in sample-org
sample-org sample-tenant git story feat/ZC-STORY-0 # git pull and safely git switch to feat/ZC-STORY-0 for all repositories in sample-org/sample-tenant
sample-org sample-tenant git story admin feat/ZC-STORY-0
sample-org sample-tenant git pull admin
# Tenant-level:
sample-tenant git branches admin
sample-tenant npm "audit fix"
```

## Directory Structure
```
LazyPolyRepoExpress/
├── README.md                      ← You are here
├── TENANT_SETUP_GUIDE.md          ← Complete setup documentation
├── tenants/
│   ├── README.md                  ← Tenants overview
│   ├── QUICK_START.md             ← Quick tenant setup (5 min)
│   ├── data/
│   │   ├── tenants.csv           ← Registry of all tenants
│   │   ├── sample-tenant.csv     ← Sample tenant, remove when you have your own
│   │   ├── TEMPLATE.csv          ← Module CSV template
│   │   └── {tenant}.csv          ← Per-tenant module definitions
│   └── dispatch/
│       ├── TEMPLATE.bat          ← Dispatcher template
│       ├── sample-tenant.bat     ← Sample tenant, remove when you have your own
│       ├── {org}.bat             ← Org-level dispatcher
│       └── {tenant}.bat          ← Per-tenant dispatchers
├── modules/                       ← Core framework modules
├── config/                        ← Configuration files
└── install.bat / install.ps1     ← Installation scripts
```
- You can add a docker directory under LazyPolyRepoExpress/ if you want your own docker shortcuts

## Configured Tenants
This instance includes the following configured tenants:

### Your Organization
- **sample-tenant** (2 projects) - Sample tenant for sample org. Replace these with your own

### Examples
- **sample-tenant** - Example tenant for testing and reference

## Troubleshooting
### recent-branches git alias does not exist
Customize however you like, add it to your global git config (.gitconfig)
```
[alias]
    recent-branches = "!f() { for branch in $(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/); do if git branch -r | grep -qw \"$branch\"; then suffix=''; else suffix=' (local)'; fi; date=$(git log -1 --format='%cd' --date=short \"$branch\"); printf '\\033[32m%s\\033[0m: \\033[33m%s%s\\033[0m\\n' \"$date\" \"$branch\" \"$suffix\"; done; }; f"
```

## Important reminders
### This is intended to be LOCAL dev only
### NEVER commit SECRETS values
- If you plan to add secrets to the repository, then please refer to the **private usage** forking instructions