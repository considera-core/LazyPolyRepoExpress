:: Considera <SUITE> <MODULE> <ACTION> <ARGS...> <FLAGS...>
:: -- Organization entry point for Considera.
:: -- Thin shim: the entry depth is what tells FnEtcDispatch how to read the
:: -- positional prefix before MODULE. See Docs.md "Schema".
:: -- Examples:
:: --   considera consideraweb app run web -v                           (considera <SuiteId> <ModuleId> <ActionId> <AppId> <Flag[]> => FnEtcDispatch2 app <AppId> <SuiteId> <ModuleId> <ActionId> <Flag[]> (app needs suite verification))
:: --   considera consideraweb app launch bff -v                        (considera <SuiteId> <ModuleId> <ActionId> <ProjectId> <Flag[]> => FnEtcDispatch2 project <ProjectId> <SuiteId> <ModuleId> <ActionId> <Flag[]> (project needs suite verification))
:: --   considera consideraweb git story web ZC-ABC-1234                (considera <SuiteId> <ModuleId> <ActionId> <AppId> <StoryId> <Flag[]> => FnEtcDispatch2 app <AppId> <SuiteId> <ModuleId> <ActionId> <StoryId> <Flag[]> (app needs suite verification))
:: --   considera consideraweb git story bff ZC-ABC-1234                (considera <SuiteId> <ModuleId> <ActionId> <ProjectId> <StoryId> <Flag[]> => FnEtcDispatch2 project <ProjectId> <SuiteId> <ModuleId> <ActionId> <StoryId> <Flag[]> (project needs suite verification))
:: --   considera consideraweb git story ZC-ABC-1234 -p bff api -v      (considera <SuiteId> <ModuleId> <ActionId> <StoryId> -p <Project[]> <Flag[]> => FnEtcDispatch2 suite <SuiteId> <ModuleId> <ActionId> <StoryId> -p <Project[]> <Flag[]> (suite verifies projects))
:: --   considera consideraweb git branch -v                            (considera <SuiteId> <ModuleId> <ActionId> <Flag[]> => FnEtcDispatch2 suite <SuiteId> <ModuleId> <ActionId> <Flag[]> (suite controls projects))
:: --   considera git branch -v                                         (considera <ModuleId> <ActionId> <Flag[]> => FnEtcDispatch2 organization considera <ModuleId> <ActionId> <Flag[]> (global controls suites)) 
:: --   considera git story ZC-ABC-1234 -v                              (considera <ModuleId> <ActionId> <StoryId> <Flag[]> => FnEtcDispatch2 organization considera <ModuleId> <ActionId> <StoryId> <Flag[]> (global controls suites)) 
:: --   considera                                                       (considera => FnEtcHelp organization considera)

:: -- Generically (so I need something to call FnEtcDispatch2, not in Considera.bat. that will call whatever calls FnEtcDispatch2):
:: --   <THIS.OrgId> <SuiteId> <ModuleId> <ActionId> <AppId | ProjectId | Arg> <...Args?> <...Flags?>
:: --   ^| <THIS.OrgId> <ModuleId> <ActionId> <AppId | ProjectId | Arg> <...Args?> <...Flags?>


@ECHO OFF
SETLOCAL EnableExtensions

:: FnEtcRouter considera %*
CALL FnEtcRouter considera %*
EXIT /B %ERRORLEVEL%
