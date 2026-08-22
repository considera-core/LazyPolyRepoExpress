:: leprechaun <ORG> <SUITE> <MODULE> <ACTION> <ARGS...> <FLAGS...>
:: -- Global entry point. Every organization is reachable from here.
:: -- Thin shim: the entry depth is what tells FnEtcDispatch how to read the
:: -- positional prefix before MODULE. See Docs.md "Schema".

@ECHO OFF
SETLOCAL EnableExtensions

CALL leprechaun function Global vanguard %*
EXIT /B %ERRORLEVEL%
