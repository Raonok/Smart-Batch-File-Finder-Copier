@echo off
setlocal enabledelayedexpansion
for /f %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"



REM ==============================
REM    MANUALLY SET THE SEARCH ROOT FOLDER BELOW
REM ==============================
set "SEARCH_ROOT=C:\Users\11892-Rofiqul-Islam\Downloads\EDM Vault_Raonok"   REM <-- CHANGE THIS LINE

REM === COLORED BANNER ===
call :PrintBanner

REM === COLOR CODES FOR EASY USE ===
set "CLR_RESET=%ESC%[0m"
set "CLR_RED=%ESC%[31m"
set "CLR_GREEN=%ESC%[32m"
set "CLR_YELLOW=%ESC%[33m"
set "CLR_BLUE=%ESC%[34m"
set "CLR_CYAN=%ESC%[36m"
set "CLR_WHITE=%ESC%[97m"
set "CLR_BOLD=%ESC%[1m"
set "CLR_DIM=%ESC%[2m"
set "CLR_MAGENTA=%ESC%[35m"

REM === CENTERED CYAN REMINDER SECTION ===
call :PrintCentered "%CLR_CYAN%==========================================================%CLR_RESET%"
call :PrintCentered "%CLR_YELLOW%  REMINDER!%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%  1. Ensure your Input file: Input\input.txt exists%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%     - One filename per line.%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%  2. Make sure your search location is set correctly:%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%     - Current SEARCH_ROOT = %SEARCH_ROOT%%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%  3. To change, edit this batch file:%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%     - Find and update the line: set \ SEARCH_ROOT = Location %CLR_RESET%"
call :PrintCentered "%CLR_CYAN%==========================================================%CLR_RESET%"
echo.

REM === ASK FOR CONFIRMATION (CYAN) ===
set "confirmation="
:ASK_CONFIRM
<nul set /p ="%CLR_BOLD%%CLR_CYAN%?%CLR_RESET% "
set /p "confirmation=Do you want to continue? (%CLR_YELLOW%YES/NO Or Y/N%CLR_RESET%): "
set "confirmation=!confirmation:~0,1!"
if /i "!confirmation!"=="Y" (
    echo %CLR_GREEN%Proceeding with search...%CLR_RESET%
) else if /i "!confirmation!"=="N" (
    echo %CLR_RED%Operation cancelled by user.%CLR_RESET%
    pause
    exit /b
) else (
    echo %CLR_YELLOW%Please type YES or NO.%CLR_RESET%
    goto :ASK_CONFIRM
)

REM === DIRECTORY VARIABLES ===
set "BATDIR=%~dp0"
if "%BATDIR:~-1%"=="\" set "BATDIR=%BATDIR:~0,-1%"
set "INPUTFOLDER=%BATDIR%\Input"
set "OUTPUTFOLDER=%BATDIR%\Output"
set "LOGFOLDER=%BATDIR%\Log"
set "INPUTFILE=%INPUTFOLDER%\input.txt"
set "LOGFILE_FOUND=%LOGFOLDER%\found_files.log"
set "LOGFILE_NOTFOUND=%LOGFOLDER%\not_found_files.log"

REM === ENSURE LOG FOLDER EXISTS ===
if not exist "%LOGFOLDER%" (
    echo %CLR_BLUE%[INFO]%CLR_RESET% Creating log folder: "%LOGFOLDER%"
    mkdir "%LOGFOLDER%"
)

REM === INPUT CHECKS WITH COLORS ===
if not exist "%INPUTFOLDER%" (
    echo %CLR_RED%ERROR: Input folder not found at "%INPUTFOLDER%"%CLR_RESET%
    pause
    exit /b
)
if not exist "%INPUTFILE%" (
    echo %CLR_RED%ERROR: input.txt not found in "%INPUTFOLDER%"%CLR_RESET%
    pause
    exit /b
)

REM === ENSURE OUTPUT FOLDER EXISTS ===
if not exist "%OUTPUTFOLDER%" (
    echo %CLR_BLUE%[INFO]%CLR_RESET% Creating output folder: "%OUTPUTFOLDER%"
    mkdir "%OUTPUTFOLDER%"
)

REM === TIMESTAMPED SPECIAL OUTPUT FOLDER ===
for /f %%a in ('powershell -NoLogo -command "Get-Date -Format yyyy-MM-dd_HHmmss"') do set "DATETIME=%%a"
set "SPECIAL_OUTPUT=%OUTPUTFOLDER%\Found_Data_%DATETIME%"
if not exist "%SPECIAL_OUTPUT%" (
    echo %CLR_BLUE%[INFO]%CLR_RESET% Creating special output folder: "%SPECIAL_OUTPUT%"
    mkdir "%SPECIAL_OUTPUT%"
)

REM === CLEAR/CREATE LOG FILES WITH HEADER ===
> "%LOGFILE_FOUND%" echo [Found File Names Log]
> "%LOGFILE_NOTFOUND%" echo [Not Found File Names Log]

REM === COUNTERS ===
set /a totalItems=0
set /a foundCount=0
set /a notFoundCount=0

REM === MAIN LOOP: SEARCH FOR EACH INPUT ===
for /f "usebackq delims=" %%F in ("%INPUTFILE%") do (
    echo.
    echo %CLR_BOLD%%CLR_MAGENTA%Searching for "%CLR_YELLOW%%%F%CLR_MAGENTA%" ...%CLR_RESET%
    set "item=%%F"
    set "matchFound=0"
    for %%X in ("!item!") do (
        set "fname=%%~nX"
        set "fext=%%~xX"
    )
    if defined fext (
        for /f "delims=" %%A in ('dir /s /b "%SEARCH_ROOT%\!fname!!fext!" 2^>nul') do (
            set "matchFound=1"
            call :PrintFound "%%A"
            copy "%%A" "%SPECIAL_OUTPUT%\" >nul
        )
        for /f "delims=" %%A in ('dir /s /b "%SEARCH_ROOT%\!fname!" 2^>nul') do (
            set "matchFound=1"
            call :PrintFound "%%A"
            copy "%%A" "%SPECIAL_OUTPUT%\" >nul
        )
    ) else (
        for /f "delims=" %%A in ('dir /s /b "%SEARCH_ROOT%\!fname!.*" 2^>nul') do (
            set "matchFound=1"
            call :PrintFound "%%A"
            copy "%%A" "%SPECIAL_OUTPUT%\" >nul
        )
        for /f "delims=" %%A in ('dir /s /b "%SEARCH_ROOT%\!fname!" 2^>nul') do (
            set "matchFound=1"
            call :PrintFound "%%A"
            copy "%%A" "%SPECIAL_OUTPUT%\" >nul
        )
    )
    set /a totalItems+=1
    if "!matchFound!"=="1" (
        set /a foundCount+=1
    ) else (
        set /a notFoundCount+=1
        call :PrintNotFound "%%F"
    )
)
echo.

REM === PRINT SUMMARY IN YELLOW ===
call :PrintSummary %totalItems% %foundCount% %notFoundCount%

REM === SHOW LOG FILE LOCATIONS ===
echo %CLR_CYAN%
echo All found data has been saved to:
echo     "%SPECIAL_OUTPUT%"
echo Found data names have been saved to:
echo     "%LOGFILE_FOUND%"
echo NOT found data names have been saved to:
echo     "%LOGFILE_NOTFOUND%"
echo %CLR_RESET%

REM === END BANNER ===
call :PrintBannerDone
pause
endlocal
goto :eof

REM =========================================
REM      SUBROUTINES FOR COLORED OUTPUT
REM =========================================

:PrintFound
echo %CLR_GREEN%[FOUND]%CLR_RESET% %CLR_BOLD%%~1%CLR_RESET%
for %%B in ("%~1") do (
    findstr /i /x /c:"%%~nxB" "%LOGFILE_FOUND%" >nul 2>&1
    if errorlevel 1 (
        echo %%~nxB>>"%LOGFILE_FOUND%"
    )
)
exit /b

:PrintNotFound
echo %CLR_RED%[NOT FOUND]%CLR_RESET% %CLR_BOLD%%~1%CLR_RESET%
findstr /i /x /c:"%~1" "%LOGFILE_NOTFOUND%" >nul 2>&1
if errorlevel 1 (
    echo %~1>>"%LOGFILE_NOTFOUND%"
)
exit /b

:PrintSummary
echo %CLR_YELLOW%==============================================%CLR_RESET%
echo %CLR_YELLOW%Total Items Searched: %~1%CLR_RESET%
echo %CLR_YELLOW%Total Found Items   : %~2%CLR_RESET%
echo %CLR_YELLOW%Total Not Found     : %~3%CLR_RESET%
echo %CLR_YELLOW%==============================================%CLR_RESET%
exit /b

:PrintCentered
REM Usage: call :PrintCentered "Your message"
REM Assumes console width is 80
setlocal EnableDelayedExpansion
set "str=%~1"
set "width=80"
call :StrLen str len
set /a padlen=(width-len)/2
if !padlen! lss 0 set padlen=0
set "pad="
for /L %%i in (1,1,!padlen!) do set "pad=!pad! "
echo(!pad!!str!
endlocal
exit /b

:StrLen
setlocal EnableDelayedExpansion
set "s=!%1!"
set "len=0"
:strlenloop
if defined s (
    set "s=!s:~1!"
    set /a len+=1
    goto strlenloop
)
(endlocal & set "%2=%len%")
exit /b

:PrintBanner
echo %CLR_CYAN%
call :PrintCentered " ==================================================="
call :PrintCentered " %CLR_BOLD%[ FILE SEARCH UTILITY ]%CLR_RESET%%CLR_CYAN%"
call :PrintCentered " ==================================================="
echo %CLR_RESET%
exit /b

:PrintBannerDone
call :PrintCentered "%CLR_GREEN% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %CLR_RESET%"
call :PrintCentered "%CLR_GREEN%All done! %CLR_RESET%"
call :PrintCentered "%CLR_CYAN%Developed By: Raonok%CLR_RESET%"
call :PrintCentered "%CLR_CYAN%Mechanical Design Engineer (BJIT)%CLR_RESET%"
call :PrintCentered "%CLR_GREEN% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %CLR_RESET%"
exit /b