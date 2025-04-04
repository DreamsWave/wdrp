@echo off
IF NOT [%~1]==[] (
    set BUILD_CONFIGURATION=%~1
)
IF NOT DEFINED BUILD_CONFIGURATION set BUILD_CONFIGURATION=Release

echo Building in '%BUILD_CONFIGURATION%' mode

mkdir "../%BUILD_CONFIGURATION%/" 2>nul

REM Find the installed Windows SDK version
for /f "tokens=3 delims= " %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows Kits\Installed Roots" /s ^| findstr "KitsRoot10" ^| findstr "InstallPath"') do (
    set WindowsKitsRoot=%%a
)

REM Find the latest Windows SDK version
for /f "tokens=* delims=" %%a in ('dir "%WindowsKitsRoot%\Include" /b /o-n') do (
    set winsdk_ver=%%a
    goto :found_sdk
)
:found_sdk

echo Using Windows SDK version: %winsdk_ver%

REM Create resource file for the Config/UI
set rc_path="%WindowsKitsRoot%\bin\%winsdk_ver%\x64\rc.exe"
%rc_path% /I "%WindowsKitsRoot%\Include\%winsdk_ver%\um" ^
/I "%WindowsKitsRoot%\Include\%winsdk_ver%\shared" Config.rc

REM Set Path/Env variables that cl.exe needs
set vcvarsall=x64 -vcvars_ver=latest
IF exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" %vcvarsall%
) ELSE IF exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" %vcvarsall%
) ELSE IF exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" %vcvarsall%
) ELSE IF exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" %vcvarsall%
) ELSE IF exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" %vcvarsall%
) ELSE IF exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" %vcvarsall%
) ELSE (
    echo Visual Studio not found. Please install Visual Studio 2019 or 2022.
    exit /b 1
)

REM Set include paths using detected SDK
set includepaths=/I "%WindowsKitsRoot%\Include\%winsdk_ver%\um" ^
/I "%WindowsKitsRoot%\Include\%winsdk_ver%\ucrt" ^
/I "%WindowsKitsRoot%\Include\%winsdk_ver%\shared" ^
/I "../vcpkg_installed/x64-windows/include"

REM Set CL.exe flags
IF NOT BUILD_CONFIGURATION == Release (
    REM Optimization disabled, no function level linking, no intrinsic functions
    set buildflags=/Od /Yc /Gy /Oi /W3
) ELSE (
    set buildflags=/O2 /Gy /W3
)
set compilerflags=/nologo %buildflags% /DUNICODE /DWIN32 /DDEBUG /DDISCORDRICHPRESENCE_EXPORTS /D_WINDOWS /D_USRDLL /D_WINDLL /EHsc /std:c++17 %includepaths%
set linkerflags=/DLL /OUT:"../%BUILD_CONFIGURATION%/gen_DiscordRichPresence.dll" User32.LIB Config.res

echo Using build flags: %buildflags%

cl.exe %compilerflags% *.cpp /link %linkerflags%

REM Cleanup
del *.ilk *.obj *.pdb *.lib *.pch *.exp Config.res RCa22352 2>nul