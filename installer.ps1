# Brotato PCK Patcher (PowerShell Standalone)
param (
    [string]$GameDir = ""
)

$ErrorActionPreference = "Stop"

function Find-BrotatoPath {
    $candidates = @(
        "C:\Program Files (x86)\Steam\steamapps\common\Brotato",
        "C:\Program Files\Steam\steamapps\common\Brotato",
        "D:\SteamLibrary\steamapps\common\Brotato",
        "E:\SteamLibrary\steamapps\common\Brotato",
        "F:\SteamLibrary\steamapps\common\Brotato"
    )
    foreach ($path in $candidates) {
        if (Test-Path "$path\Brotato.pck") {
            return $path
        }
    }
    return ""
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$fontFile = Join-Path $scriptDir "anybody-medium-thai.ttf"

if (-not (Test-Path $fontFile)) {
    Write-Host "[ERROR] Font file not found: $fontFile" -ForegroundColor Red
    pause
    exit 1
}

if ([string]::IsNullOrWhiteSpace($GameDir)) {
    $GameDir = Find-BrotatoPath
}

if (-not (Test-Path "$GameDir\Brotato.pck")) {
    Write-Host "[ERROR] Could not find Brotato.pck at: $GameDir" -ForegroundColor Red
    pause
    exit 1
}

$pckPath = "$GameDir\Brotato.pck"
$bakPath = "$GameDir\Brotato.pck.bak"

if (-not (Test-Path $bakPath)) {
    Write-Host "Creating backup: $bakPath" -ForegroundColor Cyan
    Copy-Item $pckPath $bakPath
}

Write-Host "Injecting Thai PUA font into: $pckPath" -ForegroundColor Yellow

$fontBytes = [System.IO.File]::ReadAllBytes($fontFile)
$fontSize = $fontBytes.Length
$md5 = [System.Security.Cryptography.MD5]::Create().ComputeHash($fontBytes)

$fs = [System.IO.File]::Open($pckPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite)
$br = New-Object System.IO.BinaryReader($fs)
$bw = New-Object System.IO.BinaryWriter($fs)

try {
    $fs.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
    $magic = $br.ReadBytes(4)
    $fs.Seek(4 + 16 + 64, [System.IO.SeekOrigin]::Begin) | Out-Null
    $fileCount = $br.ReadInt32()

    $targetPath = "res://resources/fonts/raw/Anybody-Medium.ttf"
    $found = $false
    $targetEntryPos = 0

    for ($i = 0; $i -lt $fileCount; $i++) {
        $entryPos = $fs.Position
        $pathLen = $br.ReadInt32()
        $pathBytes = $br.ReadBytes($pathLen)
        $pad = (4 - ($pathLen % 4)) % 4
        if ($pad -gt 0) { $br.ReadBytes($pad) | Out-Null }
        
        $offsetPos = $fs.Position
        $offset = $br.ReadInt64()
        $size = $br.ReadInt64()
        $entryMd5 = $br.ReadBytes(16)

        $pathStr = [System.Text.Encoding]::UTF8.GetString($pathBytes).TrimEnd("`0")
        if ($pathStr -eq $targetPath) {
            $found = $true
            $targetEntryPos = $offsetPos
            break
        }
    }

    if (-not $found) {
        Write-Host "[ERROR] Target font path not found in PCK!" -ForegroundColor Red
        exit 1
    }

    # Append font to end of file
    $fs.Seek(0, [System.IO.SeekOrigin]::End) | Out-Null
    $currEnd = $fs.Position
    $alignedOffset = ($currEnd + 15) -band (-bnot 15)
    
    if ($alignedOffset -gt $currEnd) {
        $padBytes = New-Object byte[] ($alignedOffset - $currEnd)
        $bw.Write($padBytes)
    }
    
    $fs.Seek($alignedOffset, [System.IO.SeekOrigin]::Begin) | Out-Null
    $bw.Write($fontBytes)
    $newPckSize = $fs.Position

    # Update entry in header
    $fs.Seek($targetEntryPos, [System.IO.SeekOrigin]::Begin) | Out-Null
    $bw.Write([int64]$alignedOffset)
    $bw.Write([int64]$fontSize)
    $bw.Write($md5)

    Write-Host "`n=======================================================" -ForegroundColor Green
    Write-Host " SUCCESS! Thai PUA Font successfully injected into Brotato!" -ForegroundColor Green
    Write-Host "=======================================================" -ForegroundColor Green
}
finally {
    $br.Close()
    $bw.Close()
    $fs.Close()
}
