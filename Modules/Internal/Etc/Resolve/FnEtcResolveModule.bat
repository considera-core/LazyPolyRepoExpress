:: FnEtcResolveModule <ModuleId>
:: -- Output:
:: --   Output_Resolved_ModuleId         (ModuleIdentifier) module identifier

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

:: Config inputs
SET "Input_ModuleId=%~1"
IF NOT DEFINED Input_ModuleId (
    CALL FnEtcLogError %~n0 "Missing required argument ^<ModuleId^>"
    EXIT /B 1
)

:: Clear existing
CALL FnEtcLogDebug %~n0 "Clearing existing data..."
FOR /F "delims==" %%V IN ('SET Output_Resolved_Module 2^>NUL') DO SET "%%V="
CALL FnEtcLogDebug %~n0 "Cleared existing data."

:: Resolve source data
CALL FnEtcLogDebug %~n0 "Resolving source data..."
CALL FnEtcDataModules
IF ERRORLEVEL 1 EXIT /B 1
CALL FnEtcLogDebug %~n0 "Resolved source data."

FOR %%M IN (%Output_Data_Modules%) DO (
    IF NOT DEFINED Output_Resolved_ModuleId (
        IF /I NOT "%Input_ModuleId%"=="%%M" (
            CALL FnEtcLogDebug %~n0 "Skipping module %%M"
        ) ELSE (
            CALL SET "Output_Resolved_ModuleId=%%M"
            CALL FnEtcLogDebug %~n0 "Resolved module (Output_Resolved_ModuleId): %%M"
        )
    )
)
IF NOT DEFINED Output_Resolved_ModuleId (
    CALL FnEtcLogError %~n0 "Unknown module %Input_ModuleId%"
    ECHO   Modules: %Output_Data_Modules%
    EXIT /B 1
)
CALL FnEtcLogDebug %~n0 "Resolved data."

ENDLOCAL ^
    & SET "Output_Resolved_ModuleId=%Output_Resolved_ModuleId%"

EXIT /B 0
