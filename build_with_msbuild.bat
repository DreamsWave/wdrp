@echo off
setlocal

:: Set configuration
set CONFIG=Release
if not "%1"=="" set CONFIG=%1

echo Building in %CONFIG% configuration...

:: Find MSBuild
set MSBUILD_PATH=
for %%v in (Current 2022 2019 2017) do (
    for %%e in (Enterprise Professional Community BuildTools) do (
        if exist "C:\Program Files\Microsoft Visual Studio\%%v\%%e\MSBuild\Current\Bin\MSBuild.exe" (
            set "MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\%%v\%%e\MSBuild\Current\Bin\MSBuild.exe"
            goto :found_msbuild
        )
        if exist "C:\Program Files (x86)\Microsoft Visual Studio\%%v\%%e\MSBuild\Current\Bin\MSBuild.exe" (
            set "MSBUILD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\%%v\%%e\MSBuild\Current\Bin\MSBuild.exe"
            goto :found_msbuild
        )
        if exist "C:\Program Files (x86)\Microsoft Visual Studio\%%v\%%e\MSBuild\15.0\Bin\MSBuild.exe" (
            set "MSBUILD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\%%v\%%e\MSBuild\15.0\Bin\MSBuild.exe"
            goto :found_msbuild
        )
    )
)

echo MSBuild not found. Please install Visual Studio with C++ development tools.
exit /b 1

:found_msbuild
echo Found MSBuild: %MSBUILD_PATH%

:: Build solution
echo Building solution...
"%MSBUILD_PATH%" DiscordRichPresence.sln /p:Configuration=%CONFIG% /p:Platform=x86 /p:VcpkgEnabled=true /p:VcpkgEnableManifest=true

if %ERRORLEVEL% NEQ 0 (
    echo Build failed with error level %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

:: Copy the built DLL with gen_ prefix to match Winamp's expectations
if exist "x86\%CONFIG%\DiscordRichPresence.dll" (
    echo Copying to gen_DiscordRichPresence.dll...
    copy /Y "x86\%CONFIG%\DiscordRichPresence.dll" "%CONFIG%\gen_DiscordRichPresence.dll"
)

echo Build completed successfully.

:: Run the CopyToInstall script to deploy
echo.
echo Do you want to deploy to Winamp? (Y/N)
set /p DEPLOY=
if /i "%DEPLOY%"=="Y" (
    cmd /c CopyToInstall.cmd
)

exit /b 0 