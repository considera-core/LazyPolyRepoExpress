# Projects

An individual codebase that can be run and tested. Projects are grouped into suites, which are grouped into organizations.

## Schema

`ProjectIdentifier: string`: The command option and identifier for the project.

`ProjectFriendlyIdentifier: string`: The friendly identifier of the project. File and directory names will use this.

`ProjectFrameworkIdentifier: string`: The framework identifier for the project. This is used to determine which framework command to use when running the project.

`ProjectFriendlyName: string`: The friendly name of the project.

`ProjectType: string`: The type of project. This is used to determine which framework command to use when running the project.

`ProjectDescription: string`: A brief description of the project.
- Optional (use `NULL`)

`ProjectRootPath: string`: The root path of the project's codebase.

`IsExternal: boolean`: Whether the project is external to Leprechaun. They will be treated as a separate module with their own set of commands.
