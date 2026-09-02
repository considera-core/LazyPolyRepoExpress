:: FnEtcLogRun <Function> <Message>
:: leprechaun function log run <Function> <Message>
:: -- Writes a dry run report as LeprechaunCLI:<Function>[R]: <Message>.
:: --
:: -- NOTE: The message is captured BEFORE delayed expansion is enabled, then
:: --       echoed through it. That is what lets a message carry <, >, & or !
:: --       literally: a plain ECHO would read them as operators, and capturing
:: --       them under delayed expansion would eat the "!". Messages therefore
:: --       need no caret escaping, which matters because every CALL hop between
:: --       the caller and here strips one level of caret.

@ECHO OFF
SETLOCAL EnableExtensions

SET "Function_Name=%~1"
SET "Function_Message=%~2"

IF NOT DEFINED Function_Name (
    ECHO LeprechaunCLI:FnEtcLogRun[F]: Missing required argument Function
    EXIT /B 1
)

IF NOT DEFINED Function_Message (
    ECHO LeprechaunCLI:FnEtcLogRun[F]: Missing required argument Message
    EXIT /B 1
)

SETLOCAL EnableDelayedExpansion
ECHO LeprechaunCLI:!Function_Name![R]: !Function_Message!
EXIT /B 0
