@echo off
chcp 65001 >nul
title GoodbyeDPI - Roblox Akilli Alternatif ve DNS Test Araci
color 0A

cls
echo ====================================================================
echo            ROBLOX GOODBYEDPI - AKILLI ALTERNATIF VE DNS TESTI       
echo ====================================================================
echo.
echo Sunuculara baglanti testi yapiliyor, lutfen bekleyin...
echo.

setlocal enabledelayedexpansion

:: Varsayılan ping değerleri
set /a ms_google=9999
set /a ms_cloudflare=9999
set /a ms_adguard=9999
set /a ms_quad9=9999

set p_google=Erisilemedi
set p_cloudflare=Erisilemedi
set p_adguard=Erisilemedi
set p_quad9=Erisilemedi

:: 1. Google (roblox_dnsredir_alternative.cmd)
for /f "tokens=4 delims==" %%a in ('ping -n 2 8.8.8.8 ^| find "Average"') do (
    set p_google=%%a
    set str=%%a
    set str=!str:ms=!
    set str=!str: =!
    set /a ms_google=!str!
)

:: 2. Cloudflare (roblox_dnsredir_alternative2.cmd)
for /f "tokens=4 delims==" %%a in ('ping -n 2 1.1.1.1 ^| find "Average"') do (
    set p_cloudflare=%%a
    set str=%%a
    set str=!str:ms=!
    set str=!str: =!
    set /a ms_cloudflare=!str!
)

:: 3. AdGuard (roblox_dnsredir_alternative_adguard.cmd)
for /f "tokens=4 delims==" %%a in ('ping -n 2 94.140.14.14 ^| find "Average"') do (
    set p_adguard=%%a
    set str=%%a
    set str=!str:ms=!
    set str=!str: =!
    set /a ms_adguard=!str!
)

:: 4. Quad9 / Bilinmeyen (roblox_dnsredir.cmd)
for /f "tokens=4 delims==" %%a in ('ping -n 2 9.9.9.9 ^| find "Average"') do (
    set p_quad9=%%a
    set str=%%a
    set str=!str:ms=!
    set str=!str: =!
    set /a ms_quad9=!str!
)

:: En iyi DNS'i Hesapla
set /a min_ms=%ms_google%
set best_script=roblox_dnsredir_alternative.cmd
set best_name=Google DNS

if %ms_cloudflare% LSS %min_ms% (
    set /a min_ms=%ms_cloudflare%
    set best_script=roblox_dnsredir_alternative2.cmd
    set best_name=Cloudflare DNS
)

if %ms_adguard% LSS %min_ms% (
    set /a min_ms=%ms_adguard%
    set best_script=roblox_dnsredir_alternative_adguard.cmd
    set best_name=AdGuard DNS
)

if %ms_quad9% LSS %min_ms% (
    set /a min_ms=%ms_quad9%
    set best_script=roblox_dnsredir.cmd
    set best_name=Quad9 DNS
)

cls
echo ====================================================================
echo                    PING TEST SONUCLARI VE MENÜ                     
echo ====================================================================
echo.
echo  Google DNS (8.8.8.8)        : %p_google%
echo  Cloudflare DNS (1.1.1.1)    : %p_cloudflare%
echo  AdGuard DNS (94.140.14.14)  : %p_adguard%
echo  Quad9 DNS (9.9.9.9)         : %p_quad9%
echo.
echo --------------------------------------------------------------------
echo  [1] En iyi performansi veren DNS sunucusunu ac (%best_name%) ve testi kapat
echo  [2] Google DNS'i ac (roblox_dnsredir_alternative.cmd) ve testi kapat
echo  [3] Cloudflare DNS'i ac (roblox_dnsredir_alternative2.cmd) ve testi kapat
echo  [4] AdGuard DNS'i ac (roblox_dnsredir_alternative_adguard.cmd) ve testi kapat
echo  [5] Quad9 DNS'i ac (roblox_dnsredir.cmd) ve testi kapat
echo  [6] Testi kapat
echo  Ek Bilgi: Cloudflare ve Google DNS tavsiye edilir
echo --------------------------------------------------------------------
echo.

set /p choice="Seciminizi yapin (1-6): "

if "%choice%"=="1" (
    echo.
    echo En iyi performans veren %best_name% baslatiliyor...
    cmd /c "%best_script%"
    exit
)
if "%choice%"=="2" (
    cmd /c "roblox_dnsredir_alternative.cmd"
    exit
)
if "%choice%"=="3" (
    cmd /c "roblox_dnsredir_alternative2.cmd"
    exit
)
if "%choice%"=="4" (
    cmd /c "roblox_dnsredir_alternative_adguard.cmd"
    exit
)
if "%choice%"=="5" (
    cmd /c "roblox_dnsredir.cmd"
    exit
)
if "%choice%"=="6" (
    exit
)

echo.
echo Gecersiz secim yapildi, test kapatiliyor...
timeout /t 2 >nul
exit