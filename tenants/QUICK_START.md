# Quick Start: Add a New Tenant

Follow these 4 simple steps to add a new tenant to LazyPolyRepoExpress.

## 1. Copy Templates

```batch
cd tenants

# Copy the CSV template
copy data\TEMPLATE.csv data\my-tenant.csv

# Copy the batch template
copy dispatch\TEMPLATE.bat dispatch\my-tenant.bat
```

## 2. Edit `data/my-tenant.csv`

Replace example entries with your actual modules:

```csv
alias,name,label,type,client,server,home
admin,my-admin,Admin,bff,my-admin/client,my-admin,main
api,my-api,Api,api,,my-api,master
```

**Quick Reference:**
- **alias**: CLI name (lowercase-with-hyphens)
- **name**: Actual directory/repo name
- **label**: Display name (PascalCase)
- **type**: `bff` (web app), `api` (API only), `lambda` (function), `app` (worker), `extra` (other)
- **client**: Path to client code (or empty for APIs)
- **server**: Path to server code (where .sln lives)
- **home**: Git branch (`master` or `main`)

## 3. Edit `dispatch/my-tenant.bat`

Update these two lines:

```batch
SET "Tenant=MyTenantName"
SET "KEY=my-tenant"
```

- **Tenant**: Display name (PascalCase)
- **KEY**: Must match your CSV filename (my-tenant.csv → my-tenant)

## 4. Register in `data/tenants.csv`

Add a line:

```csv
my-tenant,MyTenantName,C:/path/to/my/tenant/root
```

- Column 1: Tenant key (matches CSV/BAT filenames)
- Column 2: Display name
- Column 3: Absolute path to tenant root (use forward slashes `/`)

## Done! Test it:

```batch
my-tenant help
my-tenant admin git status
```

---

## Real-World Example

Here's how the Vanguard "Vitals" tenant was set up:

### Step 1: Created `data/vitals.csv`
```csv
alias,name,label,type,client,server,home
citizen,eagle-vitals,Vitals,bff,eagle-vitals/client,eagle-vitals,master
admin,eagle-vitals-admin,Admin,bff,eagle-vitals-admin/client,eagle-vitals-admin,master
api,eagle-vitals-api,Api,api,,eagle-vitals-api,master
```

### Step 2: Created `dispatch/vitals.bat`
```batch
SET "Tenant=Vitals"
SET "KEY=vitals"
```

### Step 3: Added to `data/tenants.csv`
```csv
vitals,Vitals,C:/tylerdev/Vanguard/Vitals
```

### Step 4: Tested
```batch
vitals citizen git status
vitals admin npm install
```

---

## Need More Details?

See [TENANT_SETUP_GUIDE.md](../TENANT_SETUP_GUIDE.md) for the complete documentation.

## AI Prompt for Automation

Copy and use this prompt with your AI assistant:

```
Set up a new tenant in LazyPolyRepoExpress with these details:

Tenant Name: [Your Tenant Name]
Tenant Key: [your-tenant-key]
Root Path: [C:/path/to/tenant]

Modules:
1. [Module 1 name] - type: [bff/api/lambda/app/extra]
2. [Module 2 name] - type: [bff/api/lambda/app/extra]
3. [Module 3 name] - type: [bff/api/lambda/app/extra]

Please:
1. Create tenants/data/[tenant-key].csv with all modules
2. Create tenants/dispatch/[tenant-key].bat
3. Add entry to tenants/data/tenants.csv

For each module, use the actual directory name from my project,
determine appropriate aliases, and set client/server paths correctly.
```
