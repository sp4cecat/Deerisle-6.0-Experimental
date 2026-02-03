================================================================================
          DAYZ HALL OF FAME TRACKER (MULTI-SERVER) - DISCORD BOT
                      INSTALLATION & USAGE MANUAL
================================================================================

Version: 2.0
Language: PowerShell (Windows)
Filename: deerisle_halloffame_to_discord.ps1

[ TABLE OF CONTENTS ]
--------------------------------------------------------------------------------
1. OVERVIEW & FEATURES
2. PREREQUISITES
3. INSTALLATION
4. CONFIGURATION (IMPORTANT!)
5. MANUAL TESTING
6. AUTOMATION (TASK SCHEDULER)
7. TROUBLESHOOTING & FAQ

================================================================================
1. OVERVIEW & FEATURES
================================================================================
This tool reads `halloffame.json` files from one or multiple DayZ servers,
combines the data, and posts a formatted "Speedrun Leaderboard" to a specific
Discord channel.

New Features in Version 2.0:
- Multi-Server Support: Combines player data from Deer Isle, Alteria, etc.
- Smart Updates: Edits existing Discord messages instead of spamming new ones.
- Timestamps: Displays the date and time of the entry (Calendar Emoji).
- Pagination: Automatically splits long lists into multiple messages.
- Cleanup: Automatically deletes old messages if the list becomes shorter.
- Safety Checks: Validates the Webhook URL before starting to prevent errors.

================================================================================
2. PREREQUISITES
================================================================================
1. OS: Windows Server 2016/2019/2022 or Windows 10/11.
2. PowerShell: Version 5.1 or newer (Standard on Windows).
3. Data Sources: Valid paths to the `halloffame.json` files of your servers.
4. Discord: A Webhook URL for the channel where you want the stats posted.

   -> HOW TO GET A WEBHOOK URL:
   1. Open Discord -> Right-click your channel -> "Edit Channel".
   2. Go to "Integrations" -> "Webhooks".
   3. Click "New Webhook", name it (e.g., "Leaderboard Bot").
   4. Click "Copy Webhook URL".

================================================================================
3. INSTALLATION
================================================================================
1. Open a text editor (Notepad, Notepad++, VS Code).
2. Copy the complete PowerShell script code provided in the chat.
3. Save the file with the exact name:
   
   deerisle_halloffame_to_discord.ps1

   Recommended Path (Example):
   D:\Tools\DiscordBot\deerisle_halloffame_to_discord.ps1

   NOTE: The script will automatically create a file named `bot_data.json`
   in the same folder. This file stores the message IDs for editing.

================================================================================
4. CONFIGURATION
================================================================================
You must edit the script before running it.

1. Right-click `deerisle_halloffame_to_discord.ps1` -> "Edit".
2. Locate the "--- KONFIGURATION ---" block at the very top.

STEP A: Add Server Files ($serverFiles)
   Enter the paths to your JSON files here. Ensure lines end with a comma
   (except for the last line).

   Example:
   $serverFiles = @(
       "D:\DayZ\Deerisle\Profiles\halloffame.json",
       "D:\DayZ\Alteria\Profiles\halloffame.json" 
   )

STEP B: Add Webhook URL ($Global:MyDiscordUrl)
   Paste your copied Discord URL between the quotation marks.

   Example:
   $Global:MyDiscordUrl = "https://discord.com/api/webhooks/12345/abcdef..."

3. Save the file.

================================================================================
5. MANUAL TESTING
================================================================================
It is highly recommended to run the script manually once to ensure it works.

1. Press `Windows Key`, type "PowerShell", and press Enter.
2. Navigate to your folder:
   cd "D:\Tools\DiscordBot\"

3. Run the script (Bypass prevents permission errors):
   PowerShell.exe -ExecutionPolicy Bypass -File .\deerisle_halloffame_to_discord.ps1

4. Check the Console Output:
   - "--- SYSTEM CHECK ---": Verifies if the URL was loaded correctly.
   - "Erstelle neue Seite X...": Sends the message for the first time.
   - "Aktualisiere Seite X...": Edits an existing message (on 2nd run).
   - "Fertig! Datenbank aktualisiert.": Success.

5. Check Discord:
   You should see the leaderboard with emojis and timestamps.

================================================================================
6. AUTOMATION (TASK SCHEDULER)
================================================================================
To make the bot update automatically (e.g., every 10 minutes):

1. Press `Win + R`, type `taskschd.msc`, and hit Enter.
2. Right-click -> "Create Basic Task...".
3. Name: "DayZ Leaderboard Bot". Click Next.
4. Trigger: "Daily" (you can change the interval later). Click Next.
5. Action: "Start a program". Click Next.

6. Configure Program/Script (CRITICAL STEP):
   
   - Program/script:
     PowerShell.exe

   - Add arguments (optional):
     -ExecutionPolicy Bypass -File "D:\Tools\DiscordBot\deerisle_halloffame_to_discord.ps1"
     *(The path must point exactly to your file)*

   - Start in (optional):
     D:\Tools\DiscordBot\
     *(The folder containing the script - do NOT use quotes here)*

7. Click Finish.
8. (Optional) Double-click the task -> "Triggers" tab -> Edit.
   Check "Repeat task every:" -> Select "10 minutes" (or "1 hour").

================================================================================
7. TROUBLESHOOTING & FAQ
================================================================================

[ERROR] "Invalid URI: The hostname could not be parsed"
-> Your Webhook URL is incorrect or empty.
-> Check the variable `$Global:MyDiscordUrl` in the script.
-> Ensure there are no spaces at the start or end of the URL.

[ERROR] "Warning: Could not read bot_data.json"
-> This is normal during the very first run because the file does not exist yet.
-> If this persists: Delete `bot_data.json` manually from the folder.

[QUESTION] Why is there no new message when I restart the script?
-> The script uses "Smart Updates". It edits the old message to keep the channel
   clean. Look for the "(edited)" tag in Discord.
-> If you want a completely new message, delete the message in Discord AND
   delete the `bot_data.json` file in the script folder.

[ERROR] "Fehler beim Lesen von [Path]" (Error reading path)
-> The path in `$serverFiles` is incorrect, or the server has locked the file
   for writing. The script will ignore this error and continue.

================================================================================