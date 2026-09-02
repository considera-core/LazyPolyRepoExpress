:: FnEtcRouter <OrgId> <SuiteId> <ModuleId> <ActionId> <AppId | ProjectId | Arg> <...Args?> <...Flags?>
:: ^| FnEtcRouter <OrgId> <ModuleId> <ActionId> <AppId | ProjectId | Arg> <...Args?> <...Flags?>
:: -- Also validates the existence of the params if related to Data, so no need to check again in the action level
:: Puesdo:
:: If (Input_SuiteId.IsSuite()) then
::   SET "Input_Module=%~2"
::   SET "Input_Action=%~3"
::   SET "Input_Arg4=%~4"
::   CALL FnEtcFlags2 -p "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Input_Arg4!" -a %*
::   If (Input_Arg4.IsApp()) then
::     CALL FnEtcDispatch2 app !Input_Arg4! !Input_SuiteId! !Input_Module! !Input_Action! !Output_FnEtcFlags_Args! !Output_FnEtcFlags_Flags!
::   Else If (Input_Arg4.IsProject()) then
::     CALL FnEtcDispatch2 project !Input_Arg4! !Input_SuiteId! !Input_Module! !Input_Action! !Output_FnEtcFlags_Args! !Output_FnEtcFlags_Flags!
::   Else
::     CALL FnEtcDispatch2 suite !Input_SuiteId! !Input_Module! !Input_Action! !Output_FnEtcFlags_Args! !Output_FnEtcFlags_Flags!
:: Else then
::   SET "Input_Module=%~1"
::   SET "Input_Action=%~2"
::   SET "Input_Arg3=%~3"
:: End If

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"
SET "DEBUG=1"

IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "SET Input_OrgId: %Input_OrgId%"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "SET Input_SuiteId: %Input_SuiteId%"

IF NOT DEFINED Input_OrgId (
    ECHO "Missing required argument <OrgId>"
    EXIT /B 1
)

IF NOT DEFINED Input_SuiteId (
    ECHO "Missing required argument <SuiteId | ModuleId>"
    CALL FnEtcHelp organization "%Input_OrgId%"
    EXIT /B 1
)

CALL FnEtcResolveSuite "%Input_SuiteId%" >NUL 2>&1

IF ERRORLEVEL 1 (
    SET "Input_Module=%~2"
    SET "Input_Action=%~3"
    SET "Input_Arg=%~4"
    
    IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcResolveSuite Fail"
    IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "SET Input_Module: !Input_Module!"
    IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "SET Input_Action: !Input_Action!"
    IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "SET Input_Arg: !Input_Arg!"

    IF DEFINED Input_Arg (
        CALL FnEtcFlags2 -p "!Input_OrgId!" "!Input_Module!" "!Input_Action!" "!Input_Arg!" -a %*
        CALL FnEtcDispatch2 organization "!Input_OrgId!" "!Input_Module!" "!Input_Action!" "!Input_Arg!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
    ) ELSE (
        CALL FnEtcFlags2 -p "!Input_OrgId!" "!Input_Module!" "!Input_Action!" -a %*
        CALL FnEtcDispatch2 organization "!Input_OrgId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
    )

) ELSE (
    SET "Input_Module=%~3"
    SET "Input_Action=%~4"
    SET "Input_Arg=%~5"
    
    IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcResolveSuite Success"
    IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "SET Input_Module: !Input_Module!"
    IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "SET Input_Action: !Input_Action!"
    IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "SET Input_Arg: !Input_Arg!"

    IF DEFINED Input_Arg (
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcFlags2 Called"
        CALL FnEtcFlags2 -p "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Input_Arg!" -a %*
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcFlags2 %ErrorLevel%"

        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcResolveSuiteApp Called"
        CALL FnEtcResolveSuiteApp "!Input_SuiteId!" "!Input_Arg!"
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcResolveSuiteApp %ErrorLevel%"

        IF ERRORLEVEL 1 (
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcResolveProject Called"
            CALL FnEtcResolveProject "!Input_SuiteId!" "!Input_Arg!"
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcResolveProject %ErrorLevel%"

            IF ERRORLEVEL 1 (
                IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcDispatch2 Called"
                CALL FnEtcDispatch2 suite "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
                IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcDispatch2 %ErrorLevel%"
            ) ELSE (
                IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcDispatch2 Called"
                CALL FnEtcDispatch2 project "!Input_Arg!" "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
                IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcRouter "FnEtcDispatch2 %ErrorLevel%"
            )
        ) ELSE (
            CALL FnEtcDispatch2 app "!Input_Arg!" "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
        )
    ) ELSE (
        CALL FnEtcFlags2 -p "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" -a %*
        CALL FnEtcDispatch2 suite "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
    )
)
