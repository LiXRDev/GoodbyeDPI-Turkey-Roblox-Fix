@echo off
chcp 65001 >nul
title GoodbyeDPI - Roblox Multi-Language Tool
color 0A

rem ====================================================================
rem  HER YENI SURUMDE SADECE BU SATIRI GUNCELLE / UPDATE ONLY THIS LINE
rem ====================================================================
set "LOCAL_VER=1.2.4"
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
mode con: cols=100 lines=40 >nul 2>&1
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
set "YN_KEYS=EH"
set "TXT_TITLE=ROBLOX GOODBYEDPI - AKILLI ALTERNATIF VE YONETIM V%LOCAL_VER%"
set "TXT_TESTING=Baglanti ve guncelleme kontrol ediliyor, lutfen bekleyin..."
set "TXT_RESULTS=PING TEST SONUCLARI VE MENU - v%LOCAL_VER%"
set "TXT_UNREACH=Erisilemedi"
set "TXT_NO_DNS=[X] Hicbir DNS sunucusuna erisilemedi. Internetinizi kontrol edin."
set "TXT_OPT_SMART=Akilli Secici: en hizli calisan profili bul (2-3 dk)"
set "TXT_OPT_ROBLOX=Roblox ile baslat (Roblox kapaninca otomatik kapanir)"
set "TXT_OPT_SAVED=Son kullanilan profili baslat"
set "TXT_NONE_YET=henuz yok"
set "TXT_OPT_GOOG=Google DNS'i ac (roblox_dnsredir_alternative.cmd)"
set "TXT_OPT_CF=Cloudflare DNS'i ac (roblox_dnsredir_alternative2.cmd)"
set "TXT_OPT_ADG=AdGuard DNS'i ac (roblox_dnsredir_alternative_adguard.cmd)"
set "TXT_OPT_Q9=Quad9 DNS'i ac (roblox_dnsredir.cmd)"
set "TXT_OPT_CLEAN=Roblox Onbellegini (Temp) Temizle"
set "TXT_OPT_UPDATE=Guncellemeleri Kontrol Et"
set "TXT_OPT_REPORT=Sorun Raporu Olustur (sorun_raporu.ps1)"
set "TXT_OPT_EXIT=Testi kapat"
set "TXT_SELECT=Seciminizi yapin (1-9, A, B): "
set "TXT_START_NOW=Secilen profil simdi baslatilsin mi?"
set "TXT_NO_SAVED=[i] Kayitli profil yok. Once Akilli Secici'yi (1) calistirin."
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
set "TXT_UPD_ERR=[i] Kontrol yapilamadi. Internet baglantinizi kontrol edin."
set "TXT_UPD_OPEN=Indirme sayfasi acilsin mi?"
set "TXT_CHK_TITLE=BASLANGIC KONTROLU: SORUN BULUNDU"
set "TXT_CHK_ZIP=[X] Program zip dosyasinin ICINDEN calistiriliyor. Dosyalar eksik acilir ve calismaz."
set "TXT_CHK_FATAL=[X] Eksik dosya:"
set "TXT_CHK_FIX=Cozum: Zip dosyasina sag tiklayip 'Tumunu ayikla' deyin, cikan klasorden DNSTEST.bat dosyasini calistirin."
set "TXT_CHK_EXIT=Cikmak icin bir tusa basin..."
set "TXT_CHK_WARN=[i] Bazi dosyalar bulunamadi, ilgili ozellikler calismayabilir:"
set "TXT_CHK_WARN2=Zip dosyasinin tamamini cikardiginizdan emin olun."
set "TXT_CHK_CONT=Devam etmek icin bir tusa basin..."
goto START_TEST

:SET_EN
set "YN_KEYS=YN"
set "TXT_TITLE=ROBLOX GOODBYEDPI - SMART ALTERNATIVE and MANAGEMENT V%LOCAL_VER%"
set "TXT_TESTING=Checking connection and updates, please wait..."
set "TXT_RESULTS=PING TEST RESULTS AND MENU - v%LOCAL_VER%"
set "TXT_UNREACH=Unreachable"
set "TXT_NO_DNS=[X] No DNS server is reachable. Check your internet connection."
set "TXT_OPT_SMART=Smart Picker: find the fastest working profile (2-3 min, Turkish)"
set "TXT_OPT_ROBLOX=Start with Roblox (stops when Roblox closes, Turkish)"
set "TXT_OPT_SAVED=Launch last used profile"
set "TXT_NONE_YET=none yet"
set "TXT_OPT_GOOG=Launch Google DNS (roblox_dnsredir_alternative.cmd)"
set "TXT_OPT_CF=Launch Cloudflare DNS (roblox_dnsredir_alternative2.cmd)"
set "TXT_OPT_ADG=Launch AdGuard DNS (roblox_dnsredir_alternative_adguard.cmd)"
set "TXT_OPT_Q9=Launch Quad9 DNS (roblox_dnsredir.cmd)"
set "TXT_OPT_CLEAN=Clear Roblox Cache (Temp)"
set "TXT_OPT_UPDATE=Check for Updates"
set "TXT_OPT_REPORT=Create Problem Report (sorun_raporu.ps1, Turkish)"
set "TXT_OPT_EXIT=Exit"
set "TXT_SELECT=Make your choice (1-9, A, B): "
set "TXT_START_NOW=Launch the selected profile now?"
set "TXT_NO_SAVED=[i] No saved profile yet. Run the Smart Picker (1) first."
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
set "TXT_UPD_ERR=[i] Could not check for updates. Check your internet connection."
set "TXT_UPD_OPEN=Open the download page?"
set "TXT_CHK_TITLE=STARTUP CHECK: PROBLEM FOUND"
set "TXT_CHK_ZIP=[X] The program is running from INSIDE the zip file. Files are extracted incompletely and it will not work."
set "TXT_CHK_FATAL=[X] Missing file:"
set "TXT_CHK_FIX=Fix: Right-click the zip file, choose 'Extract All', then run DNSTEST.bat from the extracted folder."
set "TXT_CHK_EXIT=Press any key to exit..."
set "TXT_CHK_WARN=[i] Some files were not found, related features may not work:"
set "TXT_CHK_WARN2=Make sure you extracted the whole zip file."
set "TXT_CHK_CONT=Press any key to continue..."
goto START_TEST

:START_TEST
call :STARTUP_CHECK
if "!CHECK_FATAL!"=="1" goto STARTUP_FAIL
if defined MISSING_LIST call :STARTUP_WARN
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
call :LOAD_PROFILE

set "NO_DNS=0"
if !ms_google! EQU 9999 if !ms_cloudflare! EQU 9999 if !ms_adguard! EQU 9999 if !ms_quad9! EQU 9999 set "NO_DNS=1"

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
echo  [1] !TXT_OPT_SMART!
echo  [2] !TXT_OPT_ROBLOX!
if defined SAVED_NAME echo  [3] !TXT_OPT_SAVED! : !SAVED_NAME!
if not defined SAVED_NAME echo  [3] !TXT_OPT_SAVED! : !TXT_NONE_YET!
echo  [4] !TXT_OPT_GOOG!
echo  [5] !TXT_OPT_CF!
echo  [6] !TXT_OPT_ADG!
echo  [7] !TXT_OPT_Q9!
echo  [8] !TXT_OPT_CLEAN!
echo  [9] !TXT_OPT_UPDATE!
echo  [A] !TXT_OPT_REPORT!
echo  [B] !TXT_OPT_EXIT!
echo --------------------------------------------------------------------
echo.

choice /c 123456789AB /n /m "!TXT_SELECT!"
if errorlevel 11 goto OPT_EXIT
if errorlevel 10 goto OPT_REPORT
if errorlevel 9 goto OPT_UPDATE
if errorlevel 8 goto OPT_CLEAN
if errorlevel 7 goto OPT_Q9
if errorlevel 6 goto OPT_ADG
if errorlevel 5 goto OPT_CF
if errorlevel 4 goto OPT_GOOG
if errorlevel 3 goto OPT_SAVED
if errorlevel 2 goto OPT_ROBLOX
goto OPT_SMART

rem --- [1] Akilli Secici: profilleri gercekten test eder, en hizlisini kaydeder ---
:OPT_SMART
echo.
if not exist "%BASE%akilli_secici.ps1" goto SMART_MISSING
powershell -NoProfile -ExecutionPolicy Bypass -File "%BASE%akilli_secici.ps1"
if errorlevel 1 goto PRESS_KEY
call :LOAD_PROFILE
if not defined SAVED_SCRIPT goto PRESS_KEY
echo.
choice /c !YN_KEYS! /m "!TXT_START_NOW! [!SAVED_NAME!]"
if errorlevel 2 goto PRESS_KEY
call :LAUNCH "!SAVED_SCRIPT!" "!SAVED_NAME!"
goto MENU

:SMART_MISSING
echo !TXT_MISSING! akilli_secici.ps1
goto PRESS_KEY

rem --- [2] Roblox ile baslat: Roblox kapaninca GoodbyeDPI de kapanir ---
:OPT_ROBLOX
echo.
if not exist "%BASE%roblox_ile_baslat.ps1" goto ROBLOX_MISSING
powershell -NoProfile -ExecutionPolicy Bypass -File "%BASE%roblox_ile_baslat.ps1"
call :LOAD_PROFILE
goto PRESS_KEY

:ROBLOX_MISSING
echo !TXT_MISSING! roblox_ile_baslat.ps1
goto PRESS_KEY

rem --- [3] Son kullanilan profil ---
:OPT_SAVED
if not defined SAVED_SCRIPT goto SAVED_NONE
call :LAUNCH "!SAVED_SCRIPT!" "!SAVED_NAME!"
goto MENU

:SAVED_NONE
echo.
echo !TXT_NO_SAVED!
goto PRESS_KEY

rem --- [4-7] Elle profil secimi ---
:OPT_GOOG
call :LAUNCH "roblox_dnsredir_alternative.cmd" "Google DNS"
goto MENU

:OPT_CF
call :LAUNCH "roblox_dnsredir_alternative2.cmd" "Cloudflare DNS"
goto MENU

:OPT_ADG
call :LAUNCH "roblox_dnsredir_alternative_adguard.cmd" "AdGuard DNS"
goto MENU

:OPT_Q9
call :LAUNCH "roblox_dnsredir.cmd" "Quad9 DNS"
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
choice /c !YN_KEYS! /m "!TXT_UPD_OPEN!"
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

rem --- Baslangic kontrolu ciddi sorun buldu: aciklama goster ve kapat ---
:STARTUP_FAIL
cls
echo ====================================================================
echo        !TXT_CHK_TITLE!
echo ====================================================================
echo.
if "!IN_ZIP!"=="1" echo  !TXT_CHK_ZIP!
if defined FATAL_LIST echo  !TXT_CHK_FATAL!!FATAL_LIST!
echo.
echo  !TXT_CHK_FIX!
echo.
echo  !TXT_CHK_EXIT!
pause >nul
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

rem ayar.ini dosyasindan son kullanilan profili okur: SAVED_SCRIPT, SAVED_NAME
rem Yonetici izniyle calistigi icin sadece bilinen 4 profil dosyasina izin verilir.
:LOAD_PROFILE
set "SAVED_SCRIPT="
set "SAVED_NAME="
if not exist "%BASE%ayar.ini" exit /b
for /f "usebackq tokens=1,* delims==" %%a in ("%BASE%ayar.ini") do call :LOAD_LINE "%%a" "%%b"
call :VALIDATE_PROFILE
exit /b

:LOAD_LINE
if /i "%~1"=="profile" set "SAVED_SCRIPT=%~2"
exit /b

:VALIDATE_PROFILE
if not defined SAVED_SCRIPT exit /b
set "SAVED_NAME="
if /i "!SAVED_SCRIPT!"=="roblox_dnsredir_alternative.cmd" set "SAVED_NAME=Google DNS"
if /i "!SAVED_SCRIPT!"=="roblox_dnsredir_alternative2.cmd" set "SAVED_NAME=Cloudflare DNS"
if /i "!SAVED_SCRIPT!"=="roblox_dnsredir_alternative_adguard.cmd" set "SAVED_NAME=AdGuard DNS"
if /i "!SAVED_SCRIPT!"=="roblox_dnsredir.cmd" set "SAVED_NAME=Quad9 DNS"
if not defined SAVED_NAME goto VALIDATE_BAD
if not exist "%BASE%!SAVED_SCRIPT!" goto VALIDATE_BAD
exit /b

:VALIDATE_BAD
set "SAVED_SCRIPT="
set "SAVED_NAME="
exit /b

rem %1 = profil dosyasi, %2 = profil adi: ayar.ini dosyasina yazar
:SAVE_PROFILE
(
echo profile=%~1
echo name=%~2
) > "%BASE%ayar.ini" 2>nul
exit /b

rem %1 = calistirilacak .cmd dosyasi, %2 = profil adi
:LAUNCH
if not exist "%BASE%%~1" goto LAUNCH_MISSING
call :SAVE_PROFILE "%~1" "%~2"
start "GoodbyeDPI" "%BASE%%~1"
exit

:LAUNCH_MISSING
echo.
echo !TXT_MISSING! %~1
echo.
echo !TXT_PRESS_KEY!
pause >nul
exit /b

rem ====================================================================
rem  BASLANGIC KONTROLU / STARTUP CHECK
rem  CHECK_FATAL=1 ise program devam etmez. MISSING_LIST doluysa sadece uyari verilir.
rem ====================================================================
:STARTUP_CHECK
set "CHECK_FATAL=0"
set "IN_ZIP=0"
set "FATAL_LIST="
set "MISSING_LIST="
rem Zip icinden mi? (Windows, 7-Zip ve WinRAR gecici klasorleri)
for %%p in (".zip\" "\7zO" "\Rar$" "Temp1_") do (
    set "_chk=!BASE:%%~p=!"
    if not "!_chk!"=="!BASE!" set "IN_ZIP=1"
)
rem Mimari secimi profil dosyalariyla (roblox_dnsredir*.cmd) ayni olmali
set "ARCH=x86"
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=x86_64"
if defined PROCESSOR_ARCHITEW6432 set "ARCH=x86_64"
if not exist "%BASE%!ARCH!\goodbyedpi.exe" set "FATAL_LIST= !ARCH!\goodbyedpi.exe"
set "PROFILES_FOUND=0"
for %%f in (roblox_dnsredir.cmd roblox_dnsredir_alternative.cmd roblox_dnsredir_alternative2.cmd roblox_dnsredir_alternative_adguard.cmd) do (
    if exist "%BASE%%%f" (
        set /a PROFILES_FOUND+=1
    ) else (
        set "MISSING_LIST=!MISSING_LIST! %%f"
    )
)
if !PROFILES_FOUND! EQU 0 set "FATAL_LIST=!FATAL_LIST! roblox_dnsredir*.cmd"
for %%f in (akilli_secici.ps1 roblox_ile_baslat.ps1 sorun_raporu.ps1) do (
    if not exist "%BASE%%%f" set "MISSING_LIST=!MISSING_LIST! %%f"
)
if "!IN_ZIP!"=="1" set "CHECK_FATAL=1"
if defined FATAL_LIST set "CHECK_FATAL=1"
exit /b

:STARTUP_WARN
cls
echo.
echo  !TXT_CHK_WARN!!MISSING_LIST!
echo  !TXT_CHK_WARN2!
echo.
echo  !TXT_CHK_CONT!
pause >nul
exit /b
