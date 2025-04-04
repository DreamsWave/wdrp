# Winamp Discord Rich Presence

This plugin adds Discord Rich Presence integration to Winamp, showing what you're currently playing in your Discord status.

![Discord Rich Presence Example](Images/screenshot.png)

## Features

- Shows currently playing track in Discord
- Displays play/pause status
- Shows elapsed time (optional)
- Customizable Discord Application ID
- Full Unicode support for Japanese, Korean, Chinese and other non-Latin characters

## Requirements

- Winamp 5.8 or newer
- Discord desktop application (not the web version)
- Visual Studio 2019 or 2022 with C++ development workload
- Windows 10 or 11

## Installation

### Method 1: Using the pre-built release

1. Download the latest release from the [Releases](https://github.com/yourusername/wdrp/releases) page
2. Extract the ZIP file
3. Copy `gen_DiscordRichPresence.dll` to your Winamp plugins folder (usually `C:\Program Files (x86)\Winamp\Plugins`)
4. Copy the `DiscordRichPresence` folder to your Winamp plugins folder
5. Restart Winamp

### Method 2: Building from source

#### Prerequisites

- Visual Studio 2019 or 2022 with C++ development workload
- Git for Windows
- Administrator privileges (for deployment)

#### Build Steps

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/wdrp.git
   cd wdrp
   ```

2. Open the solution in Visual Studio:

   ```
   DiscordRichPresence.sln
   ```

3. Set the build configuration to `Release` and platform to `x86` or `Win32`

4. Build the solution (F7 or Build > Build Solution)

5. Deploy to Winamp (requires administrator privileges):

   - Right-click on Command Prompt > "Run as administrator"
   - Navigate to the project directory:
     ```
     cd path\to\wdrp
     ```
   - Run the deployment script:
     ```
     CopyToInstall.cmd
     ```

6. Restart Winamp

## Configuration

1. Open Winamp and go to Preferences (Ctrl+P)
2. Navigate to Plugins > General Purpose
3. Find "Discord Rich Presence" and click "Configure"
4. Set your Discord Application ID (create one at https://discord.com/developers/applications)
5. Choose whether to display the track title and elapsed time
6. Click OK to save your settings

## Discord Application Setup

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Click "New Application" and give it a name (e.g., "Winamp")
3. Copy the Application ID
4. Optionally, add images for Rich Presence under "Rich Presence" > "Art Assets"
5. Enter the Application ID in the plugin configuration

## Troubleshooting

- **Plugin doesn't appear in Winamp**: Make sure the DLL is properly copied to the Plugins folder and named `gen_DiscordRichPresence.dll`
- **No Discord status**: Ensure Discord desktop app is running and "Game Activity" is enabled in Discord Settings > Activity Settings
- **Non-Latin characters appear as question marks**: Make sure you're using the latest version of the plugin which includes full Unicode support

## Changelog

### Version 1.1

- Added full Unicode support for Japanese, Korean, Chinese and other non-Latin characters
- Improved error handling for text encoding conversions
- Fixed streaming title display

## License

[Include your license information here]

## Credits

- [Your Name]
- [Any contributors or libraries used]
