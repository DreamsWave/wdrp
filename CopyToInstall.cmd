@echo off
:: Variables for paths
set "REPO_DIR=%~dp0"
set "WINAMPDIR=C:\Program Files (x86)\Winamp"

:: Check if Winamp is installed in Program Files
if exist "%WINAMPDIR%\winamp.exe" (
    echo Found Winamp at "%WINAMPDIR%"
) else (
    :: Try alternate location
    set "WINAMPDIR=C:\Program Files\Winamp"
    if exist "%WINAMPDIR%\winamp.exe" (
        echo Found Winamp at "%WINAMPDIR%"
    ) else (
        echo ERROR: Winamp installation not found!
        echo Please edit this script to set the correct path.
        pause
        exit /b 1
    )
)

:: Create the plugins directory if needed
if not exist "%WINAMPDIR%\Plugins" (
    mkdir "%WINAMPDIR%\Plugins"
)

:: Find the built DLL
set "DLL_PATH="
if exist "%REPO_DIR%Release\DiscordRichPresence.dll" (
    set "DLL_PATH=%REPO_DIR%Release\DiscordRichPresence.dll"
) else if exist "%REPO_DIR%DiscordRichPresence\Release\DiscordRichPresence.dll" (
    set "DLL_PATH=%REPO_DIR%DiscordRichPresence\Release\DiscordRichPresence.dll"
) else if exist "%REPO_DIR%DiscordRichPresence\x64\Release\DiscordRichPresence.dll" (
    set "DLL_PATH=%REPO_DIR%DiscordRichPresence\x64\Release\DiscordRichPresence.dll"
) else (
    echo ERROR: Could not find the built DiscordRichPresence.dll
    echo Make sure you've built the project in Release mode.
    pause
    exit /b 1
)

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: Not running as administrator. You may encounter permission issues.
    echo It's recommended to run this script as administrator.
    echo.
    pause
)

:: Create target directories
echo Creating directories...
if not exist "%WINAMPDIR%\Plugins\DiscordRichPresence" (
    mkdir "%WINAMPDIR%\Plugins\DiscordRichPresence"
)

:: Copy the files
echo Copying files to Winamp plugins directory...
copy /Y "%DLL_PATH%" "%WINAMPDIR%\Plugins\gen_DiscordRichPresence.dll"
if %errorLevel% neq 0 (
    echo Failed to copy DiscordRichPresence.dll. Permissions issue?
    echo Try running this script as administrator.
    pause
    exit /b 1
)

:: Copy Discord RPC DLL
copy /Y "%REPO_DIR%discord-rpc.dll" "%WINAMPDIR%\Plugins\DiscordRichPresence"
if %errorLevel% neq 0 (
    echo Failed to copy discord-rpc.dll. Permissions issue?
)

:: Copy the executable
copy /Y "%REPO_DIR%send-presence.exe" "%WINAMPDIR%\Plugins\DiscordRichPresence"
if %errorLevel% neq 0 (
    echo Failed to copy send-presence.exe. Permissions issue?
)

:: Create settings.ini files with default values
echo Creating settings files with default values...

:: Create in plugin directory
echo DisplayTitleInStatus:true > "%WINAMPDIR%\Plugins\DiscordRichPresence\settings.ini"
echo ShowElapsedTime:true >> "%WINAMPDIR%\Plugins\DiscordRichPresence\settings.ini"
echo ApplicationID:0 >> "%WINAMPDIR%\Plugins\DiscordRichPresence\settings.ini"

:: Create in AppData as backup
set "APPDATA_DIR=%APPDATA%\WinampDiscordRichPresence"
if not exist "%APPDATA_DIR%" (
    mkdir "%APPDATA_DIR%"
)
echo DisplayTitleInStatus:true > "%APPDATA_DIR%\settings.ini"
echo ShowElapsedTime:true >> "%APPDATA_DIR%\settings.ini"
echo ApplicationID:0 >> "%APPDATA_DIR%\settings.ini"

:: Ensure all files are not read-only
echo Ensuring files are not read-only...
attrib -R "%WINAMPDIR%\Plugins\DiscordRichPresence\*.*" /S
attrib -R "%WINAMPDIR%\Plugins\gen_DiscordRichPresence.dll"
attrib -R "%APPDATA_DIR%\settings.ini"

echo.
echo Installation complete!
echo.
echo IMPORTANT: To use your own Discord Application ID:
echo 1. Create a Discord application at https://discord.com/developers/applications
echo 2. Copy the Application ID and paste it into Winamp's plugin settings
echo 3. Or edit the settings.ini file directly with your Application ID
echo.
pause
