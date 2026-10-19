@echo off
chcp 65001 >nul
title GoodbyeDPI - Roblox v1.1.0 Multi-Language Tool
color 0A

:LANG_SELECT
cls
echo ====================================================================
echo               LANGUAGE SELECTION / DIL SECIMI
echo ====================================================================
echo.
echo  [1] TR - Turkce
echo  [2] EN - English
echo.
set /p lang_choice="Lutfen bir dil secin / Please select a language (1-2): "

if "%lang_choice%"=="1" goto SET_TR
if "%lang_choice%"=="2" goto SET_EN
goto LANG_SELECT

:SET_TR
set "TXT_TITLE=ROBLOX GOODBYEDPI - AKILLI ALTERNATIF VE YONETIM V1.1.0"
set "TXT_TESTING=Sunuculara baglanti testi yapiliyor, lutfen bekleyin..."
set "TXT_RESULTS=PING TEST SONUCLARI VE MENU (v1.1.0)"
set "TXT_BEST_DNS=En iyi performansi veren DNS sunucusunu ac (%best_name%) ve testi kapat"
set "TXT_OPT_GOOG=Google DNS'i ac (roblox_dnsredir_alternative.cmd) ve testi kapat"
set "TXT_OPT_CF=Cloudflare DNS'i ac (roblox_dnsredir_alternative2.cmd) ve testi kapat"
set "TXT_OPT_ADG=AdGuard DNS'i ac (roblox_dnsredir_alternative_adguard.cmd) ve testi kapat"
set "TXT_OPT_Q9=Quad9 DNS'i ac (roblox_dnsredir.cmd) ve testi kapat"
set "TXT_OPT_CLEAN=Roblox Onbellegini (Temp) Temizle"
set "TXT_OPT_EXIT=Testi kapat"
set "TXT_SELECT=Seciminizi yapin (1-7): "
set "TXT_STARTING=En iyi performans veren %best_name% baslatiliyor..."
set "TXT_CLEANING=Roblox onbellek klasoru temizleniyor..."
set "TXT_CLEAN_SUCCESS=[v] Roblox onbellegi basariyla temizlendi!"
set "TXT_CLEAN_EMPTY=[i] Temizlenecek Roblox onbellek klasoru bulunamadi."
set "TXT_PRESS_KEY=Ana menuye donmek icin bir tusa basin..."
set "TXT_INVALID=Gecersiz secim yapildi, test kapatiliyor..."
goto START_TEST

:SET_EN
set "TXT_TITLE=ROBLOX GOODBYEDPI - SMART ALTERNATIVE and MANAGEMENT V1.1.0"
set "TXT_TESTING=Testing connection to servers, please wait..."
set "TXT_RESULTS=PING TEST RESULTS AND MENU (v1.1.0)"
set "TXT_BEST_DNS=Launch best performing DNS (%best_name%) and exit"
set "TXT_OPT_GOOG=Launch Google DNS (roblox_dnsredir_alternative.cmd) and exit"
set "TXT_OPT_CF=Launch Cloudflare DNS (roblox_dnsredir_alternative2.cmd) and exit"
set "TXT_OPT_ADG=Launch AdGuard DNS (roblox_dnsredir_alternative_adguard.cmd) and exit"
set "TXT_OPT_Q9=Launch Quad9 DNS (roblox_dnsredir.cmd) and exit"
set "TXT_OPT_CLEAN=Clear Roblox Cache (Temp)"
set "TXT_OPT_EXIT=Exit test"
set "TXT_SELECT=Make your choice (1-7): "
set "TXT_STARTING=Launching best performance DNS (%best_name%)..."
set "TXT_CLEANING=Clearing Roblox cache folder..."
set "TXT_CLEAN_SUCCESS=[v] Roblox cache successfully cleared!"
set "TXT_CLEAN_EMPTY=[i] No Roblox cache folder found to clear."
set "TXT_PRESS_KEY=Press any key to return to main menu..."
set "TXT_INVALID=Invalid selection made, closing test..."
goto START_TEST

:START_TEST
cls
echo ====================================================================
echo        %TXT_TITLE%
echo ====================================================================
echo.
echo %TXT_TESTING%
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

:MENU
cls
echo ====================================================================
echo                    %TXT_RESULTS%
echo ====================================================================
echo.
echo  Google DNS (8.8.8.8)        : %p_google%
echo  Cloudflare DNS (1.1.1.1)    : %p_cloudflare%
echo  AdGuard DNS (94.140.14.14)  : %p_adguard%
echo  Quad9 DNS (9.9.9.9)         : %p_quad9%
echo.
echo --------------------------------------------------------------------
echo  [1] %TXT_BEST_DNS%
echo  [2] %TXT_OPT_GOOG%
echo  [3] %TXT_OPT_CF%
echo  [4] %TXT_OPT_ADG%
echo  [5] %TXT_OPT_Q9%
echo  [6] %TXT_OPT_CLEAN%
echo  [7] %TXT_OPT_EXIT%
echo --------------------------------------------------------------------
echo.

set /p choice="%TXT_SELECT%"

if "%choice%"=="1" (
    echo.
    echo %TXT_STARTING%
    start "GoodbyeDPI" "%best_script%"
    exit
)
if "%choice%"=="2" (
    start "GoodbyeDPI" "roblox_dnsredir_alternative.cmd"
    exit
)
if "%choice%"=="3" (
    start "GoodbyeDPI" "roblox_dnsredir_alternative2.cmd"
    exit
)
if "%choice%"=="4" (
    start "GoodbyeDPI" "roblox_dnsredir_alternative_adguard.cmd"
    exit
)
if "%choice%"=="5" (
    start "GoodbyeDPI" "roblox_dnsredir.cmd"
    exit
)
if "%choice%"=="6" (
    echo.
    echo %TXT_CLEANING%
    if exist "%localappdata%\Temp\Roblox" (
        rmdir /s /q "%localappdata%\Temp\Roblox" >nul 2>&1
        echo %TXT_CLEAN_SUCCESS%
    ) else (
        echo %TXT_CLEAN_EMPTY%
    )
    echo.
    echo %TXT_PRESS_KEY%
    pause >nul
    goto MENU
)
if "%choice%"=="7" (
    exit
)

echo.
echo %TXT_INVALID%
timeout /t 2 >nul
exit
