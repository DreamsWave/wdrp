#include "stdafx.h"
// #include "DiscordRichPresence.h" // Commented out to avoid circular reference
#include "SettingsFile.h"
#include "IniFile.h"
#include <windows.h>
#include <shlwapi.h>
#include <shlobj.h>
#include <string>
#include <fstream>

// Remove reference to DiscordRichPresence.h to avoid circular dependency
// #include "DiscordRichPresence.h" // For g_plugin

PluginSettings g_pluginSettings;

void GetPluginDllPath(char* filePath, int maxPath)
{
	// Use GetModuleFileName without a specific handle to get the executable path
	if (GetModuleFileNameA(NULL, filePath, maxPath) == 0) {
		// Failed to get path
		filePath[0] = '\0';
		return;
	}

	// Find last backslash
	char* lastBackslash = strrchr(filePath, '\\');
	if (lastBackslash) {
		*lastBackslash = '\0'; // Truncate at last backslash
	}
}

// Get the user's AppData folder for storing settings
bool GetAppDataPath(char* filePath, int maxPath)
{
	// Get the AppData\Roaming folder path
	if (SUCCEEDED(SHGetFolderPathA(NULL, CSIDL_APPDATA, NULL, 0, filePath))) {
		// Append our app folder
		strcat_s(filePath, maxPath, "\\WinampDiscordRichPresence");
		
		// Create the directory if it doesn't exist
		if (!CreateDirectoryA(filePath, NULL) && GetLastError() != ERROR_ALREADY_EXISTS) {
			return false;
		}
		
		// Append the settings file name
		strcat_s(filePath, maxPath, "\\settings.ini");
		return true;
	}
	return false;
}

void GetSettingsFilePath(char* filePath, int maxPath)
{
	// First try to get the path to the Winamp executable
	char basePath[MAX_PATH];
	GetPluginDllPath(basePath, MAX_PATH);
	
	if (basePath[0] != '\0') {
		// Try to use the standard Winamp plugin folder structure
		char testPath[MAX_PATH];
		strcpy_s(testPath, MAX_PATH, basePath);
		strcat_s(testPath, MAX_PATH, "\\Plugins\\DiscordRichPresence\\settings.ini");
		
		// Test if this file exists or we can create it
		HANDLE hFile = CreateFileA(testPath, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
		if (hFile != INVALID_HANDLE_VALUE) {
			CloseHandle(hFile);
			strcpy_s(filePath, maxPath, testPath);
			return;
		}
		
		// Try fallback location
		strcpy_s(testPath, MAX_PATH, basePath);
		strcat_s(testPath, MAX_PATH, "\\Plugins\\settings.ini");
		
		hFile = CreateFileA(testPath, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
		if (hFile != INVALID_HANDLE_VALUE) {
			CloseHandle(hFile);
			strcpy_s(filePath, maxPath, testPath);
			return;
		}
		
		// If we couldn't write to the Plugins folder, try AppData
		char appDataPath[MAX_PATH];
		if (GetAppDataPath(appDataPath, MAX_PATH)) {
			strcpy_s(filePath, maxPath, appDataPath);
			return;
		}
	}

	// Last resort: current directory
	strcpy_s(filePath, maxPath, "settings.ini");
}

bool LoadSettingsFile()
{
	// Set defaults first, in case we can't load settings
	g_pluginSettings.DisplayTitleInStatus = true;
	g_pluginSettings.ShowElapsedTime = true;
	g_pluginSettings.ApplicationID = "0";

	char filePath[MAX_PATH];
	GetSettingsFilePath(filePath, MAX_PATH);

	// Try to load from standard location
	if (IniFileExists(filePath) && LoadSettingsFromFile(filePath)) {
		return true;
	}

	// Try AppData as a fallback
	char appDataPath[MAX_PATH];
	if (GetAppDataPath(appDataPath, MAX_PATH) && IniFileExists(appDataPath) && LoadSettingsFromFile(appDataPath)) {
		// If we loaded from AppData, update the path to save back to the same place
		return true;
	}

	// Create a new settings file with defaults
	SaveSettingsFile();
	return false;
}

bool LoadSettingsFromFile(const char* filePath)
{
	if (!IniFileExists(filePath)) {
		return false;
	}

	// Note: Default values if not in the file
	char windowTitle[256];
	LoadStringFromIniFile(filePath, "Settings", "DisplayTitleInStatus", windowTitle, 256, "true");
	g_pluginSettings.DisplayTitleInStatus = StringToBool(windowTitle);

	char elapsed[256];
	LoadStringFromIniFile(filePath, "Settings", "ShowElapsedTime", elapsed, 256, "true");
	g_pluginSettings.ShowElapsedTime = StringToBool(elapsed);

	char applicationID[256];
	LoadStringFromIniFile(filePath, "Settings", "ApplicationID", applicationID, 256, "0");
	
	// Only update Application ID if it's not empty or "0"
	// This way, we don't overwrite a good ID with the default
	if (strlen(applicationID) > 1 && strcmp(applicationID, "0") != 0) {
		g_pluginSettings.ApplicationID = applicationID;
	}

	return true;
}

bool SaveSettingsFile()
{
	// Try the standard location first
	char filePath[MAX_PATH];
	GetSettingsFilePath(filePath, MAX_PATH);

	// Try to save to the standard location
	if (SaveSettingsToFile(filePath)) {
		return true;
	}

	// If we can't save to the standard location, try AppData
	char appDataPath[MAX_PATH];
	if (GetAppDataPath(appDataPath, MAX_PATH) && SaveSettingsToFile(appDataPath)) {
		return true;
	}

	// If we still couldn't save, try the current directory
	return SaveSettingsToFile("settings.ini");
}

bool SaveSettingsToFile(const char* filePath)
{
	// Ensure directory exists
	char dirPath[MAX_PATH];
	strcpy_s(dirPath, MAX_PATH, filePath);
	
	// Find last backslash to get directory
	char* lastSlash = strrchr(dirPath, '\\');
	if (lastSlash) {
		*lastSlash = '\0'; // Null terminate to get directory path
		CreateDirectoryA(dirPath, NULL);
	}

	// Try to open the file for writing
	HANDLE hFile = CreateFileA(filePath, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE) {
		return false;
	}
	CloseHandle(hFile);

	// Write each setting
	SaveBoolToIniFile(filePath, "Settings", "DisplayTitleInStatus", g_pluginSettings.DisplayTitleInStatus);
	SaveBoolToIniFile(filePath, "Settings", "ShowElapsedTime", g_pluginSettings.ShowElapsedTime);
	SaveStringToIniFile(filePath, "Settings", "ApplicationID", g_pluginSettings.ApplicationID.c_str());

	// Ensure file is not read-only
	SetFileAttributesA(filePath, FILE_ATTRIBUTE_NORMAL);
	
	// Flush any cached writes to ensure the file is written to disk
	HANDLE fileHandle = CreateFileA(filePath, GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (fileHandle != INVALID_HANDLE_VALUE) {
		FlushFileBuffers(fileHandle);
		CloseHandle(fileHandle);
		return true;
	}

	return false;
}