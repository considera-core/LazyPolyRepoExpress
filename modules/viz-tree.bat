@echo off
REM tree.bat - Directory tree printer with depth control and file filtering
REM Usage: tree.bat <depth> <printFiles>
REM   depth: Integer specifying maximum depth to traverse (0 = current dir only)
REM   printFiles: Boolean (true/false) - whether to include files in output

setlocal enabledelayedexpansion

REM Check if correct number of parameters provided
if "%~1"=="help" (
    echo Usage: better-tree ^<depth^> ^<printFiles^>
    echo   depth: Integer ^(0 or greater^) ^| optional
    echo   printFiles: true or false ^| optional
    echo Example: tree.bat 2 true
    echo Help: better-tree help
    exit /b 1
)

REM Validate depth parameter (must be numeric and >= 0)
set "depth=%~1"
echo %depth%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    set "depth=1"
    echo Using default depth: 1
)

REM Validate printFiles parameter (must be true or false)
set "printFiles=%~2"
if /i not "%printFiles%"=="true" if /i not "%printFiles%"=="false" (
    set "printFiles=false"
    echo Using default printFiles: false
)

REM Convert printFiles to lowercase for consistent comparison
set "printFiles=%printFiles:~0,1%"
call :toLower printFiles

REM Start the tree traversal from current directory
echo Directory tree for: %CD%
echo.
call :printTree "%CD%" %depth% 0 "%printFiles%"
goto :eof

REM Main recursive function to print directory tree
REM Parameters: %1=current_path, %2=max_depth, %3=current_depth, %4=print_files
:printTree
set "currentPath=%~1"
set "maxDepth=%~2"
set "currentDepth=%~3"
set "showFiles=%~4"

REM Create indentation based on current depth
set "indent="
for /l %%i in (1,1,%currentDepth%) do set "indent=!indent!  "

REM If we've reached maximum depth, stop recursion
if %currentDepth% gtr %maxDepth% goto :eof

REM Print current directory name (except for root level)
if %currentDepth% gtr 0 (
    for %%f in ("%currentPath%") do echo !indent!%%~nxf\
)

REM If we've reached max depth, don't traverse subdirectories
if %currentDepth% equ %maxDepth% goto :eof

REM Calculate next depth level
set /a nextDepth=%currentDepth%+1

REM Process subdirectories first
for /d %%d in ("%currentPath%\*") do (
    if exist "%%d" (
        call :printTree "%%d" %maxDepth% %nextDepth% "%showFiles%"
    )
)

REM Process files if printFiles is true
if /i "%showFiles%"=="t" (
    set "fileIndent=!indent!  "
    for %%f in ("%currentPath%\*") do (
        if not exist "%%f\" (
            echo !fileIndent!%%~nxf
        )
    )
)

goto :eof

REM Helper function to convert string to lowercase
:toLower
set "str=!%~1!"
for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "str=!str:%%a=%%a!"
)
for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
    set "str=!str:%%A=%%a!"
)
set "%~1=!str!"
goto :eof

REM Error handling for invalid paths or access denied
:handleError
echo Error: Unable to access directory or invalid path
exit /b 1