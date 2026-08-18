@echo off
chcp 65001 >nul
title Brotato - Thai Font & Mod Installer (1-Click)
color 0A

echo ======================================================================
echo           BROTATO - THAI MOD & FONT INSTALLER (1-CLICK)
echo ======================================================================
echo.
echo กำลังค้นหาโฟลเดอร์เกม Brotato และฉีดฟอนต์ภาษาไทย PUA เข้าตัวเกม...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer.ps1"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [สำเร็จ] ติดตั้งฟอนต์ภาษาไทย PUA เข้าตัวเกมเรียบร้อยแล้ว!
    echo สามารถเปิดเกม Brotato บน Steam แล้วเลือกภาษาไทยได้ทันทีครับ
) else (
    echo.
    echo [ผิดพลาด] เกิดข้อผิดพลาดในการติดตั้ง กรุณาตรวจสอบว่าปิดเกม Brotato อยู่หรือไม่
)

echo.
echo ======================================================================
pause
