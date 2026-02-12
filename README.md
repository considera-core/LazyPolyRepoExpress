# LazyPolyRepoExpress

A command-line framework for managing multiple related repositories (poly-repo) with ease.

## Quick Links

- **New to setup?** → [Quick Start Guide](tenants/QUICK_START.md) (5 minutes)
- **Need details?** → [Complete Tenant Setup Guide](TENANT_SETUP_GUIDE.md)
- **Using existing tenants?** → [Tenants Directory](tenants/README.md)

## What is LazyPolyRepoExpress?

LazyPolyRepoExpress helps you manage multiple related projects (tenants) where each tenant contains multiple modules (repositories). It provides:

- **CSV-based configuration** for module definitions
- **Batch dispatchers** for routing commands to modules
- **Consistent CLI interface** across all tenants
- **Easy tenant onboarding** with templates and guides

## Getting Started

### Setting Up LazyPolyRepoExpress

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
- Any changes in the upstream master are highly recommended to be merged into your origin master

### Adding Your First Tenant

1. Read the [Quick Start Guide](tenants/QUICK_START.md)
2. Copy the templates from `tenants/data/TEMPLATE.csv` and `tenants/dispatch/TEMPLATE.bat`
3. Fill in your tenant and module details
4. Register your tenant in `tenants/data/tenants.csv`
5. Test: `your-tenant help`

**Time to setup:** ~5 minutes

## Usage Examples

Once tenants are configured, use them like this:

```batch
# General format
{tenant-key} {module} {command} {args}

# Examples
vitals admin git status
ecertify api npm install
records dashboard help
ram public git pull
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

## Configured Tenants

This instance includes the following configured tenants:

### Your Organization
- **sample-tenant** (2 projects) - Sample tenant for sample org. Replace these with your own

### Examples
- **sample-tenant** - Example tenant for testing and reference

## Documentation

| Document | Purpose | Audience |
|----------|---------|----------|
| [QUICK_START.md](tenants/QUICK_START.md) | Add a tenant in 5 minutes | Developers adding tenants |
| [TENANT_SETUP_GUIDE.md](TENANT_SETUP_GUIDE.md) | Complete setup guide | Developers needing details |
| [tenants/README.md](tenants/README.md) | Tenants overview | All developers |

## Support

Need help?
1. Check the [Quick Start Guide](tenants/QUICK_START.md)
2. Review the [Complete Setup Guide](TENANT_SETUP_GUIDE.md)
3. Look at existing tenant examples in `tenants/data/`
4. Check troubleshooting section in the setup guide

## License

See LICENSE file for details.

# recent-branches git alias
Customize however you like, add it to your global git config (.gitconfig)
```
[alias]
    recent-branches = "!f() { for branch in $(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/); do if git branch -r | grep -qw \"$branch\"; then suffix=''; else suffix=' (local)'; fi; date=$(git log -1 --format='%cd' --date=short \"$branch\"); printf '\\033[32m%s\\033[0m: \\033[33m%s%s\\033[0m\\n' \"$date\" \"$branch\" \"$suffix\"; done; }; f"
```
