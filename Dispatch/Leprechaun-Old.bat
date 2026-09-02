:: leprechaun exec <ORG> <SUITE> <MODULE> <ACTION> <ARGS...> <FLAGS...>
:: leprechaun function <VERB> <ARGS...>
:: leprechaun edit
:: -- Global entry point, and the router for the "function" namespace.
:: --
:: -- Two jobs in one file because both have to answer to the name "leprechaun".
:: -- The entry point applies the Docs.md grammar; the router resolves a verb to
:: -- the function that implements it:
:: --
:: --   flags | dispatch | dispatch-internal | dispatch-external   fixed target
:: --   env | data | resolve | log | for <Name>                    prefix + Name
:: --   Global | Organization | Suite | Project <...>              FnEtcDispatch
:: --   <module> <action> <...>                                    Fn<Module><Action>
:: --
:: -- Module identifiers are checked against the router verbs by the schema test,
:: -- so a module can never shadow a verb.

@ECHO OFF

:: Routed BEFORE SETLOCAL on purpose. Half the verbs (flags, env, data, resolve)
:: export into their caller by deliberately not scoping themselves, and a
:: SETLOCAL here would discard exactly what they exist to produce.
IF /I "%~1"=="function" GOTO Function

SETLOCAL EnableExtensions
CALL FnEtcDispatch Global %*
EXIT /B %ERRORLEVEL%

:Function
    SHIFT
    SET "Router_Verb=%~1"
    SET "Router_Name=%~2"
    SET "Router_Target="
    SET "Router_Prefix="
    SET "Router_Tail="
    SET "Router_Consume=1"

    IF NOT DEFINED Router_Verb GOTO FunctionUsage

    :: Fixed targets, one token.
    IF /I "%Router_Verb%"=="flags"             SET "Router_Target=FnEtcFlags"
    IF /I "%Router_Verb%"=="dispatch"          SET "Router_Target=FnEtcDispatch"
    IF /I "%Router_Verb%"=="dispatch-internal" SET "Router_Target=FnEtcDispatchInternal"
    IF /I "%Router_Verb%"=="dispatch-external" SET "Router_Target=FnEtcDispatchExternal"
    IF DEFINED Router_Target GOTO FunctionConsume

    :: Entry depths. The verb is itself the first argument to FnEtcDispatch, so
    :: nothing is consumed.
    FOR %%E IN (Global Organization Suite Project) DO IF /I "%Router_Verb%"=="%%E" (
        SET "Router_Target=FnEtcDispatch"
        SET "Router_Consume=0"
    )
    IF DEFINED Router_Target GOTO FunctionConsume

    :: Namespaced targets, two tokens.
    IF /I "%Router_Verb%"=="env"     SET "Router_Prefix=FnEtcEnvGet"
    IF /I "%Router_Verb%"=="data"    SET "Router_Prefix=FnEtcData"
    IF /I "%Router_Verb%"=="resolve" SET "Router_Prefix=FnEtcResolve"
    IF /I "%Router_Verb%"=="log"     SET "Router_Prefix=FnEtcLog"
    IF /I "%Router_Verb%"=="for"     SET "Router_Prefix=FnEtcForEach"

    IF NOT DEFINED Router_Name GOTO FunctionMissingName
    SET "Router_Consume=2"

    IF NOT DEFINED Router_Prefix GOTO FunctionModule

    :: "for" iterates a collection but calls a function named for one member.
    IF /I "%Router_Verb%"=="for" IF /I "%Router_Name:~-1%"=="s" SET "Router_Name=%Router_Name:~0,-1%"
    SET "Router_Target=%Router_Prefix%%Router_Name%"
    GOTO FunctionConsume

:FunctionModule
    :: Anything else is <module> <action>, which is Fn + Module + Action by the
    :: Docs.md naming rule. Batch resolves file names case insensitively, so the
    :: caller's casing does not have to match the file's.
    SET "Router_Target=Fn%Router_Verb%%Router_Name%"
    GOTO FunctionConsume

:FunctionConsume
    IF "%Router_Consume%"=="0" GOTO FunctionCollect
    SHIFT
    SET /A Router_Consume-=1
    GOTO FunctionConsume

:FunctionCollect
    :: %* ignores SHIFT, so the tail is rebuilt a token at a time. %1 rather than
    :: %~1 keeps each token's own quoting intact.
    IF [%1]==[] GOTO FunctionInvoke
    SET "Router_Tail=%Router_Tail% %1"
    SHIFT
    GOTO FunctionCollect

:FunctionInvoke
    CALL %Router_Target% %Router_Tail%
    SET "Router_ReturnCode=%ERRORLEVEL%"
    GOTO FunctionReturn

:FunctionMissingName
    CALL FnEtcLogError FnEtcRouter "Verb %Router_Verb% needs a name, as in: leprechaun function %Router_Verb% <Name>"
    SET "Router_ReturnCode=1"
    GOTO FunctionReturn

:FunctionUsage
    CALL FnEtcLogError FnEtcRouter "Missing required argument <Verb>"
    ECHO   Usage: leprechaun function ^<Verb^> ^<Args...^>
    ECHO   Verbs: flags dispatch dispatch-internal dispatch-external
    ECHO          env data resolve log for
    ECHO          Global Organization Suite Project
    ECHO          ^<module^> ^<action^>
    SET "Router_ReturnCode=1"
    GOTO FunctionReturn

:FunctionReturn
    :: No SETLOCAL in this branch, so the router's own variables are cleared by
    :: hand. The return code is carried out through a FOR variable because
    :: clearing it would have to happen before EXIT /B could read it.
    SET "Router_Verb="
    SET "Router_Name="
    SET "Router_Target="
    SET "Router_Prefix="
    SET "Router_Tail="
    SET "Router_Consume="
    FOR %%R IN (%Router_ReturnCode%) DO ( SET "Router_ReturnCode=" & EXIT /B %%R )
    EXIT /B 0

