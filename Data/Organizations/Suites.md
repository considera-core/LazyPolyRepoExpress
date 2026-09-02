# Suites

Running suite commands will run all projects for the suite. This is useful for running all projects for a given suite.

## Schema

`SuiteCommandIdentifier: string`: The command alias and identifier for the suite.

`SuiteFriendlyIdentifier: string`: The friendly identifier of the suite. File and directory names will use this.

`SuiteFriendlyName: string`: The friendly name of the suite.

`SuiteDescription: string | NULL`: A brief description of the suite.
- Optional

`SuiteRootPath: string | NULL`: The root path of the suite's codebase.
- Optional
- Use relative paths in project configs.

###### Todo
- SuitePostLaunchCommand
- SuitePostRunCommand