@echo on
setlocal

:: Use 7-Zip if available, otherwise use built-in ZIP command
if exist "C:\Program Files\7-Zip\7z.exe" (
    set ZIP_UTILITY="C:\Program Files\7-Zip\7z.exe"
) else (
    set ZIP_UTILITY=powershell -command "Compress-Archive -Path"
)

del /Q Distribute.zip 2>nul
rmdir /S /Q Distribute 2>nul

mkdir Distribute
mkdir Distribute\DiscordRichPresence

echo Copying files to Distribute folder...

:: Use the 32-bit Discord RPC files from our project
if exist "%CD%\DiscordRichPresence\dependencies\discord-rpc\win32-dynamic\bin\discord-rpc.dll" (
    echo Using 32-bit Discord RPC files from project directory
    copy /Y "DiscordRichPresence\dependencies\discord-rpc\win32-dynamic\bin\discord-rpc.dll" "Distribute\DiscordRichPresence\"
    
    if exist "%CD%\DiscordRichPresence\dependencies\discord-rpc\win32-dynamic\bin\send-presence.exe" (
        copy /Y "DiscordRichPresence\dependencies\discord-rpc\win32-dynamic\bin\send-presence.exe" "Distribute\DiscordRichPresence\"
    )
) else (
    echo WARNING: 32-bit Discord RPC files not found in project directory.
    echo The release package may be incomplete.
    
    :: Fall back to vcpkg if available
    if exist "vcpkg_installed\x86-windows\bin\discord-rpc.dll" (
        copy /Y "vcpkg_installed\x86-windows\bin\discord-rpc.dll" "Distribute\DiscordRichPresence\"
    ) else if exist "vcpkg_installed\x64-windows\bin\discord-rpc.dll" (
        echo WARNING: Using 64-bit Discord RPC DLL. This may not work with 32-bit Winamp.
        copy /Y "vcpkg_installed\x64-windows\bin\discord-rpc.dll" "Distribute\DiscordRichPresence\"
    )
)

:: Copy settings.ini to the DiscordRichPresence subfolder
copy settings.ini Distribute\DiscordRichPresence\settings.ini

:: Create an empty default settings.ini in the base directory as a fallback
echo # Discord Rich Presence configuration > Distribute\settings.ini
echo ##################################### >> Distribute\settings.ini
echo DisplayTitleInStatus:true >> Distribute\settings.ini
echo ShowElapsedTime:true >> Distribute\settings.ini
echo ApplicationID:0 >> Distribute\settings.ini

:: Copy the plugin DLL
copy x64\Release\DiscordRichPresence.dll Distribute\gen_DiscordRichPresence.dll 2>nul
copy Release\DiscordRichPresence.dll Distribute\gen_DiscordRichPresence.dll 2>nul

echo Creating ZIP file...
if exist "C:\Program Files\7-Zip\7z.exe" (
    %ZIP_UTILITY% a Distribute.zip Distribute\
) else (
    powershell -command "Compress-Archive -Path 'Distribute\*' -DestinationPath 'Distribute.zip' -Force"
)

echo Release created successfully!
