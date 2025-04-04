#pragma once

// Functions for reading/writing INI files
bool IniFileExists(const char* filePath);
bool LoadStringFromIniFile(const char* filePath, const char* section, const char* key, char* value, int valueSize, const char* defaultValue);
bool SaveStringToIniFile(const char* filePath, const char* section, const char* key, const char* value);
bool SaveBoolToIniFile(const char* filePath, const char* section, const char* key, bool value);
bool StringToBool(const char* value); 