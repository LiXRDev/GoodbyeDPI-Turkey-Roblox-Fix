# GoodbyeDPI Roblox Fix - Roblox ile Baslat
# GoodbyeDPI'i baslatir, Roblox acilip kapaninca GoodbyeDPI'i otomatik kapatir.
# Kullanilan profil: Akilli Secici veya menu ile kaydedilen son profil (ayar.ini).
# Kayitli profil yoksa once Akilli Secici calistirilir.
# Cikis kodu: 0 = normal bitti, 1 = baslatilamadi veya iptal edildi.

$ErrorActionPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$Base = $PSScriptRoot
if (-not $Base) { $Base = (Get-Location).Path }
$IniFile = Join-Path $Base 'ayar.ini'

# ------------------------------------------------------------------ AYARLAR

# Roblox acik sayilan islem adlari (Player, Studio, Microsoft Store surumu).
# Roblox sizde farkli bir isimle calisiyorsa buraya ekleyin. Gorev Yoneticisi > Ayrintilar sekmesinden bakabilirsiniz.
$RobloxIslemleri = @('RobloxPlayerBeta', 'RobloxStudioBeta', 'Windows10Universal')
# Roblox hic acilmazsa kac saniye sonra sorulsun
$BeklemeSn = 300
# Roblox kapandiktan sonra kac saniye beklenip GoodbyeDPI kapatilsin (baslatici -> oyun gecislerinde yanlislikla kapanmasin)
# Daha hizli kapansin istiyorsaniz azaltin (en az 3 onerilir). Oyundan oyuna gecerken kapanirsa artirin.
$KapanmaToleransSn = 8
# Baslangicta baglantiyi dogrulamak icin denenecek adresler
$HizliTestHostlari = @('thumbnails.roblox.com', 't0.rbxcdn.com', 'www.roblox.com')

# ayar.ini icinde sadece bu dosyalara izin verilir (yonetici izniyle calistigi icin)
$Gecerli = @{
    'roblox_dnsredir_alternative.cmd'         = 'Google DNS'
    'roblox_dnsredir_alternative2.cmd'        = 'Cloudflare DNS'
    'roblox_dnsredir_alternative_adguard.cmd' = 'AdGuard DNS'
    'roblox_dnsredir.cmd'                     = 'Quad9 DNS'
    'roblox_mod_a.cmd'                        = 'Mod A'
    'roblox_mod_b.cmd'                        = 'Mod B'
    'roblox_mod_c.cmd'                        = 'Mod C'
    'roblox_mod_d.cmd'                        = 'Mod D'
}

# ------------------------------------------------------------------ GORUNUM

# Cizgi karakterleri sadece konsol kod sayfasi destekliyorsa kullanilir, yoksa duz ASCII
$kutu = $false
try {
    $cp = [Console]::OutputEncoding.CodePage
    if (@(65001, 857, 850, 437) -contains $cp) { $kutu = $true }
} catch {}
if ($kutu) {
    $cH = [string][char]0x2500; $cV = [string][char]0x2502
    $cTL = [string][char]0x250C; $cTR = [string][char]0x2510
    $cBL = [string][char]0x2514; $cBR = [string][char]0x2518
} else {
    $cH = '-'; $cV = '|'; $cTL = '+'; $cTR = '+'; $cBL = '+'; $cBR = '+'
}
$W = 80

function Write-BoxLine([string]$t, [string]$renk, [string]$kenar) {
    if ($t.Length -gt ($W - 4)) { $t = $t.Substring(0, $W - 4) }
    Write-Host ($cV + ' ') -NoNewline -ForegroundColor $kenar
    Write-Host $t.PadRight($W - 4) -NoNewline -ForegroundColor $renk
    Write-Host (' ' + $cV) -ForegroundColor $kenar
}

function Write-Banner([string]$baslik, [string[]]$satirlar, [string]$kenar) {
    Write-Host ($cTL + ($cH * ($W - 2)) + $cTR) -ForegroundColor $kenar
    Write-BoxLine $baslik 'White' $kenar
    if ($satirlar) {
        Write-BoxLine '' 'Gray' $kenar
        foreach ($s in $satirlar) { Write-BoxLine $s 'Gray' $kenar }
    }
    Write-Host ($cBL + ($cH * ($W - 2)) + $cBR) -ForegroundColor $kenar
}

function Write-Step([string]$no, [string]$ad) {
    Write-Host ''
    Write-Host ($cH + $cH + ' ') -NoNewline -ForegroundColor DarkCyan
    Write-Host ('[' + $no + '] ' + $ad + ' ') -NoNewline -ForegroundColor Cyan
    $kalan = $W - 7 - $no.Length - $ad.Length
    if ($kalan -lt 2) { $kalan = 2 }
    Write-Host ($cH * $kalan) -ForegroundColor DarkCyan
}

# Ayni satiri surekli guncelleyen durum yazisi (satir basina doner)
function Write-Canli([string]$t, [string]$renk = 'Gray') {
    Write-Host ("`r" + ('   ' + $t).PadRight($W - 1)) -NoNewline -ForegroundColor $renk
}

# Tek tusla E / H secimi. Enter varsayilani secer. Tus okunamazsa Read-Host'a duser.
function Read-Secim([bool]$enterEvet = $false) {
    try {
        while ($true) {
            $k = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            if ($k.VirtualKeyCode -eq 13) { if ($enterEvet) { return 'E' } else { return 'H' } }
            $c = [string]$k.Character
            if ($c -match '^[EeYy]$') { return 'E' }
            if ($c -match '^[HhNn]$') { return 'H' }
        }
    } catch {
        $a = Read-Host ' (E = Evet, H = Hayir)'
        if ($a -match '^\s*[EeYy]') { return 'E' }
        if ($a -match '^\s*[HhNn]') { return 'H' }
        if ($enterEvet) { return 'E' } else { return 'H' }
    }
}

function Ask-Yn([string]$soru, [bool]$varsayilanEvet = $false) {
    Write-Host ('   ' + $soru + '  ') -NoNewline
    Write-Host '[E]' -NoNewline -ForegroundColor Green
    if ($varsayilanEvet) { Write-Host ' Evet (Enter)   ' -NoNewline } else { Write-Host ' Evet   ' -NoNewline }
    Write-Host '[H]' -NoNewline -ForegroundColor Red
    if ($varsayilanEvet) { Write-Host ' Hayir : ' -NoNewline } else { Write-Host ' Hayir (Enter) : ' -NoNewline }
    $s = Read-Secim $varsayilanEvet
    if ($s -eq 'E') { Write-Host 'Evet' -ForegroundColor Green; return $true }
    Write-Host 'Hayir' -ForegroundColor Yellow
    return $false
}

# ------------------------------------------------------------------ YARDIMCILAR

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
    if (-not (Test-Path -LiteralPath $yol)) { return $false }
    Start-Process -FilePath $yol -WorkingDirectory $Base -WindowStyle Minimized | Out-Null
    for ($i = 0; $i -lt 24; $i++) {
        if ((Get-Gdpi).Count -gt 0) { break }
        Start-Sleep -Milliseconds 250
    }
    if ((Get-Gdpi).Count -eq 0) { return $false }
    Start-Sleep -Seconds 2
    return ((Get-Gdpi).Count -gt 0)
}

function Roblox-Var {
    $p = @(Get-Process -Name $RobloxIslemleri -ErrorAction SilentlyContinue)
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

# Bekleme sirasinda Q veya K tusuna basildi mi?
function Cikis-Istendi {
    try {
        while ($Host.UI.RawUI.KeyAvailable) {
            $k = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            if ([string]$k.Character -match '^[QqKk]$') { return $true }
        }
    } catch {}
    return $false
}

function Format-Sure([TimeSpan]$t) {
    return ('{0}:{1:00}' -f [int][math]::Floor($t.TotalMinutes), $t.Seconds)
}

# Baslangicta baglanti dogrulamasi: adresler ayni anda (once DNS, sonra HTTPS). Erisilen adres sayisini dondurur.
function Test-Hizli {
    $isler = @()
    foreach ($h in $HizliTestHostlari) {
        $a = $null
        try { $a = [System.Net.Dns]::BeginGetHostAddresses($h, $null, $null) } catch {}
        $isler += [pscustomobject]@{ Host = $h; DAsync = $a; DOk = $false; Req = $null; Async = $null; Ok = $false }
    }
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt 4000) {
        $hepsi = $true
        foreach ($i in $isler) { if ($i.DAsync -and -not $i.DAsync.IsCompleted) { $hepsi = $false } }
        if ($hepsi) { break }
        Start-Sleep -Milliseconds 30
    }
    foreach ($i in $isler) {
        if ($i.DAsync -and $i.DAsync.IsCompleted) {
            try { if (([System.Net.Dns]::EndGetHostAddresses($i.DAsync)).Count -gt 0) { $i.DOk = $true } } catch {}
        }
    }
    foreach ($i in $isler) {
        if (-not $i.DOk) { continue }
        try {
            $r = [System.Net.HttpWebRequest]::Create('https://' + $i.Host + '/')
            $r.Method = 'HEAD'
            $r.AllowAutoRedirect = $false
            $r.Proxy = $null
            $i.Req = $r
            $i.Async = $r.BeginGetResponse($null, $null)
        } catch {}
    }
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt 6000) {
        $hepsi = $true
        foreach ($i in $isler) { if ($i.Async -and -not $i.Async.IsCompleted) { $hepsi = $false } }
        if ($hepsi) { break }
        Start-Sleep -Milliseconds 30
    }
    $okSay = 0
    foreach ($i in $isler) {
        if ($i.Async) {
            if ($i.Async.IsCompleted) {
                try { $resp = $i.Req.EndGetResponse($i.Async); $i.Ok = $true; $resp.Close() } catch {
                    $ex = $_.Exception
                    if ($ex.InnerException) { $ex = $ex.InnerException }
                    if ($ex.Response) { $i.Ok = $true; $ex.Response.Close() }
                }
            } else { $i.Req.Abort() }
        }
        if ($i.Ok) { $okSay++ }
    }
    return $okSay
}

# ------------------------------------------------------------------ ANA AKIS

Clear-Host
Write-Banner 'GoodbyeDPI Roblox Fix  -  Roblox ile Baslat' @(
    'GoodbyeDPI acilir, Roblox kapaninca kendiliginden kapanir.',
    'Bu pencereyi oyun boyunca acik birakin. Beklerken Q tusu ile iptal edebilirsiniz.'
) 'DarkCyan'

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Host ''
    Write-Host '[HATA] Yonetici izni gerekli. DNSTEST.bat dosyasini kullanin.' -ForegroundColor Red
    exit 1
}

$profil = Oku-Profil
if (-not $profil) {
    Write-Host ''
    Write-Host '[i] Kayitli profil yok. Once Akilli Secici calistirilacak (2-5 dakika surer).' -ForegroundColor Yellow
    $sec = Join-Path $Base 'akilli_secici.ps1'
    if (-not (Test-Path -LiteralPath $sec)) {
        Write-Host '[HATA] akilli_secici.ps1 bulunamadi.' -ForegroundColor Red
        exit 1
    }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $sec
    if ($LASTEXITCODE -ne 0) {
        Write-Host ''
        Write-Host '[HATA] Profil secilemedi, Roblox ile baslatma iptal edildi.' -ForegroundColor Red
        exit 1
    }
    $profil = Oku-Profil
    if (-not $profil) {
        Write-Host '[HATA] Kaydedilen profil okunamadi.' -ForegroundColor Red
        exit 1
    }
}

$benBasladim = $false
$oturumBasla = Get-Date
try {
    Write-Step '1/3' ('GoodbyeDPI - ' + $profil.Ad)
    if ((Get-Gdpi).Count -gt 0) {
        Write-Host '   [i] GoodbyeDPI zaten calisiyor. Ona dokunulmayacak, Roblox kapaninca da kapatilmayacak.' -ForegroundColor Yellow
    } else {
        Write-Host '   Baslatiliyor...' -ForegroundColor DarkGray
        $benBasladim = $true
        if (-not (Start-Profil $profil.Dosya)) {
            $benBasladim = $false
            Write-Host '   [HATA] GoodbyeDPI baslatilamadi (antivirus engelliyor olabilir).' -ForegroundColor Red
            Write-Host '          DNSTEST.bat menusunden A ile sorun raporu alabilirsiniz.'
            exit 1
        }
        Write-Host '   [ OK ] GoodbyeDPI calisiyor.' -ForegroundColor Green

        # Baglanti dogrulamasi: profil bu aginizda hala ise yariyor mu?
        Write-Host '   Baglanti dogrulaniyor...' -ForegroundColor DarkGray
        $ok = Test-Hizli
        if ($ok -ge 1) {
            Write-Host ('   [ OK ] Roblox adreslerine erisiliyor (' + $ok + '/' + $HizliTestHostlari.Count + ').') -ForegroundColor Green
        } else {
            Write-Host '   [ !! ] Roblox adreslerine erisilemedi. Bu profil artik calismiyor olabilir (ag/ISS degismis olabilir).' -ForegroundColor Yellow
            $sec = Join-Path $Base 'akilli_secici.ps1'
            if ((Test-Path -LiteralPath $sec) -and (Ask-Yn 'Akilli Secici simdi tekrar calistirilsin mi?' $true)) {
                Stop-Gdpi
                & powershell -NoProfile -ExecutionPolicy Bypass -File $sec
                if ($LASTEXITCODE -eq 0) {
                    $yeni = Oku-Profil
                    if ($yeni) { $profil = $yeni }
                }
                Write-Step '1/3' ('GoodbyeDPI - ' + $profil.Ad)
                if (-not (Start-Profil $profil.Dosya)) {
                    $benBasladim = $false
                    Write-Host '   [HATA] GoodbyeDPI baslatilamadi.' -ForegroundColor Red
                    exit 1
                }
                Write-Host '   [ OK ] GoodbyeDPI calisiyor.' -ForegroundColor Green
            }
        }
    }

    Write-Step '2/3' 'Roblox bekleniyor'
    Write-Host "   Simdi Roblox'u acabilirsiniz." -ForegroundColor Green
    Write-Host '   (Pencereyi yanlislikla kapatirsaniz GoodbyeDPI acik kalir, siyah GoodbyeDPI penceresini elle kapatabilirsiniz.)' -ForegroundColor DarkGray
    Write-Host ''

    $durum = 'bekle'
    $bekleBasla = Get-Date
    $robloxBasla = $null
    $kapaliBasla = $null
    $yenidenDenendi = $false
    $iptal = $false

    while ($true) {
        if (Cikis-Istendi) { $iptal = $true; break }
        $roblox = Roblox-Var

        # GoodbyeDPI'i biz actiysak ve beklenmedik sekilde kapandiysa bir kez yeniden baslat
        if ($benBasladim -and (Get-Gdpi).Count -eq 0) {
            Write-Host ''
            if (-not $yenidenDenendi) {
                $yenidenDenendi = $true
                Write-Host '   [ !! ] GoodbyeDPI beklenmedik sekilde kapandi, yeniden baslatiliyor...' -ForegroundColor Yellow
                if (Start-Profil $profil.Dosya) {
                    Write-Host '   [ OK ] GoodbyeDPI yeniden calisiyor.' -ForegroundColor Green
                } else {
                    $benBasladim = $false
                    Write-Host '   [HATA] Yeniden baslatilamadi.' -ForegroundColor Red
                }
            } else {
                $benBasladim = $false
                Write-Host '   [HATA] GoodbyeDPI tekrar kapandi, tekrar baslatilmayacak.' -ForegroundColor Red
            }
        }

        if ($durum -eq 'bekle') {
            if ($roblox) {
                $durum = 'oyun'
                $robloxBasla = Get-Date
                Write-Host ''
                Write-Step '3/3' 'Roblox calisiyor'
                Write-Host '   [ OK ] Roblox algilandi. Kapanana kadar GoodbyeDPI acik kalacak.' -ForegroundColor Green
                continue
            }
            $gecen = (Get-Date) - $bekleBasla
            Write-Canli ('Roblox bekleniyor...  ' + (Format-Sure $gecen) + '    [Q] iptal') 'DarkGray'
            if ($gecen.TotalSeconds -ge $BeklemeSn) {
                Write-Host ''
                if (-not (Ask-Yn 'Roblox hala acilmadi. Beklemeye devam edilsin mi?' $true)) { $iptal = $true; break }
                $bekleBasla = Get-Date
            }
        } else {
            if ($roblox) {
                $kapaliBasla = $null
                Write-Canli ('Oyun suresi: ' + (Format-Sure ((Get-Date) - $robloxBasla)) + '    [Q] hemen kapat') 'Green'
            } else {
                if (-not $kapaliBasla) { $kapaliBasla = Get-Date }
                $kalan = [int][math]::Ceiling($KapanmaToleransSn - ((Get-Date) - $kapaliBasla).TotalSeconds)
                if ($kalan -le 0) { break }
                Write-Canli ('Roblox kapandi, GoodbyeDPI ' + $kalan + ' sn icinde kapatilacak...    [Q] hemen kapat') 'Yellow'
            }
        }
        Start-Sleep -Seconds 1
    }
    Write-Host ''

    if ($iptal) {
        Write-Host '   Iptal edildi.' -ForegroundColor Yellow
    } elseif ($durum -eq 'oyun') {
        Write-Host '   [ OK ] Roblox kapandi.' -ForegroundColor Green
    }
} finally {
    if ($benBasladim) {
        Write-Host '   GoodbyeDPI kapatiliyor...' -ForegroundColor DarkGray
        Stop-Gdpi
        Write-Host '   [ OK ] GoodbyeDPI kapatildi.' -ForegroundColor Green
    }
}

$toplam = Format-Sure ((Get-Date) - $oturumBasla)
Write-Host ''
Write-Banner 'Oturum bitti' @(('Toplam sure: ' + $toplam), 'Tekrar oynamak icin DNSTEST menusunden 2 (Roblox ile baslat) yeterli.') 'Green'
exit 0
