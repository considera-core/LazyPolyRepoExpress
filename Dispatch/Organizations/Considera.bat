:: Considera <SUITE> <MODULE> <ACTION> <ARGS...> <FLAGS...>
:: -- Organization entry point for Considera.
:: -- Thin shim: the entry depth is what tells FnEtcDispatch how to read the
:: -- positional prefix before MODULE. See Docs.md "Schema".

@ECHO OFF
SETLOCAL EnableExtensions

CALL leprechaun function Organization considera %*
EXIT /B %ERRORLEVEL%
