:: FnEtcLogError <FUNCTION> <MESSAGE>
:: leprechaun function log error <FUNCTION> <MESSAGE>
:: -- Logs an error message to the LeprechaunCLI log file, and also echoes it to
:: -- the console. The message is prefixed with the function name, and the error level.

@ECHO OFF

SET "FUNCTION_NAME=%~1"
IF NOT DEFINED FUNCTION_NAME (
    ECHO LeprechaunCLI:FnEtcLogError[F]: Missing required argument ^<FUNCTION^>
    EXIT /B 1
)

SET "FUNCTION_MESSAGE=%~2"
IF NOT DEFINED FUNCTION_MESSAGE (
    ECHO LeprechaunCLI:FnEtcLogError[F]: Missing required argument ^<MESSAGE^>
    EXIT /B 1
)

ECHO LeprechaunCLI:%FUNCTION_NAME%[E]: %FUNCTION_MESSAGE%