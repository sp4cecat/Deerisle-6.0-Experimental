# --- KONFIGURATION ---
$jsonPath = "D:\SteamLibrary\steamapps\common\DayZ\mpmissions\empty.deerisle\NIO\Deerisle\halloffame.json"
$webhookUrl = "INSERT YOUR WEBHOOK LINK URL HERE" 
# ---------------------

# Define Emojis via Code (Safe for all Windows versions)
$EmojiRocket  = [char]::ConvertFromUtf32(0x1F680) # 🚀
$EmojiGold    = [char]::ConvertFromUtf32(0x1F947) # 🥇
$EmojiSilver  = [char]::ConvertFromUtf32(0x1F948) # 🥈
$EmojiBronze  = [char]::ConvertFromUtf32(0x1F949) # 🥉
$EmojiMap     = [char]::ConvertFromUtf32(0x1F5FA) # 🗺️
$EmojiZap     = [char]::ConvertFromUtf32(0x26A1)  # ⚡
$EmojiSearch  = [char]::ConvertFromUtf32(0x1F50D) # 🔍

# Helper function to send data to Discord using UTF-8 bytes
function Send-ToDiscord {
    param ($PayloadContent)
    try {
        $jsonPayload = $PayloadContent | ConvertTo-Json -Depth 4
        # Force UTF-8 encoding so emojis don't break
        $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)
        Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json; charset=utf-8' -Body $utf8Bytes
    }
    catch {
        Write-Host "Error sending to Discord: $($_.Exception.Message)" -ForegroundColor Red
    }
}

try {
    # 1. CHECK: Does the file exist?
    if (-Not (Test-Path $jsonPath)) {
        
        # SCENARIO A: File missing -> Send Challenge Message
        Write-Host "File missing. Sending 'Challenge' message..." -ForegroundColor Yellow
        
        $payload = @{
            username = "Deer Isle Bot"
            embeds = @(
                @{
                    title = "$EmojiRocket Deer Isle Speedrun"
                    description = "$EmojiSearch **No entries found yet!**`n`nThe Hall of Fame is empty. Who will be the first survivor to conquer the island?`n`n**Login and start the run!**"
                    color = 9807270 # Grey (Neutral)
                    footer = @{ text = "Status: Waiting for the first champion..." }
                }
            )
        }
        Send-ToDiscord -PayloadContent $payload
        exit
    }

    # 2. Read JSON
    $jsonData = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

    # CHECK 2: File exists, but is the list empty?
    if ($null -eq $jsonData.Survivors -or $jsonData.Survivors.Count -eq 0) {
        Write-Host "File is empty. Sending 'Challenge' message..." -ForegroundColor Yellow
        
        $payload = @{
            username = "Deer Isle Bot"
            embeds = @(
                @{
                    title = "$EmojiRocket Deer Isle Speedrun"
                    description = "$EmojiSearch **No entries found yet!**`n`nThe Hall of Fame is empty. Who will be the first survivor to conquer the island?`n`n**Login and start the run!**"
                    color = 9807270 # Grey
                    footer = @{ text = "Status: Waiting for the first champion..." }
                }
            )
        }
        Send-ToDiscord -PayloadContent $payload
        exit
    }

    # 3. Sort Data (Speedrun Logic)
    #    Priority A: DiscoveryProgress -> Descending (High % is best)
    #    Priority B: SurvivalTimeSeconds -> Ascending (Low time is best)
    $sortedSurvivors = $jsonData.Survivors | Sort-Object -Property @{Expression="DiscoveryProgress"; Descending=$true}, @{Expression="SurvivalTimeSeconds"; Descending=$false}

    $totalCount = $sortedSurvivors.Count
    
    # 4. Loop through data in chunks of 10
    for ($i = 0; $i -lt $totalCount; $i += 10) {
        
        # Select the next 10 players
        $chunk = $sortedSurvivors | Select-Object -Skip $i -First 10
        
        $description = ""
        $rank = $i + 1

        foreach ($survivor in $chunk) {
            # Assign medals
            $rankText = switch ($rank) { 1 {$EmojiGold} 2 {$EmojiSilver} 3 {$EmojiBronze} Default {"**#$rank**"} }
            
            # Entry Format: Rank Name | Map % | Time
            $description += "$rankText **$($survivor.Name)**`n" + 
                            "$EmojiMap **$([math]::Round($survivor.DiscoveryProgress, 1))%** | $EmojiZap $($survivor.SurvivalTime)`n`n"
            $rank++
        }

        # Build Title
        $endRank = $rank - 1
        $title = "$EmojiRocket Deer Isle Speedrun (Rank $($i + 1) - $endRank)"

        $payload = @{
            username = "Deer Isle Bot"
            embeds = @(
                @{
                    title = $title
                    description = $description
                    color = 16711680 # Red (Action/Speed)
                    footer = @{ text = "Page $([math]::Floor($i/10)+1) | Total: $totalCount Players" }
                }
            )
        }

        Send-ToDiscord -PayloadContent $payload
        
        Write-Host "Sent block $($i + 1) to $endRank." -ForegroundColor Cyan
        
        # Pause to avoid Discord Rate Limits
        Start-Sleep -Seconds 1
    }

    Write-Host "Done! All pages sent successfully." -ForegroundColor Green
}
catch {
    Write-Host "Critical Error: $($_.Exception.Message)" -ForegroundColor Red
}