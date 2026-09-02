:: FnEtcLogWarning <Function> <Message>
:: leprechaun function log warning <Function> <Message>
:: -- Writes a warning as LeprechaunCLI:<Function>[W]: <Message>.
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
    ECHO LeprechaunCLI:FnEtcLogWarning[F]: Missing required argument Function
    EXIT /B 1
)

IF NOT DEFINED Function_Message (
    ECHO LeprechaunCLI:FnEtcLogWarning[F]: Missing required argument Message
    EXIT /B 1
)

SETLOCAL EnableDelayedExpansion
ECHO LeprechaunCLI:!Function_Name![W]: !Function_Message!
EXIT /B 0
