# Tenants Configuration

This directory contains tenant configurations for LazyPolyRepoExpress.

## What is a Tenant?

A **tenant** represents a project or organization with multiple related modules (repositories/applications). Each tenant has:
- Multiple modules (APIs, web apps, lambdas, etc.)
- A CSV configuration file defining all modules
- A batch dispatcher for command routing
- An entry in the tenant registry

## Directory Structure

```
tenants/
├── README.md                  ← You are here
├── QUICK_START.md             ← Start here to add a new tenant (5 minutes)
├── data/
│   ├── tenants.csv           ← Registry of all tenants
│   ├── TEMPLATE.csv          ← Copy this to create new tenant CSVs
│   ├── {tenant-key}.csv      ← One CSV per tenant
│   └── ...
└── dispatch/
    ├── TEMPLATE.bat          ← Copy this to create new dispatchers
    ├── {tenant-key}.bat      ← One dispatcher per tenant
    └── ...
```

## Getting Started

### For Developers Adding a New Tenant

1. **Quick Setup (5 minutes):**
   - Read [QUICK_START.md](QUICK_START.md)
   - Copy templates and fill in your tenant details
   - Test and you're done!

2. **Detailed Setup (if you need more info):**
   - Read [../TENANT_SETUP_GUIDE.md](../TENANT_SETUP_GUIDE.md)
   - Follow the comprehensive step-by-step guide
   - Review troubleshooting section if needed

### For Developers Using Existing Tenants

If you just want to use an already-configured tenant:

```batch
# List all tenants
type data\tenants.csv

# Use a tenant's dispatcher
vitals citizen git status
ecertify admin npm install
records api help
```

## Configured Tenants

Current tenants in this system:

### Vanguard Organization
- **ecertify** - E-Certify (6 modules)
- **records** - E-Recording (12 modules)
- **vitals** - Vitals (13 modules)
- **ram** - RAM (5 modules)
- **reco** - ReCo (6 modules)

### Example/Template
- **sample-tenant** - Sample/Example tenant for testing

## File Naming Conventions

All files use lowercase-with-hyphens:

```
data/my-tenant.csv       ← CSV configuration
dispatch/my-tenant.bat   ← Batch dispatcher
```

The tenant key in `data/tenants.csv` must match these filenames (without extension).

## CSV Format Reference

### tenants.csv (Tenant Registry)
```csv
alias,display,root
tenant-key,DisplayName,C:/path/to/tenant/root
```

### {tenant-key}.csv (Module Definitions)
```csv
alias,name,label,type,client,server,home
module-alias,repo-name,DisplayLabel,type,client/path,server/path,branch
```

## Examples

### View a Tenant's Modules
```bash
cat data/vitals.csv
```

### Test a Dispatcher
```bash
vitals help
records admin help
```

### Verify Tenant Registration
```bash
cat data/tenants.csv
```

## Module Types

- **bff** - Backend-for-Frontend (web apps with UI + server)
- **api** - API services (server only)
- **lambda** - AWS Lambda or serverless functions
- **app** - Standalone applications (workers, processors)
- **extra** - Infrastructure (cloud stacks, configs)

## Need Help?

1. Check [QUICK_START.md](QUICK_START.md) for simple setup
2. Check [../TENANT_SETUP_GUIDE.md](../TENANT_SETUP_GUIDE.md) for detailed docs
3. Look at existing tenants (vitals, ecertify, etc.) for examples
4. Review templates in `data/TEMPLATE.csv` and `dispatch/TEMPLATE.bat`

## Advanced: Organization Dispatchers

You can create organization-level dispatchers that route to multiple tenants:

**Example: `dispatch/vanguard.bat`**
```batch
vanguard ecertify admin git status
vanguard vitals api npm test
vanguard records dashboard help
```

See `dispatch/vanguard.bat` for a complete example.

---

**Documentation Version:** 1.0
**Last Updated:** 2026-02-05
