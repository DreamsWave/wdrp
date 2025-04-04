#pragma once

struct PluginSettings
{
	bool DisplayTitleInStatus;
	bool ShowElapsedTime;
	std::string ApplicationID;
};

// Gets the path to the settings file
void GetSettingsFilePath(char* filePath, int maxPath);

// Gets the path to the plugin DLL
void GetPluginDllPath(char* filePath, int maxPath);

// Gets the AppData folder path for settings
bool GetAppDataPath(char* filePath, int maxPath);

// Attempts to save our settings file
bool SaveSettingsFile();

// Attempts to save settings to a specific file
bool SaveSettingsToFile(const char* filePath);

// Attempts to load our settings file or create it if it doesn't exist
bool LoadSettingsFile();

// Attempts to load settings from a specific file
bool LoadSettingsFromFile(const char* filePath);

extern PluginSettings g_pluginSettings;