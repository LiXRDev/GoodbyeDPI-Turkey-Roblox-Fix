# GoodbyeDPI Roblox Fix - Akilli Secici
# Her profili gercekten calistirip Roblox adreslerine DNS + HTTPS ile erisimi olcer.
# (Ping sonucu degil, gercek baglanti sonucuna bakar.)
# Cikis kodu: 0 = profil secildi ve ayar.ini'ye yazildi, 1 = secilemedi veya iptal edildi.

$ErrorActionPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$Base = $PSScriptRoot
if (-not $Base) { $Base = (Get-Location).Path }
$IniFile = Join-Path $Base 'ayar.ini'
$BaslangicZamani = Get-Date

# ------------------------------------------------------------------ AYARLAR

# Test edilecek profiller (menudeki isimlerle ayni)
$Profiller = @(
    @{ Ad = 'Google DNS';     Dosya = 'roblox_dnsredir_alternative.cmd' },
    @{ Ad = 'Cloudflare DNS'; Dosya = 'roblox_dnsredir_alternative2.cmd' },
    @{ Ad = 'AdGuard DNS';    Dosya = 'roblox_dnsredir_alternative_adguard.cmd' },
    @{ Ad = 'Quad9 DNS';      Dosya = 'roblox_dnsredir.cmd' }
)

# 2. asama: DNS profilleri yetmezse, en iyi DNS profili temel alinip "-5 --set-ttl 5" yerine bu bayraklar kullanilir.
# Dosyalar roblox_mod_*.cmd adiyla otomatik uretilir (DNS ayarlari temel profilden aynen alinir).
$Modlar = @(
    @{ Ad = 'Mod A'; Dosya = 'roblox_mod_a.cmd'; Bayrak = '-6 --set-ttl 5'; Aciklama = 'sahte paket sirasi (wrong-seq)' },
    @{ Ad = 'Mod B'; Dosya = 'roblox_mod_b.cmd'; Bayrak = '-7 --set-ttl 5'; Aciklama = 'bozuk saglama toplami (wrong-chksum)' },
    @{ Ad = 'Mod C'; Dosya = 'roblox_mod_c.cmd'; Bayrak = '-9 --set-ttl 5'; Aciklama = 'ikisi birden + QUIC engeli' },
    @{ Ad = 'Mod D'; Dosya = 'roblox_mod_d.cmd'; Bayrak = '-4';             Aciklama = 'eski uyumlu mod (parcalama)' }
)

# Erisim denenecek Roblox adresleri (gorsel/avatar sorununu yakalamak icin CDN adresleri dahil)
$TestHostlari = @(
    'thumbnails.roblox.com',
    'assetdelivery.roblox.com',
    't0.rbxcdn.com',
    'css.rbxcdn.com',
    'www.roblox.com'
)
$DnsZamanAsimiMs = 4000
$ZamanAsimiMs = 6000
# Calisan profillerin hizi birden fazla turda olculur, ortalamasi alinir (tek olcum sansa bagli olur)
$TurSayisi = 3

$script:BenBaslattim = $false
$script:Kazanan = $null
$script:AvGosterildi = $false

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
    $cBlk = [string][char]0x2588
} else {
    $cH = '-'; $cV = '|'; $cTL = '+'; $cTR = '+'; $cBL = '+'; $cBR = '+'; $cBlk = '#'
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

# ayar.ini icindeki kayitli profil dosyasi adi (yoksa bos)
function Get-KayitliDosya {
    if (-not (Test-Path -LiteralPath $IniFile)) { return '' }
    foreach ($satir in (Get-Content -LiteralPath $IniFile)) {
        if ($satir -match '^\s*profile\s*=\s*(.+?)\s*$') { return $Matches[1] }
    }
    return ''
}

# Temel profil dosyasindaki "-5 --set-ttl 5" yerine mod bayraklarini koyup yeni bir .cmd uretir
function New-ModProfil([string]$temelDosya, $mod) {
    $re = '-5\s+--set-ttl\s+5'
    try { $txt = [IO.File]::ReadAllText((Join-Path $Base $temelDosya)) } catch { return $false }
    if ($txt -notmatch $re) { return $false }
    $yeni = [regex]::Replace($txt, $re, $mod.Bayrak)
    try { [IO.File]::WriteAllText((Join-Path $Base $mod.Dosya), $yeni, (New-Object Text.UTF8Encoding($false))) } catch { return $false }
    return $true
}

# Kullanilmayan uretilmis mod dosyalarini siler (kazanan veya kayitli profil kalir)
function Remove-ModDosyalari {
    $koru = $script:Kazanan
    if (-not $koru) { $koru = Get-KayitliDosya }
    Get-ChildItem -LiteralPath $Base -Filter 'roblox_mod_*.cmd' | Where-Object { $_.Name -ne $koru } | Remove-Item -Force -ErrorAction SilentlyContinue
}

# Etkin antivirusleri listeler. Silinmis ama kaydi kalmis (kalinti) antivirusler atlanir.
function Get-AktifAv {
    $liste = @()
    try { $av = @(Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntiVirusProduct -ErrorAction Stop) } catch { return @() }
    foreach ($a in $av) {
        $durum = [int]$a.productState
        if (($durum -band 0x1000) -eq 0) { continue }
        $yol = [Environment]::ExpandEnvironmentVariables([string]$a.pathToSignedProductExe)
        if ($yol -match '^[A-Za-z]:\\' -and -not (Test-Path -LiteralPath $yol)) { continue }
        $liste += [string]$a.displayName
    }
    return $liste
}

function Show-AvOnerisi {
    if ($script:AvGosterildi) { return }
    $script:AvGosterildi = $true
    Write-Step '!' 'Antivirus kontrolu'
    $av = @(Get-AktifAv)
    $mp = @()
    try { $mp = @(Get-MpThreatDetection | Where-Object { (($_.Resources -join ' ') -match 'goodbyedpi|windivert') }) } catch {}
    if ($av.Count -gt 0) { Write-Host ('   Etkin antivirus: ' + ($av -join ', ')) } else { Write-Host '   Etkin antivirus bilgisi alinamadi.' }
    if ($mp.Count -gt 0) {
        Write-Host '   [!] Windows Defender GoodbyeDPI/WinDivert dosyalarini tehdit olarak isaretlemis (Koruma gecmisinde gorunur).' -ForegroundColor Red
    }
    Write-Host '   Yapabilecekleriniz:' -ForegroundColor Yellow
    Write-Host ('   1) Bu klasoru antivirusun istisna / dislama listesine ekleyin: ' + $Base)
    if ($mp.Count -gt 0) {
        Write-Host '   2) Windows Guvenligi > Virus ve tehdit korumasi > Koruma gecmisi: karantinadaki dosyalari geri yukleyin.'
    } else {
        Write-Host '   2) Antivirusun karantina / engellenenler bolumune bakin, GoodbyeDPI veya WinDivert dosyasi varsa geri yukleyin.'
    }
    Write-Host '   3) Gelismis antivirusler (Kaspersky, ESET, Bitdefender vb.) agi kendileri tarar.'
    Write-Host '      "Sifreli baglantilari tara" / SSL tarama ozelligini gecici kapatin.'
    Write-Host '   4) Sonra Akilli Seciciyi tekrar calistirin.'
}

# Profil dosyasini calistirir, GoodbyeDPI surecinin acilmasini ve ayakta kalmasini bekler
function Start-Profil([string]$dosya) {
    $yol = Join-Path $Base $dosya
    if (-not (Test-Path -LiteralPath $yol)) { return $false }
    $script:BenBaslattim = $true
    Start-Process -FilePath $yol -WorkingDirectory $Base -WindowStyle Minimized | Out-Null
    for ($i = 0; $i -lt 24; $i++) {
        if ((Get-Gdpi).Count -gt 0) { break }
        Start-Sleep -Milliseconds 250
    }
    if ((Get-Gdpi).Count -eq 0) { return $false }
    Start-Sleep -Seconds 2
    return ((Get-Gdpi).Count -gt 0)
}

# ------------------------------------------------------------------ OLCUM

# Tum adreslere AYNI ANDA: once DNS cozumu, sonra HTTPS istegi. Herhangi bir HTTP yaniti = erisim var.
# TLS/baglanti hatasi veya zaman asimi = erisim yok (DPI engeli genelde boyle gorunur).
# Sure = DNS suresi + HTTPS suresi (DNS profilleri arasindaki farki da yansitir).
function Test-Erisim {
    $isler = @()
    foreach ($h in $TestHostlari) {
        $a = $null
        try { $a = [System.Net.Dns]::BeginGetHostAddresses($h, $null, $null) } catch {}
        $isler += [pscustomobject]@{
            Host = $h; DAsync = $a; DDone = $false; DOk = $false; DMs = 0
            Req = $null; Async = $null; Done = $false; HMs = 0; Ok = $false
        }
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt $DnsZamanAsimiMs) {
        $hepsi = $true
        foreach ($i in $isler) {
            if ($i.DAsync -and -not $i.DDone) {
                if ($i.DAsync.IsCompleted) {
                    $i.DDone = $true
                    $i.DMs = [int]$sw.ElapsedMilliseconds
                } else { $hepsi = $false }
            }
        }
        if ($hepsi) { break }
        Start-Sleep -Milliseconds 30
    }
    foreach ($i in $isler) {
        if ($i.DDone) {
            try {
                $adr = [System.Net.Dns]::EndGetHostAddresses($i.DAsync)
                if ($adr.Count -gt 0) { $i.DOk = $true }
            } catch {}
        }
    }

    foreach ($i in $isler) {
        if (-not $i.DOk) { continue }
        try {
            $r = [System.Net.HttpWebRequest]::Create('https://' + $i.Host + '/')
            $r.Method = 'HEAD'
            $r.AllowAutoRedirect = $false
            $r.Proxy = $null
            $r.UserAgent = 'GoodbyeDPI-Roblox-Fix-Test'
            $i.Req = $r
            $i.Async = $r.BeginGetResponse($null, $null)
        } catch {}
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt $ZamanAsimiMs) {
        $hepsi = $true
        foreach ($i in $isler) {
            if ($i.Async -and -not $i.Done) {
                if ($i.Async.IsCompleted) {
                    $i.Done = $true
                    $i.HMs = [int]$sw.ElapsedMilliseconds
                } else { $hepsi = $false }
            }
        }
        if ($hepsi) { break }
        Start-Sleep -Milliseconds 30
    }

    $okSay = 0
    $toplamMs = 0
    foreach ($i in $isler) {
        if ($i.Async) {
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
        }
        if ($i.Ok) { $okSay++; $toplamMs += ($i.DMs + $i.HMs) }
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
        $ms = '-'
        if ($s.Ok -gt 0) { $ms = ('' + $s.OrtMs + ' ms') }
        Write-Host ('        tur ' + ($t + 1) + '/' + $TurSayisi + ': ' + $s.Ok + '/' + $s.Toplam + ' adres, ' + $ms) -ForegroundColor DarkGray
        if ($minOk -lt 0 -or $s.Ok -lt $minOk) { $minOk = $s.Ok }
        if ($s.Ok -eq 0) { break }
        $toplamOrt += $s.OrtMs
        $turSay++
    }
    $ort = 99999
    if ($turSay -gt 0) { $ort = [int]($toplamOrt / $turSay) }
    return [pscustomobject]@{ Ok = $minOk; Toplam = $toplam; OrtMs = $ort }
}

function Write-Sonuc([string]$ad, $s) {
    $renk = 'Red'
    $isaret = '[HATA]'
    if ($s.Ok -eq $s.Toplam) { $renk = 'Green'; $isaret = '[ OK ]' } elseif ($s.Ok -gt 0) { $renk = 'Yellow'; $isaret = '[ !! ]' }
    $ms = ''
    if ($s.Ok -gt 0) { $ms = '  ortalama ' + $s.OrtMs + ' ms' }
    Write-Host ('   ' + $isaret + ' ' + $ad.PadRight(18) + $s.Ok + '/' + $s.Toplam + ' adres' + $ms) -ForegroundColor $renk
}

# Tek bir adrese ardisik yeni baglantilar acip gecikme ve basarisizlik sayisini olcer
function Test-Gecikme([string]$hostAd, [int]$adet) {
    $olc = @()
    $hata = 0
    for ($k = 0; $k -lt $adet; $k++) {
        $r = [System.Net.HttpWebRequest]::Create('https://' + $hostAd + '/')
        $r.Method = 'HEAD'
        $r.AllowAutoRedirect = $false
        $r.Proxy = $null
        $r.KeepAlive = $false
        $r.Timeout = 4000
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $ok = $false
        try { $resp = $r.GetResponse(); $ok = $true; $resp.Close() } catch {
            $ex = $_.Exception
            if ($ex.InnerException) { $ex = $ex.InnerException }
            if ($ex.Response) { $ok = $true; $ex.Response.Close() }
        }
        $sw.Stop()
        if ($ok) { $olc += [int]$sw.ElapsedMilliseconds } else { $hata++ }
        Start-Sleep -Milliseconds 200
    }
    return [pscustomobject]@{ Olc = $olc; Hata = $hata; Adet = $adet }
}

function Show-Gecikme {
    $hostlar = @('assetdelivery.roblox.com', 't0.rbxcdn.com')
    $olc = @()
    $hata = 0
    $adet = 0
    foreach ($h in $hostlar) {
        $s = Test-Gecikme $h 8
        $olc += $s.Olc
        $hata += $s.Hata
        $adet += $s.Adet
    }
    if ($olc.Count -eq 0) {
        Write-Host '   [HATA] Gecikme olculemedi: hicbir istek tamamlanmadi.' -ForegroundColor Red
        return
    }
    $ort = [int]($olc | Measure-Object -Average).Average
    $min = ($olc | Measure-Object -Minimum).Minimum
    $max = ($olc | Measure-Object -Maximum).Maximum
    $kayip = [int](100 * $hata / $adet)
    $yorum = 'Iyi'; $renk = 'Green'
    if ($ort -ge 1000) { $yorum = 'Yavas'; $renk = 'Yellow' } elseif ($ort -ge 500) { $yorum = 'Orta'; $renk = 'Yellow' }
    if ($kayip -ge 10) { $yorum = 'Kararsiz (istekler basarisiz oluyor)'; $renk = 'Red' }
    Write-Host ('   Gecikme: ortalama ' + $ort + ' ms (en az ' + $min + ', en cok ' + $max + '), basarisiz istek %' + $kayip + '  ->  ' + $yorum) -ForegroundColor $renk
}

# ------------------------------------------------------------------ ANA AKIS

Clear-Host
Write-Banner 'GoodbyeDPI Roblox Fix  -  Akilli Secici' @(
    'Her profil sirayla calistirilip Roblox adreslerine gercekten baglanilir.',
    'Ping degil gercek baglanti olculur. Calisan en hizli profil secilir.',
    'Sure: yaklasik 2-5 dk. GoodbyeDPI pencereleri kisaca acilip kapanabilir.'
) 'DarkCyan'

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Host ''
    Write-Host '[HATA] Yonetici izni gerekli. DNSTEST.bat dosyasini kullanin veya sag tik > Yonetici olarak calistir deyin.' -ForegroundColor Red
    exit 1
}

$mevcut = @($Profiller | Where-Object { Test-Path -LiteralPath (Join-Path $Base $_.Dosya) })
if ($mevcut.Count -eq 0) {
    Write-Host ''
    Write-Host '[HATA] Profil dosyalari (roblox_dnsredir*.cmd) bu klasorde bulunamadi.' -ForegroundColor Red
    exit 1
}

# Servis olarak kurulu ve calisiyorsa test edilemez (iki GoodbyeDPI cakisir)
$svc = @(Get-Service | Where-Object { ($_.Name -like '*goodbye*' -or $_.DisplayName -like '*goodbye*') -and $_.Status -eq 'Running' })
if ($svc.Count -gt 0) {
    Write-Host ''
    Write-Host '[HATA] GoodbyeDPI servisi kurulu ve calisiyor, test onunla cakisir.' -ForegroundColor Red
    Write-Host '       Once service_remove.cmd ile servisi kaldirin, sonra tekrar deneyin.'
    exit 1
}

if ((Get-Gdpi).Count -gt 0) {
    Write-Host ''
    Write-Host 'GoodbyeDPI su an calisiyor. Test icin kapatilmasi gerekir.' -ForegroundColor Yellow
    if (-not (Ask-Yn 'Simdi kapatilsin mi?')) {
        Write-Host '   Iptal edildi.'
        exit 1
    }
    Stop-Gdpi
}

try {
    Write-Step 'Hazirlik' 'GoodbyeDPI olmadan baz olcum'
    ipconfig /flushdns | Out-Null
    $baz = Test-Erisim
    Write-Sonuc 'GoodbyeDPI olmadan' $baz

    # Zaten her sey aciliyorsa 2-3 dakikalik testi bosuna yaptirmayalim
    if ($baz.Ok -eq $baz.Toplam) {
        Write-Host ''
        Write-Host '[i] GoodbyeDPI olmadan tum adreslere zaten erisiliyor. Muhtemelen GoodbyeDPI gerekmiyor.' -ForegroundColor Yellow
        if (-not (Ask-Yn 'Yine de profiller test edilsin mi?' $true)) {
            Write-Host '   Iptal edildi. Gorseller yuklenmiyorsa Roblox onbellegini temizleyin (DNSTEST menu 8).'
            exit 1
        }
    }

    # --- 1. ASAMA: DNS profilleri ---
    $sonuclar = @()
    $baslatilamadi = $false
    $n = 0
    foreach ($p in $mevcut) {
        $n++
        Write-Step ('' + $n + '/' + $mevcut.Count) $p.Ad
        Stop-Gdpi
        ipconfig /flushdns | Out-Null
        if (-not (Start-Profil $p.Dosya)) {
            Write-Host '   [HATA] Baslatilamadi (antivirus engelliyor olabilir), atlandi.' -ForegroundColor Red
            $baslatilamadi = $true
            continue
        }
        $s = Test-Profil
        Stop-Gdpi
        Write-Sonuc $p.Ad $s
        $sonuclar += [pscustomobject]@{ Ad = $p.Ad; Dosya = $p.Dosya; Ok = $s.Ok; Toplam = $s.Toplam; OrtMs = $s.OrtMs; Not = '' }
    }
    ipconfig /flushdns | Out-Null
    if ($baslatilamadi) { Show-AvOnerisi }

    # --- 2. ASAMA: DNS profilleri tam sonuc vermediyse ek bypass modlari ---
    $tam = $TestHostlari.Count
    $enOk1 = 0
    if ($sonuclar.Count -gt 0) { $enOk1 = ($sonuclar | Measure-Object -Property Ok -Maximum).Maximum }
    if ($sonuclar.Count -gt 0 -and $enOk1 -lt $tam -and $baz.Ok -lt $tam) {
        $temel = $sonuclar | Sort-Object -Property @{ Expression = 'Ok'; Descending = $true }, @{ Expression = 'OrtMs'; Descending = $false } | Select-Object -First 1
        Write-Host ''
        Write-Host ('2. asama: DNS profilleri tam sonuc vermedi. Ek bypass modlari deneniyor (temel: ' + $temel.Ad + ').') -ForegroundColor Cyan
        $m = 0
        foreach ($mod in $Modlar) {
            $m++
            Write-Step ('Mod ' + $m + '/' + $Modlar.Count) ($mod.Ad + ' - ' + $mod.Aciklama)
            if (-not (New-ModProfil $temel.Dosya $mod)) {
                Write-Host ('   [!!] ' + $temel.Dosya + ' icinde "-5 --set-ttl 5" bulunamadi, ek modlar atlandi.') -ForegroundColor Yellow
                break
            }
            Stop-Gdpi
            ipconfig /flushdns | Out-Null
            if (-not (Start-Profil $mod.Dosya)) {
                Write-Host '   [HATA] Baslatilamadi, atlandi.' -ForegroundColor Red
                continue
            }
            $s = Test-Profil
            Stop-Gdpi
            Write-Sonuc $mod.Ad $s
            $sonuclar += [pscustomobject]@{ Ad = $mod.Ad; Dosya = $mod.Dosya; Ok = $s.Ok; Toplam = $s.Toplam; OrtMs = $s.OrtMs; Not = ($mod.Aciklama + ' + ' + $temel.Ad) }
            if ($s.Ok -eq $s.Toplam) {
                Write-Host '   Tam sonuc alindi, kalan modlar denenmeyecek.' -ForegroundColor Green
                break
            }
        }
        ipconfig /flushdns | Out-Null
    }

    Write-Host ''
    if ($sonuclar.Count -eq 0) {
        Write-Banner 'Hicbir profil baslatilamadi' @('Antivirus GoodbyeDPI i engelliyor olabilir.') 'Red'
        Show-AvOnerisi
        Write-Host ''
        Write-Host '   DNSTEST.bat menusunden A ile sorun raporu alabilirsiniz.'
        exit 1
    }

    # Calisan = en cok adrese erisebilen profil(ler). Birden fazlaysa en hizlisi (en dusuk ortalama ms).
    # Mod profili ile DNS profili yakinsa (%20) sade olan DNS profili tercih edilir.
    $enOk = ($sonuclar | Measure-Object -Property Ok -Maximum).Maximum
    $calisanlar = @($sonuclar | Where-Object { $_.Ok -eq $enOk } | Sort-Object -Property OrtMs)
    $en = $calisanlar[0]
    if ($en.Not) {
        $dnsAday = @($calisanlar | Where-Object { -not $_.Not })
        if ($dnsAday.Count -gt 0 -and $dnsAday[0].OrtMs -le ($en.OrtMs * 1.2)) { $en = $dnsAday[0] }
    }

    # --- Sonuc tablosu ---
    Write-Step 'Sonuc' 'Siralama'
    $sirali = @($sonuclar | Sort-Object -Property @{ Expression = 'Ok'; Descending = $true }, @{ Expression = 'OrtMs'; Descending = $false })
    $enHizli = 1
    $hizli = @($sirali | Where-Object { $_.Ok -gt 0 })
    if ($hizli.Count -gt 0) { $enHizli = ($hizli | Measure-Object -Property OrtMs -Minimum).Minimum }
    Write-Host '      #  Profil           Erisim    Sure         Hiz' -ForegroundColor DarkGray
    $sira = 0
    foreach ($c in $sirali) {
        $sira++
        $isaret = ' '
        if ($c.Dosya -eq $en.Dosya) { $isaret = '*' }
        $ms = '-'
        $bar = ''
        $renk = 'Red'
        if ($c.Ok -gt 0) {
            $ms = '' + $c.OrtMs + ' ms'
            $k = [int][math]::Round(12 * $enHizli / [math]::Max($c.OrtMs, 1))
            if ($k -lt 1) { $k = 1 }
            $bar = $cBlk * $k
            if ($c.Ok -eq $c.Toplam) { $renk = 'Green' } else { $renk = 'Yellow' }
        }
        $satir = '    ' + $isaret + ' ' + ('' + $sira).PadRight(3) + $c.Ad.PadRight(17) + ('' + $c.Ok + '/' + $c.Toplam).PadRight(10) + $ms.PadRight(13) + $bar
        if ($c.Not) { $satir = $satir + '  [' + $c.Not + ']' }
        Write-Host $satir -ForegroundColor $renk
    }
    if ($calisanlar.Count -gt 1) {
        Write-Host ('   -> ' + $calisanlar.Count + ' profil calisiyor, en uygun olan secildi (*).') -ForegroundColor DarkGray
    }

    if ($en.Ok -eq 0) {
        Write-Host ''
        Write-Banner 'Hicbir profil Roblox adreslerine erisim saglayamadi' @(
            'Olasi nedenler: antivirus aga mudahale ediyor, internet kesik,',
            'internet saglayici farkli bir engel uyguluyor.'
        ) 'Red'
        Show-AvOnerisi
        Write-Host ''
        Write-Host '   DNSTEST.bat menusunden A ile sorun raporu alip GitHub Issues kismina yapistirin.'
        exit 1
    }

    if ($en.Ok -le $baz.Ok) {
        Write-Host ''
        Write-Host ('[i] Hicbir profil, GoodbyeDPI olmadan yapilan testten daha iyi sonuc vermedi (' + $baz.Ok + '/' + $baz.Toplam + ').') -ForegroundColor Yellow
        if ($baz.Ok -eq $baz.Toplam) {
            Write-Host '    Test adreslerine zaten erisiliyor. Gorsel sorunu baska bir yerden geliyor olabilir (Roblox onbellegi: menu 8).'
        }
        if (-not (Ask-Yn ('Yine de ' + $en.Ad + ' kaydedilsin mi?'))) {
            exit 1
        }
    }

    try {
        Set-Content -LiteralPath $IniFile -Value @(('profile=' + $en.Dosya), ('name=' + $en.Ad)) -Encoding ASCII -ErrorAction Stop
    } catch {
        Write-Host '[HATA] ayar.ini yazilamadi (klasor yazmaya kapali olabilir).' -ForegroundColor Red
        exit 1
    }
    $script:Kazanan = $en.Dosya

    # Secilen profilin gercek gecikmesini olc
    Write-Step 'Son kontrol' 'Secilen profilin gecikmesi (yaklasik 30 sn)'
    Stop-Gdpi
    if (Start-Profil $en.Dosya) {
        Show-Gecikme
        Stop-Gdpi
    } else {
        Write-Host '   [!!] Olculemedi (profil baslatilamadi).' -ForegroundColor Yellow
    }

    $gecen = (Get-Date) - $BaslangicZamani
    $sure = ('{0}:{1:00}' -f [int][math]::Floor($gecen.TotalMinutes), $gecen.Seconds)
    $ozet = @(
        ('Erisim: ' + $en.Ok + '/' + $en.Toplam + ' adres, ortalama ' + $en.OrtMs + ' ms     (toplam sure ' + $sure + ')'),
        'Kaydedildi. DNSTEST menusunden "Son kullanilan profil" veya',
        '"Roblox ile baslat" ile kullanabilirsiniz.'
    )
    if ($en.Not) { $ozet = @($ozet[0], ('Mod profili: ' + $en.Not)) + @($ozet[1], $ozet[2]) }
    Write-Host ''
    Write-Banner ('Sizin icin en iyi profil: ' + $en.Ad) $ozet 'Green'
    exit 0
} finally {
    # Test sirasinda biz actiysak GoodbyeDPI kapali birakilir (Ctrl+C dahil), gereksiz mod dosyalari silinir
    if ($script:BenBaslattim) { Stop-Gdpi }
    Remove-ModDosyalari
}
