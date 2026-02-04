:: =====================
:: fn-str-lower <string>
:: =====================
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "string=%*"
CALL :ToLower string
ECHO %string%
ENDLOCAL
EXIT /B 0

:ToLower
    :: Usage: call :ToLower varName
    SET "s=!%~1!"
    SET "s=!s:A=a!"
    SET "s=!s:B=b!"
    SET "s=!s:C=c!"
    SET "s=!s:D=d!"
    SET "s=!s:E=e!"
    SET "s=!s:F=f!"
    SET "s=!s:G=g!"
    SET "s=!s:H=h!"
    SET "s=!s:I=i!"
    SET "s=!s:J=j!"
    SET "s=!s:K=k!"
    SET "s=!s:L=l!"
    SET "s=!s:M=m!"
    SET "s=!s:N=n!"
    SET "s=!s:O=o!"
    SET "s=!s:P=p!"
    SET "s=!s:Q=q!"
    SET "s=!s:R=r!"
    SET "s=!s:S=s!"
    SET "s=!s:T=t!"
    SET "s=!s:U=u!"
    SET "s=!s:V=v!"
    SET "s=!s:W=w!"
    SET "s=!s:X=x!"
    SET "s=!s:Y=y!"
    SET "s=!s:Z=z!"
    SET "%~1=%s%"
    EXIT /B 0