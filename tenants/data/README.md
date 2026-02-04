# Tenant Data Format
## tenants.csv
- id: Tenant key
    - Required
- display: Display name
    - Required
- root: Root path excluding end-trailing / and current drive
    - Required
## [tenant].csv
- alias: Alias for your project (used for commands)
    - Required
- name: Name of both csproj and assembly, they must match
    - Required
- label: Display label
    - Required
- type: api, bff, or whatever you want
    - Required
- client: Root path of your client (must nest under root path)
    - If none, leave a whitespace " " character between the commas. See the sample-tenant for an example.
- server: Root path of your client (must nest under root path)
    - If none, leave a whitespace " " character between the commas. See the sample-tenant for an example.
- home: Source git branch (usually master or main)
    - Required
