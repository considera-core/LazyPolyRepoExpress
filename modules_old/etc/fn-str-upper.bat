:: =====================
:: fn-str-upper <string>
:: =====================
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "string=%~1"
CALL :ToUpper string
ECHO %string%
ENDLOCAL
EXIT /B 0

:ToUpper
    :: Usage: call :ToUpper varName
    SET "s=!%~1!"
    SET "s=!s:a=A!"
    SET "s=!s:b=B!"
    SET "s=!s:c=C!"
    SET "s=!s:d=D!"
    SET "s=!s:e=E!"
    SET "s=!s:f=F!"
    SET "s=!s:g=G!"
    SET "s=!s:h=H!"
    SET "s=!s:i=I!"
    SET "s=!s:j=J!"
    SET "s=!s:k=K!"
    SET "s=!s:l=L!"
    SET "s=!s:m=M!"
    SET "s=!s:n=N!"
    SET "s=!s:o=O!"
    SET "s=!s:p=P!"
    SET "s=!s:q=Q!"
    SET "s=!s:r=R!"
    SET "s=!s:s=S!"
    SET "s=!s:t=T!"
    SET "s=!s:u=U!"
    SET "s=!s:v=V!"
    SET "s=!s:w=W!"
    SET "s=!s:x=X!"
    SET "s=!s:y=Y!"
    SET "s=!s:z=Z!"
    SET "%~1=%s%"
    EXIT /B 0