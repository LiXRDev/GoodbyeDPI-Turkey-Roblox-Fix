# GoodbyeDPI Roblox Fix - Akilli Secici
# Her profili gercekten calistirip Roblox adreslerine HTTPS ile erisimi olcer.
# (Ping sonucu degil, gercek baglanti sonucuna bakar.)
# Cikis kodu: 0 = profil secildi ve ayar.ini'ye yazildi, 1 = secilemedi veya iptal edildi.

$ErrorActionPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$Base = $PSScriptRoot
$IniFile = Join-Path $Base 'ayar.ini'

# Test edilecek profiller (menudeki isimlerle ayni)
$Profiller = @(
    @{ Ad = 'Google DNS';     Dosya = 'roblox_dnsredir_alternative.cmd' },
    @{ Ad = 'Cloudflare DNS'; Dosya = 'roblox_dnsredir_alternative2.cmd' },
    @{ Ad = 'AdGuard DNS';    Dosya = 'roblox_dnsredir_alternative_adguard.cmd' },
    @{ Ad = 'Quad9 DNS';      Dosya = 'roblox_dnsredir.cmd' }
)

# Erisim denenecek Roblox adresleri (gorsel/avatar sorununu yakalamak icin CDN adresleri dahil)
$TestHostlari = @(
    'thumbnails.roblox.com',
    'assetdelivery.roblox.com',
    't0.rbxcdn.com',
    'css.rbxcdn.com',
    'www.roblox.com'
)
$ZamanAsimiMs = 6000
# Calisan profillerin hizi birden fazla turda olculur, ortalamasi alinir (tek olcum sansa bagli olur)
$TurSayisi = 3

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

# Profil dosyasini calistirir, GoodbyeDPI surecinin acilmasini bekler
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

# Tum adreslere ayni anda HTTPS istegi gonderir. Herhangi bir HTTP yaniti = erisim var.
# TLS/baglanti hatasi veya zaman asimi = erisim yok (DPI engeli genelde boyle gorunur).
function Test-Erisim {
    $isler = @()
    foreach ($h in $TestHostlari) {
        $r = [System.Net.HttpWebRequest]::Create('https://' + $h + '/')
        $r.Method = 'HEAD'
        $r.AllowAutoRedirect = $false
        $r.Proxy = $null
        $r.UserAgent = 'GoodbyeDPI-Roblox-Fix-Test'
        $isler += [pscustomobject]@{
            Host = $h; Req = $r; Async = $r.BeginGetResponse($null, $null)
            Done = $false; Ms = $ZamanAsimiMs; Ok = $false
        }
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt $ZamanAsimiMs) {
        $hepsi = $true
        foreach ($i in $isler) {
            if (-not $i.Done) {
                if ($i.Async -and $i.Async.IsCompleted) {
                    $i.Done = $true
                    $i.Ms = [int]$sw.ElapsedMilliseconds
                } else { $hepsi = $false }
            }
        }
        if ($hepsi) { break }
        Start-Sleep -Milliseconds 50
    }

    $okSay = 0
    $toplamMs = 0
    foreach ($i in $isler) {
        if ($i.Done) {
            try {
                $resp = $i.Req.EndGetResponse($i.Async)
                $i.Ok = $true
                $resp.Close()
            } catch {
                $ex = $_.Exception
                if ($ex.InnerException) { $ex = $ex.InnerException }
                if ($ex.Response) { $i.Ok = $true; $ex.Response.Close() }
            }
        } else {
            $i.Req.Abort()
        }
        if ($i.Ok) { $okSay++; $toplamMs += $i.Ms }
    }
    $ort = 99999
    if ($okSay -gt 0) { $ort = [int]($toplamMs / $okSay) }
    return [pscustomobject]@{ Ok = $okSay; Toplam = $isler.Count; OrtMs = $ort }
}

# Bir profili $TurSayisi kez test eder. Her turdan once DNS onbellegi temizlenir, boylece
# DNS cevap suresi de olcume dahil olur. Erisim her turda saglanmali (en dusuk tur sonucu alinir).
# Ilk turda hic adrese erisilemiyorsa profil calismiyordur, kalan turlar atlanir.
function Test-Profil {
    $minOk = -1
    $toplamOrt = 0
    $turSay = 0
    $toplam = $TestHostlari.Count
    for ($t = 0; $t -lt $TurSayisi; $t++) {
        ipconfig /flushdns | Out-Null
        $s = Test-Erisim
        $toplam = $s.Toplam
        if ($minOk -lt 0 -or $s.Ok -lt $minOk) { $minOk = $s.Ok }
        if ($s.Ok -eq 0) { break }
        $toplamOrt += $s.OrtMs
        $turSay++
    }
    $ort = 99999
    if ($turSay -gt 0) { $ort = [int]($toplamOrt / $turSay) }
    return [pscustomobject]@{ Ok = $minOk; Toplam = $toplam; OrtMs = $ort }
}

function Yaz-Sonuc([string]$ad, $s) {
    $renk = 'Red'
    if ($s.Ok -eq $s.Toplam) { $renk = 'Green' } elseif ($s.Ok -gt 0) { $renk = 'Yellow' }
    $ms = ''
    if ($s.Ok -gt 0) { $ms = '  (ortalama ' + $s.OrtMs + ' ms)' }
    Write-Host ('   ' + $ad.PadRight(22) + ': ' + $s.Ok + '/' + $s.Toplam + ' adrese erisildi' + $ms) -ForegroundColor $renk
}

# ------------------------------------------------------------------ ANA AKIS

Write-Host ''
Write-Host '=== Akilli Secici ===' -ForegroundColor Cyan
Write-Host 'Her profil sirayla calistirilip Roblox adreslerine gercekten baglanilmaya calisilir.'
Write-Host 'Hangi profilin SIZIN internetinizde ise yaradigini bulur. Birden fazlasi calisirsa en hizlisini secer.'
Write-Host 'Yaklasik 2-3 dakika surer.'
Write-Host 'Test sirasinda GoodbyeDPI pencereleri kisaca acilip kapanabilir, kapatmayin.'
Write-Host ''

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Host '[X] Yonetici izni gerekli. DNSTEST.bat dosyasini kullanin veya sag tik > Yonetici olarak calistir deyin.' -ForegroundColor Red
    exit 1
}

$mevcut = @($Profiller | Where-Object { Test-Path -LiteralPath (Join-Path $Base $_.Dosya) })
if ($mevcut.Count -eq 0) {
    Write-Host '[X] Profil dosyalari (roblox_dnsredir*.cmd) bu klasorde bulunamadi.' -ForegroundColor Red
    exit 1
}

# Servis olarak kurulu ve calisiyorsa test edilemez (iki GoodbyeDPI cakisir)
$svc = @(Get-Service | Where-Object { ($_.Name -like '*goodbye*' -or $_.DisplayName -like '*goodbye*') -and $_.Status -eq 'Running' })
if ($svc.Count -gt 0) {
    Write-Host '[X] GoodbyeDPI servisi kurulu ve calisiyor, test onunla cakisir.' -ForegroundColor Red
    Write-Host '    Once service_remove.cmd ile servisi kaldirin, sonra tekrar deneyin.'
    exit 1
}

if ((Get-Gdpi).Count -gt 0) {
    Write-Host 'GoodbyeDPI su an calisiyor. Test icin kapatilmasi gerekir.' -ForegroundColor Yellow
    if (-not (Ask-Yn 'Simdi kapatilsin mi?')) {
        Write-Host 'Iptal edildi.'
        exit 1
    }
    Stop-Gdpi
}

Write-Host 'Kontrol: GoodbyeDPI olmadan' -ForegroundColor Cyan
ipconfig /flushdns | Out-Null
$baz = Test-Erisim
Yaz-Sonuc 'GoodbyeDPI olmadan' $baz

$sonuclar = @()
$n = 0
foreach ($p in $mevcut) {
    $n++
    Write-Host ''
    Write-Host ('Test ' + $n + '/' + $mevcut.Count + ': ' + $p.Ad) -ForegroundColor Cyan
    Stop-Gdpi
    ipconfig /flushdns | Out-Null
    if (-not (Start-Profil $p.Dosya)) {
        Write-Host '   Baslatilamadi (antivirus engelliyor olabilir), atlandi.' -ForegroundColor Red
        continue
    }
    $s = Test-Profil
    Stop-Gdpi
    Yaz-Sonuc $p.Ad $s
    $sonuclar += [pscustomobject]@{ Ad = $p.Ad; Dosya = $p.Dosya; Ok = $s.Ok; Toplam = $s.Toplam; OrtMs = $s.OrtMs }
}
ipconfig /flushdns | Out-Null

Write-Host ''
if ($sonuclar.Count -eq 0) {
    Write-Host '[X] Hicbir profil baslatilamadi. Antivirus GoodbyeDPI i engelliyor olabilir.' -ForegroundColor Red
    Write-Host '    DNSTEST.bat menusunden A ile sorun raporu alabilirsiniz.'
    exit 1
}

# Calisan = en cok adrese erisebilen profil(ler). Birden fazlaysa en hizlisi (en dusuk ortalama ms) secilir.
$enOk = ($sonuclar | Measure-Object -Property Ok -Maximum).Maximum
$calisanlar = @($sonuclar | Where-Object { $_.Ok -eq $enOk } | Sort-Object -Property OrtMs)
$en = $calisanlar[0]

if ($enOk -gt 0) {
    Write-Host 'Siralama (en hizli en ustte):' -ForegroundColor Cyan
    $sira = 0
    foreach ($c in $calisanlar) {
        $sira++
        Write-Host ('   ' + $sira + '. ' + $c.Ad.PadRight(16) + ' ' + $c.Ok + '/' + $c.Toplam + ' adres, ortalama ' + $c.OrtMs + ' ms')
    }
    if ($calisanlar.Count -gt 1) {
        Write-Host ('   -> ' + $calisanlar.Count + ' profil calisiyor, en hizli olan secildi.')
    }
    Write-Host ''
}

if ($en.Ok -eq 0) {
    Write-Host '[X] Hicbir profil Roblox adreslerine erisim saglayamadi.' -ForegroundColor Red
    Write-Host '    Olasi nedenler: antivirus (Kaspersky vb.) aga mudahale ediyor, internet kesik, ISS farkli bir engel uyguluyor.'
    Write-Host '    DNSTEST.bat menusunden A ile sorun raporu alip GitHub Issues kismina yapistirin.'
    exit 1
}

if ($en.Ok -le $baz.Ok) {
    Write-Host ('[i] Hicbir profil, GoodbyeDPI olmadan yapilan testten daha iyi sonuc vermedi (' + $baz.Ok + '/' + $baz.Toplam + ').') -ForegroundColor Yellow
    if ($baz.Ok -eq $baz.Toplam) {
        Write-Host '    Test adreslerine zaten erisiliyor. Gorsel sorunu baska bir yerden geliyor olabilir (Roblox onbellegi: menu 8).'
    }
    if (-not (Ask-Yn ('Yine de en hizli profil (' + $en.Ad + ') kaydedilsin mi?'))) {
        exit 1
    }
}

Set-Content -Path $IniFile -Value @(('profile=' + $en.Dosya), ('name=' + $en.Ad)) -Encoding ASCII
Write-Host ('[v] Sizin icin en iyi profil: ' + $en.Ad + '  (' + $en.Ok + '/' + $en.Toplam + ' adres, ortalama ' + $en.OrtMs + ' ms)') -ForegroundColor Green
Write-Host '    Kaydedildi. Menuden "Son kullanilan profil" veya "Roblox ile baslat" ile kullanabilirsiniz.'
exit 0