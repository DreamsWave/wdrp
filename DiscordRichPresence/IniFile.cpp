#include "stdafx.h"
#include "IniFile.h"
#include <windows.h>

bool IniFileExists(const char* filePath)
{
    return GetFileAttributesA(filePath) != INVALID_FILE_ATTRIBUTES;
}

bool LoadStringFromIniFile(const char* filePath, const char* section, const char* key, char* value, int valueSize, const char* defaultValue)
{
    DWORD result = GetPrivateProfileStringA(section, key, defaultValue, value, valueSize, filePath);
    return result > 0;
}

bool SaveStringToIniFile(const char* filePath, const char* section, const char* key, const char* value)
{
    return WritePrivateProfileStringA(section, key, value, filePath) != 0;
}

bool SaveBoolToIniFile(const char* filePath, const char* section, const char* key, bool value)
{
    return WritePrivateProfileStringA(section, key, value ? "true" : "false", filePath) != 0;
}

bool StringToBool(const char* value)
{
    if (!value)
        return false;
        
    if (_stricmp(value, "true") == 0 || 
        _stricmp(value, "yes") == 0 || 
        _stricmp(value, "1") == 0 ||
        _stricmp(value, "on") == 0)
        return true;
    
    return false;
} 