@echo off
setlocal enabledelayedexpansion
for /f %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"

REM ==========================================================
REM              FILE SEARCH UTILITY (SAFE COPY MODE)
REM                 Developed by: Raonok
REM ==========================================================

REM ==============================
REM    SET SEARCH ROOT FOLDER BELOW
REM ==============================
set "SEARCH_ROOT=D:\"   REM <-- CHANGE THIS LINE IF NEEDED

REM === COLOR CODES ===
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

REM === COLORED BANNER ===
call :PrintBanner

REM === CENTERED CYAN REMINDER SECTION ===
call :PrintCentered "%CLR_CYAN%==========================================================%CLR_RESET%"
call :PrintCentered "%CLR_YELLOW%  REMINDER!%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%  1. Ensure your Input file: Input\input.txt exists%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%     - One filename per line.%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%  2. Make sure your search location is set correctly:%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%     
call :PrintCentered "%CLR_WHITE%  3. To change, edit this batch file:%CLR_RESET%"
call :PrintCentered "%CLR_WHITE%     - Find and update the line: set \ SEARCH_ROOT = Location %CLR_RESET%"
call :PrintCentered "%CLR_CYAN%==========================================================%CLR_RESET%"
echo.

REM === CONFIRMATION PROMPT ===
set "confirmation="
:ASK_CONFIRM
<nul set /p ="%CLR_BOLD%%CLR_CYAN%?%CLR_RESET% "
set /p "confirmation=Do you want to continue searching in '%SEARCH_ROOT%'? (Y/N): "
set "confirmation=!confirmation:~0,1!"
if /i "!confirmation!"=="Y" (
    echo %CLR_GREEN%Proceeding with search...%CLR_RESET%
) else if /i "!confirmation!"=="N" (
    echo %CLR_RED%Operation cancelled by user.%CLR_RESET%
    pause
    exit /b
) else (
    echo %CLR_YELLOW%Please type Y or N.%CLR_RESET%
    goto :ASK_CONFIRM
)

REM === PATH VARIABLES ===
set "BATDIR=%~dp0"
if "%BATDIR:~-1%"=="\" set "BATDIR=%BATDIR:~0,-1%"
set "INPUTFOLDER=%BATDIR%\Input"
set "OUTPUTFOLDER=%BATDIR%\Output"
set "LOGFOLDER=%BATDIR%\Log"
set "INPUTFILE=%INPUTFOLDER%\input.txt"
set "LOGFILE_FOUND=%LOGFOLDER%\found_files.log"
set "LOGFILE_NOTFOUND=%LOGFOLDER%\not_found_files.log"

REM === ENSURE FOLDERS EXIST ===
if not exist "%INPUTFOLDER%" (
    echo %CLR_RED%ERROR: Input folder not found at "%INPUTFOLDER%"%CLR_RESET%
    pause
    exit /b
)
if not exist "%OUTPUTFOLDER%" mkdir "%OUTPUTFOLDER%"
if not exist "%LOGFOLDER%" mkdir "%LOGFOLDER%"

REM === CHECK INPUT FILE ===
if not exist "%INPUTFILE%" (
    echo %CLR_RED%ERROR: input.txt not found in "%INPUTFOLDER%"%CLR_RESET%
    pause
    exit /b
)

REM === TIMESTAMPED OUTPUT FOLDER ===
for /f %%a in ('powershell -NoLogo -command "Get-Date -Format yyyy-MM-dd_HHmmss"') do set "DATETIME=%%a"
set "SPECIAL_OUTPUT=%OUTPUTFOLDER%\Found_Data_%DATETIME%"
if not exist "%SPECIAL_OUTPUT%" mkdir "%SPECIAL_OUTPUT%"

REM === INIT LOGS ===
> "%LOGFILE_FOUND%" echo [Found File Names Log]
> "%LOGFILE_NOTFOUND%" echo [Not Found File Names Log]

REM === COUNTERS ===
set /a totalItems=0
set /a foundCount=0
set /a notFoundCount=0

REM === MAIN SEARCH LOOP ===
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
        for /f "delims=" %%A in ('dir /a:-h-s /s /b "%SEARCH_ROOT%\!fname!!fext!" 2^>nul ^| findstr /vi /c:"\$RECYCLE.BIN" /c:"System Volume Information"') do (
            set "matchFound=1"
            call :PrintFound "%%A"
            call :CopyParentFolder "%%A"
        )
    ) else (
        for /f "delims=" %%A in ('dir /a:-h-s /s /b "%SEARCH_ROOT%\!fname!.*" 2^>nul ^| findstr /vi /c:"\$RECYCLE.BIN" /c:"System Volume Information"') do (
            set "matchFound=1"
            call :PrintFound "%%A"
            call :CopyParentFolder "%%A"
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

REM === SUMMARY ===
call :PrintSummary %totalItems% %foundCount% %notFoundCount%

REM === SHOW OUTPUT LOCATIONS ===
echo %CLR_CYAN%
echo All found folders have been saved to:
echo     "%SPECIAL_OUTPUT%"
echo Found data names logged at:
echo     "%LOGFILE_FOUND%"
echo Not found data logged at:
echo     "%LOGFILE_NOTFOUND%"
echo %CLR_RESET%

REM === END BANNER ===
call :PrintBannerDone
pause
endlocal
goto :eof

REM ==========================================================
REM                SUBROUTINES BELOW
REM ==========================================================

:PrintFound
echo %CLR_GREEN%[FOUND]%CLR_RESET% %CLR_BOLD%%~1%CLR_RESET%
for %%B in ("%~1") do (
    findstr /i /x /c:"%%~nxB" "%LOGFILE_FOUND%" >nul 2>&1
    if errorlevel 1 echo %%~nxB>>"%LOGFILE_FOUND%"
)
exit /b

:PrintNotFound
echo %CLR_RED%[NOT FOUND]%CLR_RESET% %CLR_BOLD%%~1%CLR_RESET%
findstr /i /x /c:"%~1" "%LOGFILE_NOTFOUND%" >nul 2>&1
if errorlevel 1 echo %~1>>"%LOGFILE_NOTFOUND%"
exit /b

:CopyParentFolder
REM === Copy only the found file into its parent folder (not hidden/system) ===
set "fullpath=%~1"
for %%P in ("%fullpath%") do set "parent=%%~dpP"
set "parent=!parent:~0,-1!"
for %%Q in ("!parent!") do set "foldername=%%~nxQ"

REM Create same parent folder in output
if not exist "%SPECIAL_OUTPUT%\!foldername!\" mkdir "%SPECIAL_OUTPUT%\!foldername!\"

REM Copy only that file
set "filename=%~nx1"
echo %CLR_BLUE%[COPYING]%CLR_RESET% Copying "!filename!" into "!foldername!" ...
copy "%fullpath%" "%SPECIAL_OUTPUT%\!foldername!\" /Y >nul
exit /b

:PrintSummary
echo %CLR_YELLOW%==============================================%CLR_RESET%
echo %CLR_YELLOW%Total Items Searched: %~1%CLR_RESET%
echo %CLR_YELLOW%Total Found Items   : %~2%CLR_RESET%
echo %CLR_YELLOW%Total Not Found     : %~3%CLR_RESET%
echo %CLR_YELLOW%==============================================%CLR_RESET%
exit /b

:PrintCentered
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
call :PrintCentered " %CLR_BOLD%[ FILE SEARCH UTILITY - With Sub Folder ]%CLR_RESET%%CLR_CYAN%"
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
