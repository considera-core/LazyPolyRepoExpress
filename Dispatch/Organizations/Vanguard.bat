:: Vanguard <SUITE> <MODULE> <ACTION> <ARGS...> <FLAGS...>
:: -- Organization entry point for Vanguard.
:: -- Thin shim: the entry depth is what tells FnEtcDispatch how to read the
:: -- positional prefix before MODULE. See Docs.md "Schema".

@ECHO OFF
SETLOCAL EnableExtensions

CALL leprechaun function Organization vanguard %*
EXIT /B %ERRORLEVEL%
