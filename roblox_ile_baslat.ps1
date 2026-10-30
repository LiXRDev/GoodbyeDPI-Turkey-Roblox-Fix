# GoodbyeDPI Roblox Fix - Roblox ile Baslat
# GoodbyeDPI'i baslatir, Roblox acilip kapaninca GoodbyeDPI'i otomatik kapatir.
# Kullanilan profil: Akilli Secici veya menu ile kaydedilen son profil (ayar.ini).
# Kayitli profil yoksa once Akilli Secici calistirilir.

$ErrorActionPreference = 'SilentlyContinue'

$Base = $PSScriptRoot
$IniFile = Join-Path $Base 'ayar.ini'

# Roblox acik sayilan islem adlari (Player, Studio, Microsoft Store surumu).
# Roblox sizde farkli bir isimle calisiyorsa buraya ekleyin. Gorev Yoneticisi > Ayrintilar sekmesinden bakabilirsiniz.
$RobloxIslemleri = @('RobloxPlayerBeta', 'RobloxStudioBeta', 'Windows10Universal')
# Roblox hic acilmazsa kac saniye sonra sorulsun
$BeklemeSn = 300
# Roblox kapandiktan sonra kac saniye beklenip GoodbyeDPI kapatilsin (baslatici -> oyun gecislerinde yanlislikla kapanmasin)
$KapanmaToleransSn = 20

# ayar.ini icinde sadece bu dosyalara izin verilir (yonetici izniyle calistigi icin)
$Gecerli = @{
    'roblox_dnsredir_alternative.cmd'         = 'Google DNS'
    'roblox_dnsredir_alternative2.cmd'        = 'Cloudflare DNS'
    'roblox_dnsredir_alternative_adguard.cmd' = 'AdGuard DNS'
    'roblox_dnsredir.cmd'                     = 'Quad9 DNS'
}

function Ask-Yn([string]$soru) {
    $a = Read-Host ($soru + ' (E = Evet, H = Hayir)')
    return ($a -match '^\s*[EeYy]')
}

function Get-Gdpi { return @(Get-Process -Name 'goodbyedpi' -ErrorAction SilentlyContinue) }

function Stop-Gdpi {
    Get-Process -Name 'goodbyedpi' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    for ($i = 0; $i -lt 20; $i++) {
        if ((Get-Gdpi).Count -eq 0) { break }
        Start-Sleep -Milliseconds 250
    }
}

function Start-Profil([string]$dosya) {
    $yol = Join-Path $Base $dosya
    Start-Process -FilePath $yol -WorkingDirectory $Base -WindowStyle Minimized | Out-Null
    for ($i = 0; $i -lt 24; $i++) {
        if ((Get-Gdpi).Count -gt 0) { break }
        Start-Sleep -Milliseconds 250
    }
    Start-Sleep -Seconds 2
    return ((Get-Gdpi).Count -gt 0)
}

function Roblox-Var {
    $p = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $RobloxIslemleri -contains $_.ProcessName })
    return ($p.Count -gt 0)
}

function Oku-Profil {
    if (-not (Test-Path -LiteralPath $IniFile)) { return $null }
    foreach ($satir in (Get-Content -LiteralPath $IniFile)) {
        if ($satir -match '^\s*profile\s*=\s*(.+?)\s*$') {
            $d = $Matches[1]
            if ($Gecerli.ContainsKey($d) -and (Test-Path -LiteralPath (Join-Path $Base $d))) {
                return [pscustomobject]@{ Dosya = $d; Ad = $Gecerli[$d] }
            }
        }
    }
    return $null
}

# ------------------------------------------------------------------ ANA AKIS

Write-Host ''
Write-Host '=== Roblox ile Baslat ===' -ForegroundColor Cyan

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Host '[X] Yonetici izni gerekli. DNSTEST.bat dosyasini kullanin.' -ForegroundColor Red
    exit 1
}

$profil = Oku-Profil
if (-not $profil) {
    Write-Host 'Kayitli profil yok. Once Akilli Secici calistirilacak (2-3 dakika surer).' -ForegroundColor Yellow
    $sec = Join-Path $Base 'akilli_secici.ps1'
    if (-not (Test-Path -LiteralPath $sec)) {
        Write-Host '[X] akilli_secici.ps1 bulunamadi.' -ForegroundColor Red
        exit 1
    }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $sec
    if ($LASTEXITCODE -ne 0) {
        Write-Host '[X] Profil secilemedi, Roblox ile baslatma iptal edildi.' -ForegroundColor Red
        exit 1
    }
    $profil = Oku-Profil
    if (-not $profil) {
        Write-Host '[X] Kaydedilen profil okunamadi.' -ForegroundColor Red
        exit 1
    }
}

Write-Host ('Profil: ' + $profil.Ad) -ForegroundColor Cyan

$benBasladim = $false
if ((Get-Gdpi).Count -gt 0) {
    Write-Host '[i] GoodbyeDPI zaten calisiyor. Ona dokunulmayacak, Roblox kapaninca da kapatilmayacak.' -ForegroundColor Yellow
} else {
    Write-Host 'GoodbyeDPI baslatiliyor...'
    if (-not (Start-Profil $profil.Dosya)) {
        Write-Host '[X] GoodbyeDPI baslatilamadi (antivirus engelliyor olabilir). DNSTEST.bat menusunden A ile sorun raporu alabilirsiniz.' -ForegroundColor Red
        exit 1
    }
    $benBasladim = $true
    Write-Host '[v] GoodbyeDPI calisiyor.' -ForegroundColor Green
}

Write-Host ''
Write-Host "Simdi Roblox'u acabilirsiniz." -ForegroundColor Green
Write-Host 'Bu pencereyi kapatmayin. Roblox kapaninca GoodbyeDPI otomatik kapatilir.'
Write-Host '(Pencereyi yanlislikla kapatirsaniz GoodbyeDPI acik kalir, GoodbyeDPI penceresini elle kapatabilirsiniz.)'
Write-Host ''

try {
    $gorulen = $false
    $bekleBasla = Get-Date
    $sonYazi = Get-Date
    while (-not $gorulen) {
        if (Roblox-Var) { $gorulen = $true; break }
        Start-Sleep -Seconds 1
        if (((Get-Date) - $sonYazi).TotalSeconds -ge 30) {
            Write-Host 'Roblox bekleniyor...'
            $sonYazi = Get-Date
        }
        if (((Get-Date) - $bekleBasla).TotalSeconds -ge $BeklemeSn) {
            if (-not (Ask-Yn 'Roblox hala acilmadi. Beklemeye devam edilsin mi?')) { break }
            $bekleBasla = Get-Date
        }
    }

    if ($gorulen) {
        Write-Host '[v] Roblox algilandi. Kapanana kadar GoodbyeDPI acik kalacak.' -ForegroundColor Green
        $kapaliSn = 0
        while ($kapaliSn -lt $KapanmaToleransSn) {
            if (Roblox-Var) { $kapaliSn = 0 } else { $kapaliSn += 2 }
            Start-Sleep -Seconds 2
        }
        Write-Host '[v] Roblox kapandi.' -ForegroundColor Green
    } else {
        Write-Host 'Roblox algilanmadi.' -ForegroundColor Yellow
    }
} finally {
    if ($benBasladim) {
        Write-Host 'GoodbyeDPI kapatiliyor...'
        Stop-Gdpi
        Write-Host '[v] GoodbyeDPI kapatildi.' -ForegroundColor Green
    }
}
exit 0
