# Tenant Setup Guide for LazyPolyRepoExpress

This guide will help you set up new tenants (projects/organizations) in LazyPolyRepoExpress by creating the necessary CSV configuration files and dispatch batch files.

## Overview

Setting up a tenant involves three main steps:
1. **Extract configuration data** from your existing config files
2. **Create tenant CSV files** with module information
3. **Create dispatch batch files** for command routing
4. **Register the tenant** in tenants.csv

---

## Step 1: Extract Configuration Data

### 1.1 Identify Your Source Configuration

Locate your existing configuration file that contains:
- Project/module names
- Repository paths
- Git branches
- Module aliases or keys

**Example source formats:**
- Static config files (`.config`, `.env`, `.properties`)
- JSON/YAML configuration files
- Build configuration files

### 1.2 Map Out Your Modules

For each module in your tenant, identify:

| Field | Description | Example |
|-------|-------------|---------|
| **alias** | Short, CLI-friendly identifier | `admin`, `api`, `public` |
| **name** | Repository/directory name | `eagle-vitals-admin` |
| **label** | Human-readable display name | `Admin`, `Api`, `Dashboard` |
| **type** | Service type (see below) | `bff`, `api`, `lambda` |
| **client** | Client/frontend directory path | `eagle-vitals-admin/client` |
| **server** | Server/backend directory path (where .sln lives) | `eagle-vitals-admin` |
| **home** | Default git branch | `master`, `main`, `develop` |

### 1.3 Module Types

Choose the appropriate type for each module:

- **`bff`** - Backend-for-Frontend (web apps with both client and server)
- **`api`** - API services (server only, no client)
- **`lambda`** - AWS Lambda functions or serverless functions
- **`app`** - Standalone applications (queue processors, workers, etc.)
- **`extra`** - Infrastructure, cloud stacks, or other special modules

---

## Step 2: Create Tenant CSV File

### 2.1 File Location

Create your tenant CSV file at:
```
tenants/data/{tenant-key}.csv
```

Example: `tenants/data/my-project.csv`

### 2.2 CSV Structure

```csv
alias,name,label,type,client,server,home
```

### 2.3 Fill In Module Data

**For BFF modules (with UI):**
```csv
admin,my-project-admin,Admin,bff,my-project-admin/client,my-project-admin,main
```

**For API modules (no UI):**
```csv
api,my-project-api,Api,api,,my-project-api,master
```

**For Lambda functions:**
```csv
lambda-upload,my-s3-upload-lambda,S3Upload,lambda,,my-s3-upload-lambda,main
```

### 2.4 Complete Example

**File: `tenants/data/my-project.csv`**
```csv
alias,name,label,type,client,server,home
public,my-project-web,PublicWeb,bff,my-project-web/client,my-project-web,main
admin,my-project-admin,Admin,bff,my-project-admin/client,my-project-admin,main
api,my-project-api,Api,api,,my-project-api,master
public-api,my-project-public-api,PublicApi,api,,my-project-public-api,main
lambda-processor,my-queue-processor-lambda,QueueProcessor,lambda,,my-queue-processor-lambda,main
cloud-stack,my-cloud-stack,CloudStack,extra,,my-cloud-stack,main
```

---

## Step 3: Create Dispatch Batch Files

### 3.1 Individual Tenant Dispatcher

Create a batch file for your tenant at:
```
tenants/dispatch/{tenant-key}.bat
```

**Template:**
```batch
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
:: The name of the App directory (/Tenant/...projects)
SET "Tenant={DisplayName}"
:: The name of the CSV key
SET "KEY={tenant-key}"
SET "module=%~1"
SET "action=%~2"
SET "arg1=%~3"
SET "arg2=%~4"
SET "arg3=%~5"
CALL fn-dispatch "%TENANT%" "%KEY%" "%module%" "%action%" "%arg1%" "%arg2%" "%arg3%"
IF ERRORLEVEL 1 EXIT /B 1
```

**Example: `tenants/dispatch/my-project.bat`**
```batch
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
:: The name of the App directory (/Tenant/...projects)
SET "Tenant=MyProject"
:: The name of the CSV key
SET "KEY=my-project"
SET "module=%~1"
SET "action=%~2"
SET "arg1=%~3"
SET "arg2=%~4"
SET "arg3=%~5"
CALL fn-dispatch "%TENANT%" "%KEY%" "%module%" "%action%" "%arg1%" "%arg2%" "%arg3%"
IF ERRORLEVEL 1 EXIT /B 1
```

### 3.2 Organization-Level Dispatcher (Optional)

If you have multiple related tenants, create an organization dispatcher:

**File: `tenants/dispatch/my-org.bat`**
```batch
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
SET "project=%~1"
SET "module=%~2"
SET "action=%~3"
SET "arg1=%~4"
SET "arg2=%~5"
IF "%project%"=="hello" (
    ECHO Hello, %USERNAME%. This is LazyPolyRepoExpress for MyOrg.
    ECHO   Usage: my-org ^<project^> ^<module^> ^<action^> ^<arg1^> ^<arg2^>
    ECHO   Projects: project-a, project-b, project-c ^(configured in tenants.csv^)
    ECHO   Modules: help, git, ai, app, ide, npm
    EXIT /B 0
)
IF /I "%project%"=="project-a" (
    CALL project-a "%module%" "%action%" "%arg1%" "%arg2%"
) ELSE IF /I "%project%"=="project-b" (
    CALL project-b "%module%" "%action%" "%arg1%" "%arg2%"
) ELSE IF /I "%project%"=="project-c" (
    CALL project-c "%module%" "%action%" "%arg1%" "%arg2%"
) ELSE (
    ECHO Unknown project: %project%
    ECHO Available projects: project-a, project-b, project-c
    EXIT /B 1
)
```

---

## Step 4: Register Tenant in tenants.csv

### 4.1 Edit tenants.csv

Open `tenants/data/tenants.csv` and add your tenant:

```csv
alias,display,root
my-project,MyProject,C:/path/to/my-project/root
```

### 4.2 Field Definitions

- **alias**: The tenant key (must match your CSV and BAT filenames)
- **display**: Human-readable display name
- **root**: Absolute path to the tenant's root directory containing all modules

### 4.3 Path Format Notes

- Use forward slashes `/` even on Windows
- Use absolute paths, not relative paths
- Do not include trailing slashes
- Example: `C:/dev/projects/my-project` ✓
- Example: `C:\dev\projects\my-project\` ✗

---

## Step 5: Verify Your Setup

### 5.1 Check File Structure

Ensure you have created:
```
tenants/
├── data/
│   ├── tenants.csv          (tenant registered here)
│   └── my-project.csv       (your module definitions)
└── dispatch/
    └── my-project.bat       (your dispatcher)
```

### 5.2 Test Your Configuration

```batch
# Test the dispatcher
my-project help

# Test with a specific module
my-project admin git status
```

---

## Common Patterns and Best Practices

### Naming Conventions

**Aliases:**
- Use lowercase with hyphens
- Keep them short and memorable
- Examples: `admin`, `api`, `public-api`, `lambda-upload`

**Labels:**
- Use PascalCase for display names
- Match your existing conventions
- Examples: `Admin`, `PublicApi`, `QueueProcessor`

**Directory Names:**
- Use your actual repository/folder names
- Include the full path from tenant root
- Client paths are relative to server path

### Client/Server Path Examples

**Nested client directory:**
```csv
admin,my-admin,Admin,bff,my-admin/client,my-admin,main
```
This assumes:
```
/MyProject/
  └── my-admin/
      ├── my-admin.sln        (server root)
      └── client/             (client code)
```

**No client directory (API only):**
```csv
api,my-api,Api,api,,my-api,master
```
This assumes:
```
/MyProject/
  └── my-api/
      └── my-api.sln          (server only)
```

### Git Branch Strategy

- Use `master` or `main` based on your repository default
- This represents the "home" branch for the module
- The system can work with other branches, this is just the default

---

## Example: Complete Setup Walkthrough

### Scenario
Setting up a new tenant called "HealthPortal" with 4 modules.

### Step 1: Extract Data

From our config, we identify:
- Admin portal (web app)
- Public portal (web app)
- Backend API
- Document processor (lambda)

### Step 2: Create CSV

**File: `tenants/data/health-portal.csv`**
```csv
alias,name,label,type,client,server,home
admin,health-admin,Admin,bff,health-admin/client,health-admin,main
public,health-public,Public,bff,health-public/client,health-public,main
api,health-api,Api,api,,health-api,master
lambda-docs,health-doc-processor,DocProcessor,lambda,,health-doc-processor,main
```

### Step 3: Create Dispatcher

**File: `tenants/dispatch/health-portal.bat`**
```batch
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
SET "Tenant=HealthPortal"
SET "KEY=health-portal"
SET "module=%~1"
SET "action=%~2"
SET "arg1=%~3"
SET "arg2=%~4"
SET "arg3=%~5"
CALL fn-dispatch "%TENANT%" "%KEY%" "%module%" "%action%" "%arg1%" "%arg2%" "%arg3%"
IF ERRORLEVEL 1 EXIT /B 1
```

### Step 4: Register Tenant

Add to `tenants/data/tenants.csv`:
```csv
health-portal,HealthPortal,C:/dev/health-portal
```

### Step 5: Test

```batch
health-portal admin git status
health-portal api npm install
health-portal lambda-docs help
```

---

## Troubleshooting

### Issue: "Cannot find module"
- Check that the module alias exists in your CSV
- Verify CSV has no typos in the header row
- Ensure CSV uses commas (not semicolons) as delimiter

### Issue: "Cannot find path"
- Verify the `root` path in tenants.csv is correct
- Check that server paths in module CSV are relative to root
- Ensure paths use forward slashes

### Issue: Dispatcher not found
- Check that the batch file is in `tenants/dispatch/`
- Verify filename matches the tenant key in tenants.csv
- Ensure the batch file has correct line endings (CRLF for Windows)

### Issue: "Wrong branch"
- Update the `home` column in your module CSV
- Verify your local repository is on the correct branch
- Check that the branch exists on remote

---

## Advanced: Automated Setup Script

Here's a prompt you can use with AI to automate tenant setup:

```
I need to set up a new tenant in LazyPolyRepoExpress. Please help me:

1. Extract configuration from: [path/to/your/config/file]
2. The tenant is called: [TenantName]
3. The tenant key is: [tenant-key]
4. The root directory is: [path/to/tenant/root]
5. Create the CSV file at: tenants/data/[tenant-key].csv
6. Create the dispatcher at: tenants/dispatch/[tenant-key].bat
7. Update tenants/data/tenants.csv to register the tenant

For each module, identify:
- Repository name (from the config)
- Alias (short CLI name)
- Label (display name)
- Type (bff, api, lambda, app, or extra)
- Client directory (if it has a UI)
- Server directory (where .sln or main code lives)
- Git branch (master or main)

Please analyze the configuration and create all necessary files.
```

---

## Reference: Vanguard Example

The Vanguard setup is a complete example you can reference:

**Tenants configured:**
- `ecertify` - E-Certify tenant (6 modules)
- `records` - E-Recording tenant (12 modules)
- `vitals` - Vitals tenant (13 modules)
- `ram` - RAM tenant (5 modules)
- `reco` - ReCo tenant (6 modules)

**Files to review:**
- CSV definitions: `tenants/data/{ecertify,records,vitals,ram,reco}.csv`
- Individual dispatchers: `tenants/dispatch/{ecertify,records,vitals,ram,reco}.bat`
- Organization dispatcher: `tenants/dispatch/vanguard.bat`
- Tenant registry: `tenants/data/tenants.csv`

---

## Need Help?

If you run into issues:
1. Review the example Vanguard configuration files
2. Check the troubleshooting section above
3. Verify your CSV syntax (use a CSV validator)
4. Test with the sample-tenant to ensure the system works
5. Create an issue in the repository with your configuration

---

**Last Updated:** 2026-02-05
**Version:** 1.0
