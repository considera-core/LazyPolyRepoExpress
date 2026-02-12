# LazyPolyRepoExpress Cheat Sheet

Quick reference for common tasks and configurations.

## Setup a New Tenant (3 Steps)

### 1. Create CSV: `tenants/data/my-tenant.csv`
```csv
alias,name,label,type,client,server,home
admin,my-admin,Admin,bff,my-admin/client,my-admin,main
api,my-api,Api,api,,my-api,master
```

### 2. Create Dispatcher: `tenants/dispatch/my-tenant.bat`
```batch
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
SET "Tenant=MyTenant"
SET "KEY=my-tenant"
SET "module=%~1"
SET "action=%~2"
SET "arg1=%~3"
SET "arg2=%~4"
SET "arg3=%~5"
CALL fn-dispatch "%TENANT%" "%KEY%" "%module%" "%action%" "%arg1%" "%arg2%" "%arg3%"
IF ERRORLEVEL 1 EXIT /B 1
```

### 3. Register: Add to `tenants/data/tenants.csv`
```csv
my-tenant,MyTenant,C:/path/to/tenant
```

---

## CSV Field Reference

| Field | Required | Description | Example |
|-------|----------|-------------|---------|
| **alias** | Yes | CLI identifier | `admin`, `api`, `lambda-upload` |
| **name** | Yes | Directory name | `my-project-admin` |
| **label** | Yes | Display name | `Admin`, `PublicApi` |
| **type** | Yes | Module type | `bff`, `api`, `lambda`, `app`, `extra` |
| **client** | No | Client path | `my-admin/client` (or empty) |
| **server** | Yes | Server path | `my-admin` |
| **home** | Yes | Git branch | `master`, `main`, `develop` |

---

## Module Types

| Type | Description | Has Client? | Has Server? | Example |
|------|-------------|-------------|-------------|---------|
| **bff** | Web app (UI + API) | ✓ | ✓ | Admin portals, dashboards |
| **api** | API service | ✗ | ✓ | REST APIs, GraphQL |
| **lambda** | Serverless function | ✗ | ✓ | AWS Lambda, Azure Functions |
| **app** | Standalone app | ✗ | ✓ | Queue processors, workers |
| **extra** | Infrastructure | ✗ | ✓ | Cloud stacks, configs |

---

## Common Patterns

### BFF (Backend-for-Frontend)
```csv
admin,my-admin,Admin,bff,my-admin/client,my-admin,main
```
Assumes:
```
/my-admin/
  ├── my-admin.sln    (server)
  └── client/         (UI code)
```

### API (No Client)
```csv
api,my-api,Api,api,,my-api,master
```
Assumes:
```
/my-api/
  └── my-api.sln      (server only)
```

### Lambda Function
```csv
lambda-upload,s3-upload-lambda,S3Upload,lambda,,s3-upload-lambda,main
```

---

## Command Format

```batch
{tenant} {module} {command} [args]
```

### Examples
```batch
# Git commands
vitals admin git status
vitals admin git pull origin main

# NPM commands
ecertify api npm install
ecertify api npm run build

# Custom commands
records dashboard help
ram public app start
```

---

## File Locations Quick Reference

```
tenants/
├── data/
│   ├── tenants.csv              ← Tenant registry (add your tenant here)
│   └── {tenant-key}.csv         ← Module definitions (one per tenant)
└── dispatch/
    └── {tenant-key}.bat         ← Dispatcher (one per tenant)
```

**Key rule:** The `{tenant-key}` must be the same in all three places:
- Filename of CSV: `my-tenant.csv`
- Filename of BAT: `my-tenant.bat`
- First column in `tenants.csv`: `my-tenant`

---

## Path Rules

### In `tenants.csv`
```csv
my-tenant,MyTenant,C:/absolute/path/to/tenant
```
- Use **absolute paths**
- Use **forward slashes** `/` (even on Windows)
- **No trailing slash**

### In module CSV files
```csv
alias,name,label,type,client,server,home
admin,my-admin,Admin,bff,my-admin/client,my-admin,main
```
- Use **relative paths** (relative to tenant root)
- Use **forward slashes** `/`
- Client path is relative to server path

---

## Naming Conventions

### Aliases (CLI names)
- **lowercase-with-hyphens**
- Keep short and memorable
- ✓ Good: `admin`, `api`, `lambda-upload`
- ✗ Bad: `AdminPortal`, `api_service`, `Lambda_Upload_S3`

### Labels (Display names)
- **PascalCase**
- Human-readable
- ✓ Good: `Admin`, `PublicApi`, `QueueProcessor`
- ✗ Bad: `admin`, `public-api`, `queue_processor`

### Tenant Keys
- **lowercase-with-hyphens**
- Match CSV/BAT filenames
- ✓ Good: `my-project`, `health-portal`
- ✗ Bad: `MyProject`, `health_portal`

---

## Troubleshooting One-Liners

```batch
# Verify tenant is registered
type tenants\data\tenants.csv | findstr my-tenant

# Check module CSV exists and is valid
type tenants\data\my-tenant.csv

# Test dispatcher exists
where my-tenant

# Verify paths in CSV
# Paths should be relative, use forward slashes

# Test dispatcher works
my-tenant help
```

---

## Common Errors

### "Cannot find module"
- ✓ Check module alias exists in CSV
- ✓ Check CSV header is correct
- ✓ Verify no typos in alias

### "Cannot find path"
- ✓ Check `tenants.csv` has correct root path
- ✓ Verify paths use forward slashes `/`
- ✓ Ensure server path is relative to root

### "Command not recognized"
- ✓ Batch file must be in `tenants/dispatch/`
- ✓ Filename must match tenant key
- ✓ May need to restart terminal

---

## Copy-Paste Templates

### Empty Module CSV
```csv
alias,name,label,type,client,server,home
```

### BFF Module Row
```csv
admin,my-admin,Admin,bff,my-admin/client,my-admin,main
```

### API Module Row
```csv
api,my-api,Api,api,,my-api,master
```

### Lambda Module Row
```csv
lambda-func,my-lambda,MyLambda,lambda,,my-lambda,main
```

### Tenant Registry Row
```csv
my-tenant,MyTenant,C:/dev/projects/my-tenant
```

---

## AI Setup Prompt

```
Set up LazyPolyRepoExpress tenant:

Name: [TenantName]
Key: [tenant-key]
Root: [C:/path/to/root]

Modules:
- [module-name] (type: bff/api/lambda/app/extra)
- [module-name] (type: bff/api/lambda/app/extra)

Create:
1. tenants/data/[key].csv
2. tenants/dispatch/[key].bat
3. Entry in tenants/data/tenants.csv
```

---

## Quick Navigation

| Need to... | Go to... |
|------------|----------|
| Add a tenant (quick) | [QUICK_START.md](tenants/QUICK_START.md) |
| Add a tenant (detailed) | [TENANT_SETUP_GUIDE.md](TENANT_SETUP_GUIDE.md) |
| Understand structure | [tenants/README.md](tenants/README.md) |
| See examples | Look at Vanguard tenants in `tenants/data/` |
| Use templates | Copy `tenants/data/TEMPLATE.csv` and `tenants/dispatch/TEMPLATE.bat` |

---

**Print this page for quick reference while setting up tenants!**
