:: FnEtcLogError <Function> <Message>
:: leprechaun function log error <Function> <Message>
:: -- Writes an error as LeprechaunCLI:<Function>[E]: <Message>.
:: --
:: -- NOTE: The message is captured BEFORE delayed expansion is enabled, then
:: --       echoed through it. That is what lets a message carry <, >, & or !
:: --       literally: a plain ECHO would read them as operators, and capturing
:: --       them under delayed expansion would eat the "!". Messages therefore
:: --       need no caret escaping, which matters because every CALL hop between
:: --       the caller and here strips one level of caret.

@ECHO OFF
SETLOCAL EnableExtensions

SET "Input_Name=%~1"
SET "Input_Message=%~2"

IF NOT DEFINED Input_Name (
    ECHO LeprechaunCLI:FnEtcLogError[F]: Missing required argument Function
    EXIT /B 1
)

IF NOT DEFINED Input_Message (
    ECHO LeprechaunCLI:FnEtcLogError[F]: Missing required argument Message
    EXIT /B 1
)

SETLOCAL EnableDelayedExpansion
ECHO LeprechaunCLI:!Input_Name![E]: !Input_Message!
EXIT /B 0
