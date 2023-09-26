# League Of Languages Script
# Version: 2.0.0
# Author: KuryKat
# License: GPLv3

<#
Description:
This script creates a shortcut for the League of Legends client with a specified language.

CHECK THE WIKI (https://github.com/KuryKat/LeagueOfLanguages/wiki) FOR MORE INFORMATION!!

Usage:
1. Run the script using PowerShell.
2. Choose a Language from the Menu using the Arrow Keys
3. A shortcut with your chosen language will be created on your desktop.

Disclaimer:
League Of Languages is an independent project and is not affiliated with or endorsed by Riot Games, Inc. League Of Legends and related trademarks are the property of Riot Games, Inc. Please be aware that the name "League Of Languages" is used solely for the purpose of describing the functionality of this script and does not imply any official association with Riot Games.

License:
This script is released under the GPLv3 License. See the "LICENSE" file for details.
#>

# The path to your Desktop folder
# Only change this if you have your Desktop on another Disk!
# Default Value for Windows: "$HOME/Desktop"
$DESKTOP_PATH = "D:/repos/Personal-Projects/LeagueOfLanguages"

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

###########################################################################
#                                                                         # 
# AVOID EDITING ANYTHING BELOW THIS IF YOU DON'T KNOW WHAT YOU'RE DOING!! #
#                                                                         # 
###########################################################################

# An Array containing all the Locale Codes
$LOCALE_CODES = @(
    "zh_CN",
    "en_AU",
    "en_GB",
    "en_US",
    "fr_FR",
    "de_DE",
    "el_GR",
    "hu_HU",
    "it_IT",
    "ja_JP",
    "ko_KR",
    "pl_PL",
    "pt_BR",
    "ro_RO",
    "ru_RU",
    "es_MX",
    "es_ES",
    "zh_TW",
    "tr_TR"
)

# An Array containing all the Locale Names
$LOCALE_NAMES = @(
    "Chinese",
    "English Australian",
    "English Great Britain",
    "English USA",
    "French",
    "German",
    "Greek",
    "Hungarian",
    "Italian",
    "Japanese",
    "Korean",
    "Polish",
    "Portuguese",
    "Romanian",
    "Russian",
    "Spanish Latin America",
    "Spanish Spain",
    "Taiwanese",
    "Turkish"
)

# An Array containing all the Menu Options
$MenuOptions = @()
for ($i = 0; $i -lt $LOCALE_CODES.Length; $i++) {
    $LOCALE_CODE = $LOCALE_CODES[$i]
    $LOCALE_NAME = $LOCALE_NAMES[$i]
    
    $MenuOptions += "($LOCALE_CODE) $LOCALE_NAME"
}

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

# A very Neat Log function
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

# A very Neat Menu function
function Get-MenuSelection {
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$MenuItems,
        [Parameter(Mandatory = $true)]
        [String]$MenuPrompt
    )
    $cursorPosition = $host.UI.RawUI.CursorPosition
    $pos = 0

    function Write-Menu {
        param (
            [int]$selectedItemIndex
        )
        $Host.UI.RawUI.CursorPosition = $cursorPosition
        $prompt = $MenuPrompt
        $maxLineLength = ($MenuItems | Measure-Object -Property Length -Maximum).Maximum + 4
        while ($prompt.Length -lt $maxLineLength + 4) {
            $prompt = " $prompt "
        }
        Write-Host $prompt -ForegroundColor Green
        for ($i = 0; $i -lt $MenuItems.Count; $i++) {
            $line = "    $($MenuItems[$i])" + (" " * ($maxLineLength - $MenuItems[$i].Length))
            if ($selectedItemIndex -eq $i) {
                Write-Host $line -ForegroundColor Blue -BackgroundColor Gray
            }
            else {
                Write-Host $line
            }
        }
    }

    Write-Menu -selectedItemIndex $pos
    $key = $null
    while ($key -ne 13) {
        $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        $key = $press.virtualkeycode
        if ($key -eq 0) {
            Write-Log -level INFO -message "^C"
            Write-Log -level VERBOSE -message "Terminated"
            pause
            exit
        }
        if ($key -eq 38) {
            $pos--
        }
        if ($key -eq 40) {
            $pos++
        }
        if ($pos -lt 0) { $pos = $MenuItems.count - 1 }
        if ($pos -eq $MenuItems.count) { $pos = 0 }

        Write-Menu -selectedItemIndex $pos
    }

    return $pos
}

function New-LeagueClient-Shortcut {
	param ( 
        [string]$DestinationPath 		= "$DESKTOP_PATH/$SHORTCUT_NAME.lnk", 
        [string]$DestinationDescription	= "$SHORTCUT_NAME", 
        [string]$SourceExe 				= "$LEAGUE_CLIENT_LOCATION", 
        [string]$ArgumentsToSourceExe 	= "--locale=$LOCALE"
	)

    $WshShell = New-Object -comObject WScript.Shell

    Write-Log -level DEBUG -message "Creating Shortcut at '$DestinationPath'"
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
    
    $LOCALE = $LOCALE_CODES[
        $(
            Get-MenuSelection `
                -MenuItems $MenuOptions `
                -MenuPrompt "Which language do you want? (Use Arrow Keys)"
        )
    ]

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
