@echo off
chcp 65001 >nul
title Brotato - Restore Original Game Files
color 0E

echo ======================================================================
echo           BROTATO - RESTORE ORIGINAL FILES (ถอนการติดตั้ง)
echo ======================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$paths = @('C:\Program Files (x86)\Steam\steamapps\common\Brotato', 'C:\Program Files\Steam\steamapps\common\Brotato', 'D:\SteamLibrary\steamapps\common\Brotato', 'E:\SteamLibrary\steamapps\common\Brotato'); foreach ($p in $paths) { if (Test-Path \"$p\Brotato.pck.bak\") { Copy-Item \"$p\Brotato.pck.bak\" \"$p\Brotato.pck\" -Force; Write-Host \"[SUCCESS] Restored original Brotato.pck in $p\" -ForegroundColor Green; exit 0 } }; Write-Host '[ERROR] No backup file Brotato.pck.bak found!' -ForegroundColor Red; exit 1"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [สำเร็จ] คืนค่าไฟล์เกมดั้งเดิมของ Steam เรียบร้อยแล้ว!
) else (
    echo.
    echo [แจ้งเตือน] ไม่พบไฟล์สำรอง Brotato.pck.bak
)

echo.
echo ======================================================================
pause
