:: FnEtcDataModules
:: -- Output:
:: --   Output_Data_Modules                     (ModuleIdentifier[]) space separated module identifiers
:: --   Output_Data_Module<Index>Id             (ModuleIdentifier) module identifier

@ECHO OFF

:: Resolve source
CALL FnEtcLogDebug %~n0 "Resolving data path..."
CALL FnEtcEnvGetDataPath
CALL FnEtcLogDebug %~n0 "Resolved data path (Output_Env_DataPath): %Output_Env_DataPath%"

CALL FnEtcLogDebug %~n0 "Verifying data path..."
SET "Local_DataModulesFile=%Output_Env_DataPath%\Modules.csv"
IF NOT EXIST "%Local_DataModulesFile%" (
    CALL FnEtcLogError %~n0 "Modules.csv not found at %Local_DataModulesFile%"
    EXIT /B 1
)
CALL FnEtcLogDebug %~n0 "Verified data path (Local_DataModulesFile): %Local_DataModulesFile%"

:: Clear existing
CALL FnEtcLogDebug %~n0 "Clearing existing data..."
FOR /F "delims==" %%V IN ('SET Output_Data_Module 2^>NUL') DO SET "%%V="
CALL FnEtcLogDebug %~n0 "Cleared existing data."

:: Map to output
SET "Local_Index=0"
CALL FnEtcLogDebug %~n0 "Mapping data..."
FOR /F "usebackq skip=1 tokens=1 delims=, eol=#" %%a IN ("%Local_DataModulesFile%") DO (
    CALL SET "Output_Data_Modules=%%Output_Data_Modules%% %%a"
    CALL SET "Output_Data_Module%%Local_Index%%Id=%%a"
    SET /A Local_Index+=1
    CALL FnEtcLogDebug %~n0 "Mapped (Output_Data_Module%%Local_Index%%Id): %%a"
    CALL FnEtcLogDebug %~n0 "Updated (Output_Data_Modules): %%Output_Data_Modules%%"
)
CALL FnEtcLogDebug %~n0 "Mapped data."

:: Trim the leading separator so the joined form iterates cleanly.
IF DEFINED Output_Data_Modules SET "Output_Data_Modules=%Output_Data_Modules:~1%"
SET "Output_Data_ModulesCount=%Local_Index%"
EXIT /B 0
