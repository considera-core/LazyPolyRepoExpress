:: FnEtcLogWarning <Function> <Message>
:: -- Input:
:: --   <Function> The name of the function generating the log message.
:: --   <Message> The warning message to be logged.
:: -- Output:
:: --   void stdout

@ECHO OFF

CALL FnEtcConfigGet Logs__Warning
IF ERRORLEVEL 1 EXIT /B 1
IF NOT "%Output_Config_Value%"=="true" EXIT /B 0

SET "Input_Name=%~1"
SET "Input_Message=%~2"

IF NOT DEFINED Input_Name ECHO "LeprechaunCLI:%~n0[F]: Missing required argument Function" & EXIT /B 1
IF NOT DEFINED Input_Message ECHO "LeprechaunCLI:%~n0[F]: Missing required argument Message" & EXIT /B 1

CALL FnEtcConfigGet "Logs__Warning__%Input_Name%"
IF "%Output_Config_Value%"=="false" EXIT /B 0

ECHO LeprechaunCLI:%Input_Name%[W]: %Input_Message%
EXIT /B 0
