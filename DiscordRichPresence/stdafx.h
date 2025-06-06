// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers

// For 64-bit compatibility
#ifdef _WIN64
  #ifndef GWL_WNDPROC
    #define GWL_WNDPROC GWLP_WNDPROC
  #endif
  #ifndef GWL_HINSTANCE
    #define GWL_HINSTANCE GWLP_HINSTANCE
  #endif
  #ifndef GWL_HWNDPARENT
    #define GWL_HWNDPARENT GWLP_HWNDPARENT
  #endif
  #ifndef GWL_STYLE
    #define GWL_STYLE GWLP_STYLE
  #endif
  #ifndef GWL_USERDATA
    #define GWL_USERDATA GWLP_USERDATA
  #endif
  #ifndef GWL_ID
    #define GWL_ID GWLP_ID
  #endif
#endif

// Windows Header Files (SDK version 10.0.17134.0):
#include <windows.h>
#include <windowsx.h>
#include <commctrl.h>

// Winamp plugin
#include <wa_ipc.h>

// Discord API
#include "../vcpkg_installed/x64-windows/include/discord_rpc.h"

// STL (v141 toolset)
#include <string>
#include <codecvt>
#include <sstream>
#include <fstream>
#include <assert.h>
#include <chrono>
#include <vector>
#include <locale>

#define _CRT_SECURE_NO_WARNINGS