# League Of Languages Script
# Version: 1.0.0
# Author: KuryKat
# License: GPLv3

<#
Description:
This script creates a shortcut for the League of Legends client with a specified language.

Usage:
1. Edit the variables in this script to customize your preferences.
2. Run the script using PowerShell.
3. A shortcut with your chosen language will be created on your desktop.

Disclaimer:
League Of Languages is an independent project and is not affiliated with or endorsed by Riot Games, Inc. League Of Legends and related trademarks are the property of Riot Games, Inc. Please be aware that the name "League Of Languages" is used solely for the purpose of describing the functionality of this script and does not imply any official association with Riot Games.

License:
This script is released under the GPLv3 License. See the "LICENSE" file for details.
#>

# Define your preferred language ( Locale List: https://rentry.co/league_locales )
# Default Value: "en_US"
$LOCALE="en_US"

# The path to your Desktop folder
# Only change this if you have your Desktop on another Disk!
# Default Value for Windows: "$HOME/Desktop"
$DESKTOP_PATH = "$HOME/Desktop"

# The League Client Location!
# Only change this if you installed the game on another Disk!
# Default Value for Windows: "C:/Riot Games/League of Legends/LeagueClient.exe"
$LEAGUE_CLIENT_LOCATION = "C:/Riot Games/League of Legends/LeagueClient.exe"

# The name for the shortcut!
# Note: If there is a file with the same name it is possible that the Shortcut 
# will not be created or that the shortcut will override said file!
# Note: This will also be used as the Description for the Shortcut!
# Default Value: "League of Legends"
$SHORTCUT_NAME = "League of Legends"

enum LogLevel {
    ERROR
    WARN
    SUCCESS
    INFO
    VERBOSE
    DEBUG
}

# Log File Path
# Default Value: "$DESKTOP_PATH/$($MyInvocation.MyCommand.Name).log"
$LOG_FILE_PATH = "$DESKTOP_PATH/$($MyInvocation.MyCommand.Name).log"

# Log Output Level
# Default Value:   "[LogLevel]::INFO"
$LOG_OUTPUT_LEVEL = [LogLevel]::INFO

function Clear-Log {
    Write-Log -level DEBUG -message "Clearing Log File"
    Clear-Content -Path $LOG_FILE_PATH
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string] $message,
        [Parameter(Mandatory = $false)][LogLevel] $level = [LogLevel]::INFO
    )

    $timestamp = (Get-Date).toString("ddMMMyyyy HH:mm:ss.fff")
    $parsedMessage = "[$timestamp] [$level] - $message"
    Add-Content -Path $LOG_FILE_PATH -Value "$parsedMessage"

    switch ($level) {
        "ERROR" {
            if ($LOG_OUTPUT_LEVEL -ge [LogLevel]::ERROR) {
                Write-Host
                Write-Host "$parsedMessage" -ForegroundColor Red
                # Write-Error "$message"
                Write-Host
                break
            }
        } 
        "WARN" {
            if ($LOG_OUTPUT_LEVEL -ge [LogLevel]::WARN) {
                Write-Host
                Write-Host "$parsedMessage" -ForegroundColor Yellow
                # Write-Warning "$message"
                Write-Host            
                break
            }
        } 
        "SUCCESS" {
            if ($LOG_OUTPUT_LEVEL -ge [LogLevel]::INFO) {
                Write-Host
                Write-Host "$parsedMessage" -ForegroundColor Green
                Write-Host
                break
            } 
        } 
        "INFO" {
            if ($LOG_OUTPUT_LEVEL -ge [LogLevel]::INFO) {
                Write-Host
                Write-Host "$parsedMessage" -ForegroundColor Blue
                Write-Host
                break
            } 
        } 
        "VERBOSE" {
            if ($LOG_OUTPUT_LEVEL -ge [LogLevel]::VERBOSE) {
                Write-Host
                Write-Host "$parsedMessage" -ForegroundColor DarkCyan
                # Write-Verbose "$message"
                Write-Host
                break
            }
        }
        "DEBUG" {
            if ($LOG_OUTPUT_LEVEL -ge [LogLevel]::DEBUG) {
                Write-Host
                Write-Host "$parsedMessage" -ForegroundColor Cyan
                # Write-Log -level DEBUG -message "$message"
                Write-Host
                break
            } 
        } 
    }
}

function New-LeagueClient-Shortcut {
	param ( 
        [string]$DestinationPath 		= "$DESKTOP_PATH/$SHORTCUT_NAME.lnk", 
        [string]$DestinationDescription	= "$SHORTCUT_NAME", 
        [string]$SourceExe 				= "$LEAGUE_CLIENT_LOCATION", 
        [string]$ArgumentsToSourceExe 	= "--locale=$LOCALE"
	)

    $WshShell = New-Object -comObject WScript.Shell

    Write-Log -level DEBUG -message "Creating Shortcut at $DestinationPath"
    $Shortcut = $WshShell.CreateShortcut($DestinationPath)

    Write-Log -level DEBUG -message "Shortcut Target: $SourceExe"
    $Shortcut.TargetPath   = $SourceExe

    Write-Log -level DEBUG -message "Shortcut Arguments: $ArgumentsToSourceExe"
    $Shortcut.Arguments    = $ArgumentsToSourceExe

    Write-Log -level DEBUG -message "Shortcut Description: $DestinationDescription"
    $Shortcut.Description  = $DestinationDescription
    
    Write-Log -level DEBUG -message "Saving Shortcut: $Shortcut"
    $Shortcut.Save()

}

try {
    Clear-Log
    Write-Log -level INFO -message "Starting Script..."
    New-LeagueClient-Shortcut
    Write-Log -level SUCCESS -message "Shortcut Created Successfully!"
    pause
} catch {
    Write-Log -level ERROR -message "Error on line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    Write-Log -level ERROR -message "Check the log file at '$LOG_FILE_PATH' to see more information!"
    pause
}
