# Organizations
Running organization commands will run all suites for the organization. This is useful for running all suites for a given organization.

## Schema

`OrganizationCommandIdentifier: string`: The command alias and identifier for the organization.

`OrganizationFriendlyIdentifier: string`: The friendly identifier of the organization. File and directory names will use this.

`OrganizationFriendlyName: string`: The friendly name of the organization.

`OrganizationDescription: string | NULL`: A brief description of the organization.
- Optional

`OrganizationRootPath: string | NULL`: The root path of the organization's codebase.
- Optional
- Use relative paths in organization configs.

## List
Considera

Vanguard