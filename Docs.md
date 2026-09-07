# Schema
```c
# Internal
## All Projects
leprechaun ORG SUITE MODULE ACTION ARGS... FLAGS...
ORG SUITE MODULE ACTION ARGS... FLAGS...
SUITE MODULE ACTION ARGS... FLAGS...

## 1+ Projects
leprechaun ORG SUITE MODULE ACTION ARGS...  -p PROJECTS... FLAGS...
ORG SUITE MODULE ACTION ARGS...  -p PROJECTS... FLAGS...
SUITE MODULE ACTION ARGS...  -p PROJECTS... FLAGS...

## 1 Project
leprechaun ORG SUITE PROJECT MODULE ACTION ARGS... FLAGS...
ORG SUITE PROJECT MODULE ACTION ARGS... FLAGS...
SUITE PROJECT MODULE ACTION ARGS... FLAGS...

## All Suites
leprechaun ORG MODULE ACTION ARGS... FLAGS...
ORG MODULE ACTION ARGS... FLAGS...

## All Organizations
leprechaun MODULE ACTION ARGS... FLAGS...

# External
## 1 Project
leprechaun ORG SUITE PROJECT COMMAND
ORG SUITE PROJECT COMMAND
SUITE PROJECT COMMAND

## All Suites
leprechaun ORG COMMAND
ORG COMMAND
```
## Examples
### External example
consideraweb proxy start -v
### Internal examples
leprechaun considera consideraweb api app launch -v
leprechaun considera consideraweb app launch -p api bff -v
consideraweb app launch -p api bff -v
consideraweb app run -a web -v
considera consideraweb app launch -p api bff -v
considera git branch -v
considera consideraweb git refresh-dependabot
consideraweb api test run -v
leprechaun leprechaun git home

# Resolution
How a command line becomes an `(ORG, SUITE, PROJECT, MODULE, ACTION)` tuple.

## Step 1: find MODULE
Scan the positional arguments left to right for the first token that is a known
module identifier, read from `Data/Modules.csv`. That token is MODULE, the next
one is ACTION, and every positional after it is an ARG.

If no positional is a known module, the invocation is External and goes to
`FnEtcDispatchExternal` instead.

MODULE is the pivot rather than the first argument because it is the only
position drawn from a closed, data-defined set, so it can be located without
knowing how many optional tokens precede it.

## Step 2: read the prefix by length
Everything before MODULE is the prefix. Its meaning comes from its length plus
the depth of the entry point it was typed at, so no name lookup is needed to
tell an ORG from a SUITE:

| prefix | `leprechaun` (global) | org script    | suite script  |
|--------|-----------------------|---------------|---------------|
| 0      | all organizations     | all suites    | all projects  |
| 1      | ORG                   | SUITE         | PROJECT       |
| 2      | ORG SUITE             | SUITE PROJECT | error         |
| 3      | ORG SUITE PROJECT     | error         | error         |

A prefix longer than the entry depth allows is rejected rather than guessed at.

## Step 3: validate, then fan out
Any ORG, SUITE or PROJECT named explicitly must exist; unknown names are
rejected before anything is dispatched. An absent ORG or SUITE means fan out
over all of them. Suites whose `Active` column is not `true` are skipped.

## Constraints this relies on
Enforced by the `schema` test group, not by convention:
- Suite command identifiers are unique across all organizations. This is what
  lets the Function Schema take SUITE without an accompanying ORG.
- No project identifier collides with an action name of any module, because a
  leaf function reads its second positional as PROJECT when it names a project.
- `OrganizationFriendlyIdentifier` and `SuiteFriendlyIdentifier` are the on-disk
  directory names, so each must have a directory.
- Every active suite has a `Projects.csv`. An inactive suite may be declared
  before it is scaffolded.

# Flags
| Flag | Long | Kind | Meaning |
|------|------|------|---------|
| `-p` | `--projects` | list | Projects to act on. 1+ values. |
| `-a` | `--args` | list | ARGS, as an alternative to trailing positionals. 1+ values. |
| `-o` | `--org` | value | Organization, for scripts called directly. |
| `-s` | `--suite` | value | Suite, for scripts called directly. |
| `-v` | `--verbose` | boolean | Verbose output. |
| `-d` | `--dry-run` | boolean | Test mode: report the resolution, do not execute. |

**List flags** consume every following token until the next flag or the end of
the line, so `-p api bff -v` is two projects and then a flag. **Value flags**
consume exactly one token. Everything else is boolean and is forwarded onward
untouched, so a flag added at the entry point reaches the leaf function.

Short flags are canonicalized to their long name, so callers only ever read
`FLAG_PROJECTS`, never `FLAG_P`. Dashes in flag names become underscores:
`--dry-run` sets `FLAG_DRY_RUN`.

## Dry run contract
Under `-d` each layer reports what it resolved instead of executing it. The
output is stable and is what the test suite asserts against:

```c
LPRE:RESOLVE org=<org> suite=<suite> project=<project> module=<module> action=<action> args=<args> projects=<projects> flags=<flags>
LPRE:EXEC fn=<Fn> suite=<suite> project=<project> args=<args> projects=<projects> flags=<flags>
LPRE:EXTERNAL suite=<suite> project=<project> command=<command> args=<args> flags=<flags>
LPRE:RUN fn=<Fn> suite=<suite> project=<project> path=<path> ... flags=<flags>
```

`Fn<Module>Dispatch` calls the leaf under `-d` too, passing `-d` through, so a dry
run previews the real fan out: one `LPRE:RUN` per project the command would touch.
`LPRE:EXEC` appears only when the leaf does not exist yet, which is what keeps the
grammar testable ahead of the leaves being written.

Leaves report before checking that the project directory exists, so a dry run
works on a machine where the suite is not checked out.

Validation still runs under `-d`, so an unknown module, action, suite or project
fails in test mode exactly as it would for real.

# Function Schema
```c
# Internal
## All Projects
### FnEtcForEachProject => Fn(PROJECT, MODULE, ACTION)
FN = FN(MODULE, ACTION) SUITE ARGS... FLAGS...

## Select projects
### FOR => Fn(PROJECT, MODULE, ACTION)
FN = FN(MODULE, ACTION) SUITE ARGS... -p PROJECTS... FLAGS...

## Single project
### Fn(PROJECT, MODULE, ACTION)
FN = Fn(PROJECT, MODULE, ACTION) = FN(MODULE, ACTION) SUITE PROJECT ARGS... FLAGS...
```

All three forms are the same script. A leaf function called without a single
project recurses on itself until it reaches the single project base case, which
is the only form that does work:

```c
IF a PROJECT was given          -> do the work
ELSE IF -p PROJECTS was given   -> FOR each, call self with that one project
ELSE                            -> FnEtcForEachProject SUITE <self> ARGS... FLAGS...
```

The second positional is a PROJECT when it names a project in the suite, and the
first ARG otherwise. The `action-collisions` schema test keeps that distinction
unambiguous.

## Translation
```c
# Organization invocation
ORG SUITE MODULE ACTION ARGS... -p PROJECTS... FLAGS...
=>
FN(MODULE, ACTION) SUITE ARGS... -p PROJECTS... FLAGS...

ORG MODULE ACTION ARGS... FLAGS...
=>
FnEtcForEachSuite ORG FN(MODULE, ACTION) ARGS... FLAGS...
=>
[FN(MODULE, ACTION) SUITE ARGS... FLAGS...]

# Suite invocation
SUITE MODULE ACTION ARGS... -p PROJECTS... FLAGS...
=>
FN(MODULE, ACTION) SUITE ARGS... -p PROJECTS... FLAGS...

SUITE MODULE ACTION ARGS... FLAGS...
=>
FN(MODULE, ACTION) SUITE ARGS... FLAGS...
=>
FnEtcForEachProject SUITE FN(MODULE, ACTION) ARGS... FLAGS...   // inside FN
=>
[FN(MODULE, ACTION) SUITE PROJECT ARGS... FLAGS...]
```

Note the last expansion: the fan out over projects happens *inside* FN, not at
dispatch time. Dispatch always calls FN once; FN decides whether it is the base
case.

## Examples
```c
considera consideraweb app launch -p api bff -v
=>
FnAppLaunch consideraweb -p api bff -v

consideraweb git home -v -d
=>
FnGitHome consideraweb -v -d // In FnGitDispatch
=>
FnEtcForEachProject consideraweb FnGitHome -v -d // In FnGitHome
=>
[Projects PROJECT: FnGitHome consideraweb PROJECT -v -d] // Eval In FnEtcForEachProject
```

## Naming
`FN(MODULE, ACTION)` is `Fn` + the module in PascalCase + the action in
PascalCase, with hyphens removed: module `git` and action `refresh-dependabot`
give `FnGitRefreshDependabot`. Each `Fn<Module>Dispatch` declares the mapping
explicitly as `<action>:<FunctionSuffix>` pairs, so the action list and the
resolved name never drift apart.

# Layers
```c
<entry script>             leprechaun | <org> | <suite>
  FnEtcDispatch            applies the grammar, validates, fans out
    FnEtcDispatchInternal  validates MODULE
      Fn<Module>Dispatch   validates ACTION, resolves FN
        Fn<Module><Action> the leaf, recursing to one project
    FnEtcDispatchExternal  when no positional is a module
      Fn<Project>Dispatch  an external project's own commands
```

Entry scripts are shims that pass their depth to `FnEtcDispatch`. The Etc
plumbing passes state by flag, which is unambiguous; only the leaf functions use
the positional Function Schema.

# Entry Points
| Command | Depth | Supplies |
|---------|-------|----------|
| `leprechaun` | global | nothing |
| `considera` | org | `--org considera` |
| `vanguard` | org | `--org vanguard` |
| `consideraweb` | suite | `--org considera --suite consideraweb` |

Adding an organization or suite means adding one shim in `Dispatch/`.

## Bin
`Bin/` is the whole command surface: one generated forwarder per script in
`Dispatch/` and `Modules/`, named by the script's base name. Put `Bin` on PATH
and everything resolves by name from anywhere.

```c
FnExternalBootstrapShortcuts            // regenerate after adding a script
FnExternalBootstrapShortcuts --clean    // remove generated forwarders
```

Forwarders are `.bat` rather than `.lnk` because `PATHEXT` never contains
`.LNK`, and they `CALL` the real path so `%~dp0` inside a script still names its
own module directory. They do not `SETLOCAL`, so readers that export `LPRE_*`
into their caller keep working across the hop. Only files carrying the
`LPRE-GENERATED-SHIM` marker are ever rewritten or removed.

# Modules Schema
Every module exposes `Fn<Module>Dispatch`, which validates the action and calls
the leaf. Leaf signatures are the Function Schema above:
`FN SUITE PROJECT ARGS... FLAGS...` and its two fan out forms.

## Etc
Plumbing. Not a dispatchable module; these are called by name.

### Command line
| Function | Signature |
|---|---|
| `FnEtcFlags` | `FnEtcFlags ARGS...` — parses a command line into `FLAG_*` |
| `FnEtcFlagsPick` | `FnEtcFlagsPick <SHORT> <LONG>` — copies `FLAG_<SHORT>` into `FLAG_<LONG>` |

### Dispatch
| Function | Signature |
|---|---|
| `FnEtcDispatch` | `FnEtcDispatch --entry <global\|org\|suite> [--org ORG] [--suite SUITE] COMMAND...` |
| `FnEtcDispatchInternal` | `FnEtcDispatchInternal --suite S --module M --action A [--project P] [-p PROJECTS...] [-a ARGS...] FLAGS...` |
| `FnEtcDispatchExternal` | `FnEtcDispatchExternal --entry <depth> [--org ORG] [--suite SUITE] COMMAND...` |

### Iteration
| Function | Signature |
|---|---|
| `FnEtcForEachSuite` | `FnEtcForEachSuite ORG FN ARGS... -p PROJECTS... FLAGS...` |
| `FnEtcForEachProject` | `FnEtcForEachProject SUITE FN ARGS... FLAGS...` |

```c
# Dispatch
FnEtcForEachSuite ORG FN ARGS... -p PROJECTS... FLAGS...

# Dispatch (Debug)
FnEtcForEachSuite ORG FN ARGS... -p PROJECTS... FLAGS... -v

# Test
FnEtcForEachSuite ORG FN ARGS... -p PROJECTS... FLAGS... -d

# Test (Debug)
FnEtcForEachSuite ORG FN ARGS... -p PROJECTS... FLAGS... -v -d
```

### Data
Readers own all CSV parsing. They export `LPRE_*` into the caller's scope and
deliberately do not `SETLOCAL`, since cmd runs an implicit `ENDLOCAL` on return
and would discard exactly what they exist to produce.

| Function | Signature | Exports |
|---|---|---|
| `FnEtcEnvGetDataPath` | `FnEtcEnvGetDataPath` | `Output_Env_DataPath` |
| `FnEtcEnvGetRootRepoPath` | `FnEtcEnvGetRootRepoPath` | `Output_Env_RootRepoPath` |
| `FnEtcCsvModules` | `FnEtcCsvModules` | `LPRE_MODULES` |
| `FnEtcCsvOrgs` | `FnEtcCsvOrgs` | `Output_Data_Orgs`, `GLOBAL_ORG_<id>_*` |
| `FnEtcCsvSuites` | `FnEtcCsvSuites ORG` | `LPRE_SUITES`, `LPRE_SUITES_ACTIVE`, `GLOBAL_SUITE_<id>_*` |
| `FnEtcCsvProjects` | `FnEtcCsvProjects ORG SUITE` | `GLOBAL_PROJECTS`, `GLOBAL_PROJECTS_INTERNAL`, `GLOBAL_PROJECTS_EXTERNAL`, `GLOBAL_PROJECT_<id>_*` |
| `FnEtcResolveSuite` | `FnEtcResolveSuite SUITE` | `Output_Resolved_SuiteOrgId`, `Output_Resolved_SuiteDataPath` |
| `FnEtcResolveProjectPath` | `FnEtcResolveProjectPath SUITE PROJECT` | `Output_Resolved_ProjectPath`, `Output_Resolved_ProjectLabel` |

A CSV holding only its header is a declared but empty collection, which is
valid. A missing CSV is an error.

`FnEtcResolveProjectPath` joins `SuiteRootPath` with the project's relative
`ProjectRootPath` and the drive the CLI lives on. It does not check that the
result exists, so dry runs work anywhere; callers doing real work check.

### Cache
Caches the whole tree into the environment as `ORGANIZATIONS_*`. Built on the
readers above; the dispatch chain queries the readers directly and does not need
this cache to be warm.

| Function | Signature |
|---|---|
| `FnEtcBootstrapOrganizations` | `FnEtcBootstrapOrganizations FLAGS...` |
| `FnEtcBootstrapSuites` | `FnEtcBootstrapSuites -o ORG -i ORG_ID FLAGS...` |
| `FnEtcBootstrapProjects` | `FnEtcBootstrapProjects --org ORG --org-id ID --suite SUITE --suite-id ID` |
| `FnEtcSelectOrganization` | `FnEtcSelectOrganization -o ORG` |

## Ai
`claude:Claude`

| Action | Function |
|---|---|
| `claude` | `FnAiClaude SUITE PROJECT ARGS... FLAGS...` |

`FnAiClaude` opens Claude Code in a project with ARGS as the initial prompt.
`--here` runs in the current window; otherwise each project gets its own Windows
Terminal tab, so a fan out over a suite does not serialise behind one
interactive session.

It is the **reference leaf**: converting the remaining leaves means following
its four steps.

```c
1. parse with FnEtcFlags
2. split SUITE / PROJECT / ARGS, using the suite's project list to decide
   whether positional 2 is a PROJECT or the first ARG
3. pick one of the three forms:
     PROJECT set        -> base case
     -p PROJECTS set    -> FOR each, call self with that one project
     neither            -> FnEtcForEachProject SUITE <self> ARGS... FLAGS...
4. do the work in the base case only, after FnEtcResolveProjectPath
```

Recursion passes ARGS back as `-a`, which keeps the positional 2 question from
arising on the way down.

## App
`run:Run launch:Launch validate:Validate list:List`

| Action | Function |
|---|---|
| `run` | `FnAppRun SUITE PROJECT ARGS... FLAGS...` — run an app from `Apps.csv` |
| `launch` | `FnAppLaunch SUITE PROJECT ARGS... FLAGS...` |
| `validate` | `FnAppValidate SUITE PROJECT ARGS... FLAGS...` |
| `list` | `FnAppList SUITE ARGS... FLAGS...` — list `Apps.csv` |

## Aws
`login:Login whoami:Whoami env:Env`

## Db
`migrate:Migrate seed:Seed reset:Reset`

## Git
`branch:Branch branches:Branches pull:Pull home:Home story:Story refresh-dependabot:RefreshDependabot`

| Action | Function |
|---|---|
| `branch` | `FnGitBranch SUITE PROJECT FLAGS...` |
| `branches` | `FnGitBranches SUITE PROJECT FLAGS...` |
| `pull` | `FnGitPull SUITE PROJECT FLAGS...` |
| `home` | `FnGitHome SUITE PROJECT FLAGS...` |
| `story` | `FnGitStory SUITE PROJECT STORY_ID FLAGS...` |
| `refresh-dependabot` | `FnGitRefreshDependabot SUITE PROJECT FLAGS...` |

## Ide
`code:Code jetbrains:Jetbrains rider:Rider webstorm:Webstorm`

## Npm
`install:Install run:Run build:Build test:Test`

## Npx
`run:Run`

## Nuget
`restore:Restore pack:Pack push:Push`

## Terraform
`init:Init plan:Plan apply:Apply`

## Unity
`open:Open build:Build`

## Utility
`tree:Tree path:Path list:List`

## Test
`list:List run:Run`

Validates the CLI against this document.

| Action | Function |
|---|---|
| `list` | `FnTestList SUITE [GROUPS...]` — list groups and case names |
| `run` | `FnTestRun SUITE [NAMES...]` — run all, or the named groups and cases |

`FnTestAssert CHECK` backs the `schema` group and checks the data invariants
listed under Resolution.

```c
consideraweb test list
consideraweb test run                    // all
consideraweb test run grammar flags      // 1+ groups
consideraweb test run fn-name-casing     // 1+ individual cases
```

Cases live in `Modules/Internal/Test/Cases/*.cases`, one per line, pipe
delimited because inputs contain commas and quotes:

```c
NAME|INPUT|RC|EXPECT
```

`INPUT` is run as typed, `RC` is the exit code it must produce, and `EXPECT` is
a substring its output must contain. An `EXPECT` starting with `!` asserts the
substring is **absent**, which is how a case proves something was skipped rather
than merely not looked for. Most cases end in `-d` and assert against the dry
run contract.

| Group | Covers |
|---|---|
| `grammar` | every example in this document |
| `prefix` | prefix length against entry depth, including over-long prefixes |
| `flags` | list flags, long forms, ordering, passthrough |
| `fanout` | all organizations, all suites, all projects, `-p` subsets, base case |
| `external` | External dispatch, and rejecting it for internal projects |
| `negative` | unknown module, action, suite, project; missing action; bad flags |
| `schema` | the data invariants under Resolution |
| `ai` | the reference leaf: base case, both fan out forms, prompt carriage |

`FnTestRun` refuses to re-enter itself. One grammar case is `test run`, and
since a dispatcher calls the leaf even under `-d`, without that guard the suite
would run itself recursively.

# Conventions
- Messages are `LeprechaunCLI:<Fn>[<L>]: <text>` where `L` is `E` error, `I`
  info or `D` debug.
- **Every leaf must honour `-d`.** Dispatchers call the leaf under `-d` so the
  preview is real, which means a leaf that ignores the flag will execute during
  a dry run. Report before touching anything.
- Scripts that export variables do not `SETLOCAL`; scripts that do work do.
- The CSV readers memoize: a reload is skipped when the same data is already in
  scope. Children inherit a warm cache but their own loads never leak back up.
  Pass `--refresh` to force a reread.
- Delayed expansion stays off through the dispatch chain, so a `!` inside an
  argument survives to the leaf.
- `EXIT /B %ERRORLEVEL%` is never written inside a parenthesised block, where it
  would expand before the call it is meant to report.
- Batch files are stored CRLF. cmd cannot resolve `GOTO`/`CALL` labels in a
  LF-only file, so `.gitattributes` pins `*.bat` to `eol=crlf`.
