:: ==========================================
:: fn-git-story <tenant> <project> <story-id>
:: ==========================================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
SET "storyId=%~3"

IF NOT DEFINED project (
    ECHO [ERROR] Missing project or story identifier
    EXIT /B 1
)

:: TWO SCENARIOS
:: 1. fn-git-story <tenant> <project> <story-id>
:: 2. fn-git-story <tenant> <story-id>
:: fn-foreach <tenant> <function> <...args>
::   => fn-git-story <tenant> <project> <storyId>
IF NOT DEFINED storyId (
    CALL fn-findProjectByAlias "%project%"
    IF NOT ERRORLEVEL 1 (
        ECHO [ERROR] Missing story identifier, got project "%project%" instead
        EXIT /B 1
    )
    CALL fn-foreach "%tenant%" "fn-git-story" "%project%"
    EXIT /B 0
)

CALL fn-findProjectByAlias "%storyId%"
IF NOT ERRORLEVEL 1 (
    ECHO [ERROR] Missing story identifier, got project "%storyId%" instead
    EXIT /B 1
)

CALL :FN
EXIT /B 0

:FN
    ECHO [VANGUARD GIT STORY: %tenant%/%project%/%storyId%]
    CALL fn-git "%tenant%" "%project%" "switch %storyId% >> NUL || git switch -c %storyId%"
    EXIT /B 0