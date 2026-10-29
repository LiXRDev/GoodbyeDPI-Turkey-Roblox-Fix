@echo off
chcp 65001 >nul
title GoodbyeDPI - Roblox Multi-Language Tool
color 0A

rem ====================================================================
rem  HER YENI SURUMDE SADECE BU SATIRI GUNCELLE / UPDATE ONLY THIS LINE
rem ====================================================================
set "LOCAL_VER=1.2.1"
set "REPO=LiXRDev/GoodbyeDPI-Turkey-Roblox-Fix"
rem ====================================================================

rem --- Yonetici kontrolu / Admin check ---
net session >nul 2>&1
if errorlevel 1 goto NOT_ADMIN
goto ADMIN_OK

:NOT_ADMIN
echo.
echo Yonetici izni isteniyor / Requesting administrator permission...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
exit /b

:ADMIN_OK
cd /d "%~dp0"
set "BASE=%~dp0"
setlocal enabledelayedexpansion

:LANG_SELECT
cls
echo ====================================================================
echo               LANGUAGE SELECTION / DIL SECIMI
echo ====================================================================
echo.
echo  [1] TR - Turkce
echo  [2] EN - English
echo.
choice /c 12 /n /m "Lutfen bir dil secin / Please select a language (1-2): "
if errorlevel 2 goto SET_EN
goto SET_TR

:SET_TR
set "UPD_KEYS=EH"
set "TXT_TITLE=ROBLOX GOODBYEDPI - AKILLI ALTERNATIF VE YONETIM V%LOCAL_VER%"
set "TXT_TESTING=Sunuculara baglanti testi ve guncelleme kontrolu yapiliyor, lutfen bekleyin..."
set "TXT_RESULTS=PING TEST SONUCLARI VE MENU - v%LOCAL_VER%"
set "TXT_UNREACH=Erisilemedi"
set "TXT_NO_DNS=[X] Hicbir DNS sunucusuna erisilemedi. Internet baglantinizi kontrol edin."
set "TXT_OPT_BEST=En iyi DNS'i ac ve testi kapat"
set "TXT_OPT_GOOG=Google DNS'i ac (roblox_dnsredir_alternative.cmd) ve testi kapat"
set "TXT_OPT_CF=Cloudflare DNS'i ac (roblox_dnsredir_alternative2.cmd) ve testi kapat"
set "TXT_OPT_ADG=AdGuard DNS'i ac (roblox_dnsredir_alternative_adguard.cmd) ve testi kapat"
set "TXT_OPT_Q9=Quad9 DNS'i ac (roblox_dnsredir.cmd) ve testi kapat"
set "TXT_OPT_CLEAN=Roblox Onbellegini (Temp) Temizle"
set "TXT_OPT_UPDATE=Guncellemeleri Kontrol Et"
set "TXT_OPT_REPORT=Sorun Raporu Olustur (sorun_raporu.ps1)"
set "TXT_OPT_EXIT=Testi kapat"
set "TXT_SELECT=Seciminizi yapin (1-9): "
set "TXT_STARTING=Baslatiliyor:"
set "TXT_CLEANING=Roblox gecici dosyalari temizleniyor..."
set "TXT_CLEAN_SUCCESS=[v] Roblox onbellegi basariyla temizlendi."
set "TXT_CLEAN_FAIL=[x] Temizlenemedi. Roblox acik olabilir, kapatip tekrar deneyin."
set "TXT_CLEAN_EMPTY=[i] Temizlenecek Roblox onbellek klasoru bulunamadi."
set "TXT_PRESS_KEY=Ana menuye donmek icin bir tusa basin..."
set "TXT_MISSING=Dosya bulunamadi:"
set "TXT_UPD_CHECKING=Guncellemeler kontrol ediliyor..."
set "TXT_UPD_NEW=[*] Yeni surum mevcut:"
set "TXT_UPD_YOURS=Sizdeki:"
set "TXT_UPD_OK=[v] Guncelsiniz. En son surum:"
set "TXT_UPD_ERR=[i] Kontrol yapilamadi. Internet baglantinizi kontrol edin veya daha sonra tekrar deneyin."
set "TXT_UPD_OPEN=Indirme sayfasi acilsin mi?"
goto START_TEST

:SET_EN
set "UPD_KEYS=YN"
set "TXT_TITLE=ROBLOX GOODBYEDPI - SMART ALTERNATIVE and MANAGEMENT V%LOCAL_VER%"
set "TXT_TESTING=Testing connection to servers and checking for updates, please wait..."
set "TXT_RESULTS=PING TEST RESULTS AND MENU - v%LOCAL_VER%"
set "TXT_UNREACH=Unreachable"
set "TXT_NO_DNS=[X] No DNS server is reachable. Please check your internet connection."
set "TXT_OPT_BEST=Launch best DNS and exit"
set "TXT_OPT_GOOG=Launch Google DNS (roblox_dnsredir_alternative.cmd) and exit"
set "TXT_OPT_CF=Launch Cloudflare DNS (roblox_dnsredir_alternative2.cmd) and exit"
set "TXT_OPT_ADG=Launch AdGuard DNS (roblox_dnsredir_alternative_adguard.cmd) and exit"
set "TXT_OPT_Q9=Launch Quad9 DNS (roblox_dnsredir.cmd) and exit"
set "TXT_OPT_CLEAN=Clear Roblox Cache (Temp)"
set "TXT_OPT_UPDATE=Check for Updates"
set "TXT_OPT_REPORT=Create Problem Report (sorun_raporu.ps1, Turkish only)"
set "TXT_OPT_EXIT=Exit"
set "TXT_SELECT=Make your choice (1-9): "
set "TXT_STARTING=Launching:"
set "TXT_CLEANING=Clearing Roblox temporary files..."
set "TXT_CLEAN_SUCCESS=[v] Roblox cache successfully cleared."
set "TXT_CLEAN_FAIL=[x] Could not clear it. Roblox may be open, close it and try again."
set "TXT_CLEAN_EMPTY=[i] No Roblox cache folder found to clear."
set "TXT_PRESS_KEY=Press any key to return to main menu..."
set "TXT_MISSING=File not found:"
set "TXT_UPD_CHECKING=Checking for updates..."
set "TXT_UPD_NEW=[*] New version available:"
set "TXT_UPD_YOURS=Yours:"
set "TXT_UPD_OK=[v] You are up to date. Latest version:"
set "TXT_UPD_ERR=[i] Could not check for updates. Check your internet connection or try again later."
set "TXT_UPD_OPEN=Open the download page?"
goto START_TEST

:START_TEST
cls
echo ====================================================================
echo        !TXT_TITLE!
echo ====================================================================
echo.
echo !TXT_TESTING!
echo.

call :PING_DNS 8.8.8.8 ms_google p_google
call :PING_DNS 1.1.1.1 ms_cloudflare p_cloudflare
call :PING_DNS 94.140.14.14 ms_adguard p_adguard
call :PING_DNS 9.9.9.9 ms_quad9 p_quad9
call :CHECK_UPDATE

rem --- En iyi DNS'i hesapla / Pick the best DNS ---
set /a min_ms=ms_google
set "best_script=roblox_dnsredir_alternative.cmd"
set "best_name=Google DNS"

if !ms_cloudflare! LSS !min_ms! (
    set /a min_ms=ms_cloudflare
    set "best_script=roblox_dnsredir_alternative2.cmd"
    set "best_name=Cloudflare DNS"
)
if !ms_adguard! LSS !min_ms! (
    set /a min_ms=ms_adguard
    set "best_script=roblox_dnsredir_alternative_adguard.cmd"
    set "best_name=AdGuard DNS"
)
if !ms_quad9! LSS !min_ms! (
    set /a min_ms=ms_quad9
    set "best_script=roblox_dnsredir.cmd"
    set "best_name=Quad9 DNS"
)

set "NO_DNS=0"
if !min_ms! EQU 9999 set "NO_DNS=1"

:MENU
cls
echo ====================================================================
echo                    !TXT_RESULTS!
echo ====================================================================
echo.
echo  Google DNS (8.8.8.8)        : !p_google!
echo  Cloudflare DNS (1.1.1.1)    : !p_cloudflare!
echo  AdGuard DNS (94.140.14.14)  : !p_adguard!
echo  Quad9 DNS (9.9.9.9)         : !p_quad9!
echo.
if "!UPD_STATE!"=="NEW" echo  !TXT_UPD_NEW! v!UPD_LATEST!  -  !TXT_UPD_YOURS! v%LOCAL_VER%
if "!NO_DNS!"=="1" echo  !TXT_NO_DNS!
echo --------------------------------------------------------------------
echo  [1] !TXT_OPT_BEST! [!best_name!]
echo  [2] !TXT_OPT_GOOG!
echo  [3] !TXT_OPT_CF!
echo  [4] !TXT_OPT_ADG!
echo  [5] !TXT_OPT_Q9!
echo  [6] !TXT_OPT_CLEAN!
echo  [7] !TXT_OPT_UPDATE!
echo  [8] !TXT_OPT_REPORT!
echo  [9] !TXT_OPT_EXIT!
echo --------------------------------------------------------------------
echo.

choice /c 123456789 /n /m "!TXT_SELECT!"
if errorlevel 9 goto OPT_EXIT
if errorlevel 8 goto OPT_REPORT
if errorlevel 7 goto OPT_UPDATE
if errorlevel 6 goto OPT_CLEAN
if errorlevel 5 goto OPT_Q9
if errorlevel 4 goto OPT_ADG
if errorlevel 3 goto OPT_CF
if errorlevel 2 goto OPT_GOOG
goto OPT_BEST

:OPT_BEST
echo.
echo !TXT_STARTING! !best_name!
call :LAUNCH "!best_script!"
goto MENU

:OPT_GOOG
call :LAUNCH "roblox_dnsredir_alternative.cmd"
goto MENU

:OPT_CF
call :LAUNCH "roblox_dnsredir_alternative2.cmd"
goto MENU

:OPT_ADG
call :LAUNCH "roblox_dnsredir_alternative_adguard.cmd"
goto MENU

:OPT_Q9
call :LAUNCH "roblox_dnsredir.cmd"
goto MENU

:OPT_CLEAN
echo.
echo !TXT_CLEANING!
if not exist "%TEMP%\Roblox" goto CLEAN_EMPTY
rmdir /s /q "%TEMP%\Roblox" >nul 2>&1
if exist "%TEMP%\Roblox" goto CLEAN_FAIL
echo !TXT_CLEAN_SUCCESS!
goto PRESS_KEY

:CLEAN_EMPTY
echo !TXT_CLEAN_EMPTY!
goto PRESS_KEY

:CLEAN_FAIL
echo !TXT_CLEAN_FAIL!
goto PRESS_KEY

:OPT_UPDATE
echo.
echo !TXT_UPD_CHECKING!
call :CHECK_UPDATE
if "!UPD_STATE!"=="NEW" goto UPD_NEW
if "!UPD_STATE!"=="OK" goto UPD_OK
echo !TXT_UPD_ERR!  [kod/code: !UPD_LATEST!]
goto PRESS_KEY

:UPD_OK
echo !TXT_UPD_OK! v!UPD_LATEST!
goto PRESS_KEY

:UPD_NEW
echo !TXT_UPD_NEW! v!UPD_LATEST!  -  !TXT_UPD_YOURS! v%LOCAL_VER%
echo.
choice /c !UPD_KEYS! /m "!TXT_UPD_OPEN!"
if not errorlevel 2 start "" "https://github.com/%REPO%/releases/latest"
goto PRESS_KEY

:OPT_REPORT
if not exist "%BASE%sorun_raporu.ps1" goto REPORT_MISSING
powershell -NoProfile -ExecutionPolicy Bypass -File "%BASE%sorun_raporu.ps1"
goto PRESS_KEY

:REPORT_MISSING
echo.
echo !TXT_MISSING! sorun_raporu.ps1
goto PRESS_KEY

:PRESS_KEY
echo.
echo !TXT_PRESS_KEY!
pause >nul
goto MENU

:OPT_EXIT
exit

rem ====================================================================
rem  ALT RUTINLER / SUBROUTINES
rem ====================================================================

rem %1 = IP adresi, %2 = ms degiskeni, %3 = gosterim degiskeni
rem Dilden bagimsiz: ping ozet satirini "ms" ile biten satira gore bulur.
:PING_DNS
set "%~2=9999"
set "%~3=!TXT_UNREACH!"
for /f "tokens=4 delims==" %%a in ('ping -n 2 -w 1500 %~1 ^| findstr /r "ms$"') do (
    set "_str=%%a"
    set "_str=!_str:ms=!"
    set "_str=!_str: =!"
    set /a "%~2=!_str!"
    set "%~3=!_str! ms"
)
exit /b

rem UPD_STATE = NEW / OK / ERR, UPD_LATEST = son surum numarasi
:CHECK_UPDATE
set "UPD_STATE=ERR"
set "UPD_LATEST=0"
for /f "usebackq tokens=1,2 delims=:" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12 } catch {}; $t=$null; try { $x=(Invoke-WebRequest -Uri 'https://github.com/%REPO%/releases.atom' -UseBasicParsing -TimeoutSec 15).RawContent; if ($x -match '/releases/tag/v?([0-9][0-9.]*[0-9])') { $t=$Matches[1] } } catch {}; if (-not $t) { try { $j=Invoke-RestMethod -Uri 'https://api.github.com/repos/%REPO%/releases/latest' -Headers @{'User-Agent'='dnstest'} -TimeoutSec 15; if ($j.tag_name -match '([0-9][0-9.]*[0-9])') { $t=$Matches[1] } } catch {} }; if (-not $t) { 'ERR:NOREL'; exit }; try { if ([version]$t -gt [version]'%LOCAL_VER%') { 'NEW:'+$t } else { 'OK:'+$t } } catch { 'ERR:VER' }"`) do (
    set "UPD_STATE=%%a"
    set "UPD_LATEST=%%b"
)
exit /b

rem %1 = calistirilacak .cmd dosyasi
:LAUNCH
if not exist "%BASE%%~1" goto LAUNCH_MISSING
start "GoodbyeDPI" "%BASE%%~1"
exit

:LAUNCH_MISSING
echo.
echo !TXT_MISSING! %~1
echo.
echo !TXT_PRESS_KEY!
pause >nul
exit /b
