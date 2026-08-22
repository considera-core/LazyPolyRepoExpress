:: ConsideraWeb <MODULE> <ACTION> <ARGS...> <FLAGS...>
:: -- Suite entry point for ConsideraWeb.
:: -- Thin shim: the entry depth is what tells FnEtcDispatch how to read the
:: -- positional prefix before MODULE. See Docs.md "Schema".

@ECHO OFF
SETLOCAL EnableExtensions

CALL leprechaun function Suite consideraweb %*
EXIT /B %ERRORLEVEL%
