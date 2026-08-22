:: FnEtcLogRun <Function> <Message>
:: leprechaun function log run <Function> <Message>
:: -- Logs an error message to the LeprechaunCLI log file, and also echoes it to
:: -- the console. The message is prefixed with the function name, and the error level.

@ECHO OFF

SET "FUNCTION_NAME=%~1"
IF NOT DEFINED FUNCTION_NAME (
    ECHO LeprechaunCLI:FnEtcLogRun[F]: Missing required argument ^<Function^>
    EXIT /B 1
)

SET "FUNCTION_MESSAGE=%~2"
IF NOT DEFINED FUNCTION_MESSAGE (
    ECHO LeprechaunCLI:FnEtcLogRun[F]: Missing required argument ^<Message^>
    EXIT /B 1
)

ECHO LeprechaunCLI:%FUNCTION_NAME%[R]: %FUNCTION_MESSAGE%