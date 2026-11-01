# GoodbyeDPI Roblox Fix - Sorun Raporu
# Her bilgi icin ayri onay ister, onaylanmayan bilgiyi toplamaz, sonucu rapor.txt dosyasina yazar.
# Arac surumu DNSTEST.bat icindeki LOCAL_VER satirindan otomatik okunur (burada surum guncellemek gerekmez).

$ErrorActionPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$Base = $PSScriptRoot
if (-not $Base) { $Base = (Get-Location).Path }
$Repo = 'LiXRDev/GoodbyeDPI-Turkey-Roblox-Fix'
$OutFile = Join-Path $Base 'rapor.txt'
$lines = New-Object System.Collections.Generic.List[string]

# Kayitli profil adlarini tanimak icin (ayar.ini sadece bu dosyalara izin verir)
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

# ------------------------------------------------------------------ SURUM

$ToolVersion = 'bilinmiyor'
$batYol = Join-Path $Base 'DNSTEST.bat'
if (Test-Path -LiteralPath $batYol) {
    $m = Select-String -LiteralPath $batYol -Pattern 'set\s+"LOCAL_VER=([0-9][0-9.]*)"' | Select-Object -First 1
    if ($m) { $ToolVersion = $m.Matches[0].Groups[1].Value }
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
$W = 72

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

# Rapora satir ekler ve ayni satiri ekranda ">" isaretiyle gosterir.
# Boylece neyin dosyaya yazildigi gorunur: ">" ile baslayan her satir rapor.txt icindedir.
function Add-Line([string]$t, [string]$renk = 'Gray') {
    $lines.Add($t)
    Write-Host '  > ' -NoNewline -ForegroundColor DarkGray
    Write-Host $t -ForegroundColor $renk
}

# Tek tusla E / H / T secimi. Enter = Hayir. Tus okunamazsa (ISE, yonlendirme) Read-Host'a duser.
function Read-Secim {
    try {
        while ($true) {
            $k = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            if ($k.VirtualKeyCode -eq 13) { return 'H' }
            $c = [string]$k.Character
            if ($c -match '^[EeYy]$') { return 'E' }
            if ($c -match '^[HhNn]$') { return 'H' }
            if ($c -match '^[Tt]$') { return 'T' }
        }
    } catch {
        $a = Read-Host ' (E = Evet, H = Hayir, T = kalanlarin hepsi Evet)'
        if ($a -match '^\s*[EeYy]') { return 'E' }
        if ($a -match '^\s*[Tt]') { return 'T' }
        return 'H'
    }
}

$script:HepsiEvet = $false

# Her otomatik bilgi icin onay ister. Enter veya H = Hayir.
function Ask-Consent([string]$no, [string]$ad, [string]$ne) {
    Write-Step $no $ad
    Write-Host '   Paylasilacak bilgi: ' -NoNewline -ForegroundColor DarkGray
    Write-Host $ne
    if ($script:HepsiEvet) {
        Write-Host '   Onaylandi (toplu onay).' -ForegroundColor DarkGreen
        return $true
    }
    Write-Host '   Rapora eklensin mi?  ' -NoNewline
    Write-Host '[E]' -NoNewline -ForegroundColor Green
    Write-Host ' Evet   ' -NoNewline
    Write-Host '[H]' -NoNewline -ForegroundColor Red
    Write-Host ' Hayir (Enter)   ' -NoNewline
    Write-Host '[T]' -NoNewline -ForegroundColor Yellow
    Write-Host ' Kalanlarin hepsi Evet : ' -NoNewline
    $s = Read-Secim
    if ($s -eq 'T') { $script:HepsiEvet = $true; $s = 'E' }
    if ($s -eq 'E') {
        Write-Host 'Evet' -ForegroundColor Green
        return $true
    }
    Write-Host 'Hayir' -ForegroundColor Yellow
    return $false
}

# Onaylanmayan bolumun verisi toplanmaz, rapora sadece "paylasilmadi" notu dusulur
function Skip-Section([string]$baslik) {
    $lines.Add('--- ' + $baslik + ' ---')
    $lines.Add('Kullanici paylasmak istemedi.')
    $lines.Add('')
    Write-Host '   Atlandi. Bu bilgi toplanmadi ve rapora eklenmeyecek.' -ForegroundColor Yellow
}

# Kullanicinin yazdigi metni temizler: kontrol karakterlerini atar, uzunlugu sinirlar
function Clean-Input([string]$s, [int]$max = 120) {
    if (-not $s) { return '(belirtilmedi)' }
    $s = ($s -replace '[\x00-\x1F\x7F]', ' ').Trim()
    if ($s.Length -gt $max) { $s = $s.Substring(0, $max) }
    if (-not $s) { return '(belirtilmedi)' }
    return $s
}

function Copy-Clip([string]$text) {
    try { Set-Clipboard -Value $text -ErrorAction Stop; return $true } catch {}
    try { $text | clip.exe; return $true } catch {}
    return $false
}

# ------------------------------------------------------------------ BAGLANTI TESTI

# WebException durumunu kisa Turkce aciklamaya cevirir: @(tur, aciklama)
function Get-HataTuru($ex) {
    $d = ''
    if ($ex -and $ex.Status) { $d = [string]$ex.Status }
    switch ($d) {
        'Timeout'               { return @('timeout', 'Zaman asimi') }
        'NameResolutionFailure' { return @('dns', 'DNS cozulemedi') }
        'ConnectFailure'        { return @('baglanti', 'Baglanti kurulamadi') }
        { @('ConnectionClosed', 'ReceiveFailure', 'SendFailure', 'KeepAliveFailure', 'PipelineFailure') -contains $_ } {
            return @('reset', 'Baglanti kesildi/sifirlandi (DPI engeli belirtisi)')
        }
        { @('SecureChannelFailure', 'TrustFailure') -contains $_ } {
            return @('tls', 'TLS/sertifika hatasi (antivirus SSL taramasi olabilir)')
        }
    }
    if ($d) { return @('diger', ('Hata: ' + $d)) }
    return @('diger', 'Bilinmeyen hata')
}

# Tum adresleri AYNI ANDA test eder: once DNS (en fazla 5 sn), sonra HTTPS (en fazla 8 sn).
# Herhangi bir HTTP yaniti = erisim var. Eskisine gore ~1 dakika yerine ~15 saniyede biter.
function Test-Roblox([string[]]$hostlar) {
    $sonuc = @()

    $dnsIs = @()
    foreach ($h in $hostlar) {
        $a = $null
        try { $a = [System.Net.Dns]::BeginGetHostAddresses($h, $null, $null) } catch {}
        $dnsIs += [pscustomobject]@{ Host = $h; Async = $a; Ok = $false; Bitti = $false }
    }
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt 5000) {
        $hepsi = $true
        foreach ($i in $dnsIs) {
            if ($i.Async -and -not $i.Async.IsCompleted) { $hepsi = $false }
        }
        if ($hepsi) { break }
        Start-Sleep -Milliseconds 40
    }
    foreach ($i in $dnsIs) {
        if ($i.Async -and $i.Async.IsCompleted) {
            $i.Bitti = $true
            try {
                $adr = [System.Net.Dns]::EndGetHostAddresses($i.Async)
                if ($adr.Count -gt 0) { $i.Ok = $true }
            } catch {}
        }
    }

    $isler = @()
    foreach ($i in $dnsIs) {
        if (-not $i.Ok) {
            $acik = 'DNS cozulemedi'
            if (-not $i.Bitti) { $acik = 'DNS zaman asimi' }
            $sonuc += [pscustomobject]@{ Host = $i.Host; Ok = $false; Tur = 'dns'; Aciklama = $acik }
            continue
        }
        try {
            $r = [System.Net.HttpWebRequest]::Create('https://' + $i.Host + '/')
            $r.Method = 'HEAD'
            $r.AllowAutoRedirect = $false
            $r.Proxy = $null
            $r.UserAgent = 'GoodbyeDPI-Roblox-Fix-Rapor'
            $isler += [pscustomobject]@{ Host = $i.Host; Req = $r; Async = $r.BeginGetResponse($null, $null); Done = $false; Ms = 0 }
        } catch {
            $sonuc += [pscustomobject]@{ Host = $i.Host; Ok = $false; Tur = 'diger'; Aciklama = 'Istek baslatilamadi' }
        }
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt 8000) {
        $hepsi = $true
        foreach ($i in $isler) {
            if (-not $i.Done) {
                if ($i.Async.IsCompleted) {
                    $i.Done = $true
                    $i.Ms = [int]$sw.ElapsedMilliseconds
                } else { $hepsi = $false }
            }
        }
        if ($hepsi) { break }
        Start-Sleep -Milliseconds 40
    }

    foreach ($i in $isler) {
        if ($i.Done) {
            try {
                $resp = $i.Req.EndGetResponse($i.Async)
                $kod = [int]$resp.StatusCode
                $resp.Close()
                $sonuc += [pscustomobject]@{ Host = $i.Host; Ok = $true; Tur = 'ok'; Aciklama = ('HTTP ' + $kod + ', ' + $i.Ms + ' ms') }
            } catch {
                $ex = $_.Exception
                if ($ex.InnerException) { $ex = $ex.InnerException }
                if ($ex.Response) {
                    $kod = [int]$ex.Response.StatusCode
                    $ex.Response.Close()
                    $sonuc += [pscustomobject]@{ Host = $i.Host; Ok = $true; Tur = 'ok'; Aciklama = ('HTTP ' + $kod + ', ' + $i.Ms + ' ms') }
                } else {
                    $t = Get-HataTuru $ex
                    $sonuc += [pscustomobject]@{ Host = $i.Host; Ok = $false; Tur = $t[0]; Aciklama = $t[1] }
                }
            }
        } else {
            $i.Req.Abort()
            $sonuc += [pscustomobject]@{ Host = $i.Host; Ok = $false; Tur = 'timeout'; Aciklama = 'Zaman asimi (8 sn)' }
        }
    }
    return $sonuc
}

# ------------------------------------------------------------------ ANA AKIS

Clear-Host
Write-Banner 'GoodbyeDPI Roblox Fix  -  Sorun Raporu' @(
    ('Surum ' + $ToolVersion + '   |   Rapor sadece bu bilgisayarda kalir'),
    'Her bilgi icin ayri onay istenir. Onaylamadiginiz bilgi toplanmaz.',
    'IP adresiniz, kullanici ve bilgisayar adiniz rapora yazilmaz.',
    'Basinda ">" olan satirlar rapor.txt dosyasina aynen yazilir.'
) 'DarkCyan'

Write-Host ''
Write-Host 'Once sizin yazacaginiz bilgiler (istemediginizi bos birakip Enter ile gecin):' -ForegroundColor Cyan
$isp = Clean-Input (Read-Host '  Internet saglayiciniz (orn. Turk Telekom, Turkcell Superonline, Vodafone)')
$cmdUsed = Clean-Input (Read-Host '  Hangi profili/dosyayi denediniz (orn. Google DNS, roblox_dnsredir.cmd)')
$problem = Clean-Input (Read-Host '  Sorunu kisaca yazin (orn. avatarlar yuklenmiyor)')

Write-Step '*' 'Rapor basligi (her zaman eklenir)'
Add-Line '=== GoodbyeDPI Roblox Fix - Sorun Raporu ===' 'White'
Add-Line ('Tarih: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm'))
Add-Line ('Arac surumu: ' + $ToolVersion)
Add-Line ('Internet saglayici: ' + $isp)
Add-Line ('Denenen profil/dosya: ' + $cmdUsed)
Add-Line ('Sorun: ' + $problem)
$lines.Add('')

$gdpiCalisiyor = $null

# --- 1) Windows ve sistem ---
if (Ask-Consent '1/6' 'Windows ve sistem' 'Windows adi, surumu, 32/64 bit, PowerShell surumu, yonetici izni var mi (orn. Windows 11 Pro 10.0.22631, 64-bit)') {
    $lines.Add('--- Sistem ---')
    $os = Get-CimInstance Win32_OperatingSystem
    if ($os) {
        Add-Line ('Windows: ' + $os.Caption + ' ' + $os.Version + ' (' + $os.OSArchitecture + ')')
    } else { Add-Line 'Windows: bilgi alinamadi' 'Yellow' }
    Add-Line ('PowerShell: ' + $PSVersionTable.PSVersion.ToString())
    $yonetici = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($yonetici) { Add-Line 'Yonetici izni: var' } else { Add-Line 'Yonetici izni: YOK (GoodbyeDPI yonetici izni olmadan calismaz)' 'Yellow' }
    $lines.Add('')
} else { Skip-Section 'Sistem' }

# --- 2) Antivirus ---
if (Ask-Consent '2/6' 'Antivirus' 'Yuklu antivirus urunlerinin adi ve su an acik mi kapali mi oldugu') {
    $lines.Add('--- Antivirus ---')
    $av = @(Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntiVirusProduct)
    if ($av.Count -gt 0) {
        $kapaliVar = $false
        foreach ($p in $av) {
            # productState bitleri: 0x1000 = koruma acik, 0x10 = imzalar eski
            $state = [int]$p.productState
            $acik = (($state -band 0x1000) -ne 0)
            $imzaEski = (($state -band 0x10) -ne 0)
            # Program dosyasi diskte yoksa Windows'taki kayit eski bir kalintidir, "acik" gorunse bile kullanilmiyordur
            $yol = [Environment]::ExpandEnvironmentVariables([string]$p.pathToSignedProductExe)
            $dosyaYok = (($yol -match '^[A-Za-z]:\\') -and (-not (Test-Path -LiteralPath $yol)))
            $renk = 'Gray'
            if ($dosyaYok) {
                $kapaliVar = $true
                $durum = 'KALINTI - program dosyasi bulunamadi, kaldirilmis olabilir, kullanilmiyor'
            } elseif ($acik) {
                $renk = 'Green'
                $durum = 'AKTIF - su an kullanilan'
                if ($imzaEski) { $durum = $durum + ', imzalar eski olabilir' } else { $durum = $durum + ', imzalar guncel' }
            } else {
                $kapaliVar = $true
                $durum = 'KAPALI - kullanilmiyor'
            }
            Add-Line ($p.displayName + ' : ' + $durum + ' [kod: ' + $state + ']') $renk
        }
        if ($kapaliVar) {
            Add-Line 'Not: KALINTI veya KAPALI gorunen urunler eskiden kaldirilmis programlarin kalintisi olabilir.' 'DarkGray'
        }
    } else { Add-Line 'Bilgi alinamadi (kayitli antivirus yok ya da Windows Guvenlik Merkezi okunamadi)' 'Yellow' }
    $lines.Add('')
} else { Skip-Section 'Antivirus' }

# --- 3) DNS ---
if (Ask-Consent '3/6' 'DNS ayarlari' 'Ag baglantilarinizda ayarli DNS sunucu adresleri (orn. 8.8.8.8 veya modem adresi 192.168.1.1)') {
    $lines.Add('--- DNS Ayarlari ---')
    $dns = @(Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses })
    if ($dns.Count -gt 0) {
        foreach ($d in $dns) { Add-Line ($d.InterfaceAlias + ': ' + ($d.ServerAddresses -join ', ')) }
    } else { Add-Line 'Bilgi alinamadi' 'Yellow' }
    $lines.Add('')
} else { Skip-Section 'DNS Ayarlari' }

# --- 4) GoodbyeDPI durumu ---
if (Ask-Consent '4/6' 'GoodbyeDPI durumu' 'GoodbyeDPI su an calisiyor mu ve servis olarak kurulu mu') {
    $lines.Add('--- GoodbyeDPI Durumu ---')
    $proc = @(Get-Process | Where-Object { $_.ProcessName -like '*goodbyedpi*' })
    if ($proc.Count -gt 0) {
        $gdpiCalisiyor = $true
        Add-Line 'Process: CALISIYOR' 'Green'
    } else {
        $gdpiCalisiyor = $false
        Add-Line 'Process: calismiyor'
    }
    $svc = @(Get-Service | Where-Object { $_.Name -like '*goodbye*' -or $_.DisplayName -like '*goodbye*' })
    if ($svc.Count -gt 0) {
        foreach ($s in $svc) { Add-Line ('Servis: ' + $s.Name + ' - ' + $s.Status) }
        if ($proc.Count -eq 0 -and ($svc | Where-Object { $_.Status -eq 'Running' })) { $gdpiCalisiyor = $true }
    } else { Add-Line 'Servis: kurulu degil' }
    $lines.Add('')
} else { Skip-Section 'GoodbyeDPI Durumu' }

# --- 5) Roblox baglanti testleri ---
if (Ask-Consent '5/6' 'Roblox baglanti testleri' 'Roblox sunucularina (roblox.com ve rbxcdn.com) erisilip erisilemedigi, yaklasik 15 saniye surer') {
    $lines.Add('--- Roblox Baglanti Testleri ---')
    $hosts = @('www.roblox.com', 'apis.roblox.com', 'thumbnails.roblox.com', 'assetdelivery.roblox.com', 't0.rbxcdn.com', 'css.rbxcdn.com')
    Write-Host '   Adresler ayni anda test ediliyor, lutfen bekleyin...' -ForegroundColor DarkGray
    $res = @(Test-Roblox $hosts)
    foreach ($h in $hosts) {
        $x = $res | Where-Object { $_.Host -eq $h } | Select-Object -First 1
        if (-not $x) { continue }
        if ($x.Ok) { Add-Line ('[ OK ] ' + $h.PadRight(26) + $x.Aciklama) 'Green' }
        else { Add-Line ('[HATA] ' + $h.PadRight(26) + $x.Aciklama) 'Red' }
    }
    $okSay = @($res | Where-Object { $_.Ok }).Count
    $nDns = @($res | Where-Object { $_.Tur -eq 'dns' }).Count
    $nTls = @($res | Where-Object { $_.Tur -eq 'tls' }).Count
    $nKes = @($res | Where-Object { $_.Tur -eq 'reset' -or $_.Tur -eq 'timeout' -or $_.Tur -eq 'baglanti' }).Count
    $renkOzet = 'Red'
    if ($okSay -eq $hosts.Count) { $renkOzet = 'Green' } elseif ($okSay -gt 0) { $renkOzet = 'Yellow' }
    Add-Line ('Ozet: ' + $okSay + '/' + $hosts.Count + ' adrese erisildi') $renkOzet

    # Otomatik teshis: sonuclara bakip en olasi nedeni yazar
    if ($okSay -eq $hosts.Count) {
        Add-Line 'Teshis: Tum adreslere erisiliyor, baglanti tarafinda sorun gorunmuyor.' 'Green'
        Add-Line 'Gorseller hala yuklenmiyorsa Roblox onbellegini temizleyin (DNSTEST menu 8).' 'DarkGray'
    } elseif ($nDns -eq $hosts.Count) {
        Add-Line 'Teshis: Hicbir adresin DNS kaydi cozulemiyor. Internet baglantinizi ve DNS ayarlarini kontrol edin.' 'Yellow'
    } else {
        if ($nDns -gt 0) { Add-Line 'Teshis: Bazi adresler icin DNS cozulemiyor. DNS sunucusunu degistirmeyi deneyin.' 'Yellow' }
        if ($nTls -gt 0) { Add-Line 'Teshis: TLS/sertifika hatasi var. Antivirusun SSL/HTTPS taramasini gecici kapatmayi deneyin.' 'Yellow' }
        if ($nKes -gt 0) {
            if ($gdpiCalisiyor -eq $true) {
                Add-Line 'Teshis: GoodbyeDPI calisirken de baglanti kesiliyor. Akilli Secici (menu 1) ile baska profil/mod deneyin.' 'Yellow'
            } elseif ($gdpiCalisiyor -eq $false) {
                Add-Line 'Teshis: Baglanti kesiliyor ve GoodbyeDPI calismiyor. Internet saglayici engeli olasi, Akilli Secici (menu 1) ile baslayin.' 'Yellow'
            } else {
                Add-Line 'Teshis: Baglanti kesiliyor/zaman asiyor. Internet saglayici engeli belirtisi, GoodbyeDPI ile deneyin.' 'Yellow'
            }
        }
    }
    $lines.Add('')
} else { Skip-Section 'Roblox Baglanti Testleri' }

# --- 6) Arac dosyalari ---
if (Ask-Consent '6/6' 'Arac dosyalari' 'Gerekli dosyalarin klasorde olup olmadigi, zip icinden calistirilip calistirilmadigi, kayitli profil (klasor yolu yazilmaz)') {
    $lines.Add('--- Arac Dosyalari ---')
    $beklenen = @('DNSTEST.bat', 'akilli_secici.ps1', 'roblox_ile_baslat.ps1', 'sorun_raporu.ps1',
                  'roblox_dnsredir.cmd', 'roblox_dnsredir_alternative.cmd', 'roblox_dnsredir_alternative2.cmd', 'roblox_dnsredir_alternative_adguard.cmd')
    $eksik = @($beklenen | Where-Object { -not (Test-Path -LiteralPath (Join-Path $Base $_)) })
    if ($eksik.Count -eq 0) { Add-Line 'Dosyalar: tamam' 'Green' } else { Add-Line ('Eksik dosyalar: ' + ($eksik -join ', ')) 'Red' }

    $mim = 'x86'
    if ([Environment]::Is64BitOperatingSystem) { $mim = 'x86_64' }
    if (Test-Path -LiteralPath (Join-Path $Base ($mim + '\goodbyedpi.exe'))) {
        Add-Line ('GoodbyeDPI dosyasi (' + $mim + '): var') 'Green'
    } else { Add-Line ('GoodbyeDPI dosyasi (' + $mim + '): YOK') 'Red' }

    if ($Base -match '\.zip\\|\\7zO|\\Rar\$|Temp1_') {
        Add-Line 'Zip icinden calistirma: EVET (dosyalar eksik acilir, once klasore cikarin)' 'Red'
    } else { Add-Line 'Zip icinden calistirma: hayir' }

    $kayitli = 'yok'
    $ini = Join-Path $Base 'ayar.ini'
    if (Test-Path -LiteralPath $ini) {
        foreach ($satir in (Get-Content -LiteralPath $ini)) {
            if ($satir -match '^\s*profile\s*=\s*(.+?)\s*$') {
                $d = $Matches[1]
                if ($Gecerli.ContainsKey($d)) { $kayitli = $Gecerli[$d] } else { $kayitli = 'taninmayan deger' }
            }
        }
    }
    Add-Line ('Kayitli profil: ' + $kayitli)
    $lines.Add('')
} else { Skip-Section 'Arac Dosyalari' }

# ------------------------------------------------------------------ KAYDET

$yazildi = $false
$hedefler = @($OutFile, (Join-Path $env:TEMP 'rapor.txt'))
foreach ($h in $hedefler) {
    try {
        [IO.File]::WriteAllLines($h, $lines.ToArray(), (New-Object System.Text.UTF8Encoding($true)))
        $OutFile = $h
        $yazildi = $true
        break
    } catch {}
}

Write-Host ''
if ($yazildi) {
    Write-Banner 'Rapor hazir' @(
        'Dosya: rapor.txt',
        '">" ile baslayan satirlarin hepsi dosyaya yazildi. Istemediginiz satiri',
        'silip paylasabilirsiniz.'
    ) 'Green'
    if ($OutFile -ne (Join-Path $Base 'rapor.txt')) {
        Write-Host ('   Not: Klasore yazilamadi, rapor gecici klasore kaydedildi: ' + $OutFile) -ForegroundColor Yellow
    }
} else {
    Write-Banner 'Rapor dosyaya yazilamadi' @('Klasor yazmaya kapali olabilir. Raporu panoya kopyalamayi deneyin.') 'Red'
}

Write-Host ''
Write-Host '   Raporu panoya kopyalayayim mi?  ' -NoNewline
Write-Host '[E]' -NoNewline -ForegroundColor Green
Write-Host ' Evet   ' -NoNewline
Write-Host '[H]' -NoNewline -ForegroundColor Red
Write-Host ' Hayir (Enter) : ' -NoNewline
$s = Read-Secim
if ($s -eq 'E' -or $s -eq 'T') {
    if (Copy-Clip ($lines.ToArray() -join "`r`n")) {
        Write-Host 'Evet' -ForegroundColor Green
        Write-Host '   Panoya kopyalandi. Yapistirmak icin Ctrl+V.' -ForegroundColor Green
    } else {
        Write-Host 'Evet' -ForegroundColor Green
        Write-Host '   Kopyalanamadi. rapor.txt dosyasindan elle kopyalayin.' -ForegroundColor Yellow
    }
} else { Write-Host 'Hayir' -ForegroundColor Yellow }

Write-Host ''
Write-Host ('   Sorunu bildirmek icin: https://github.com/' + $Repo + '/issues') -ForegroundColor Cyan
Write-Host '   (Raporu yapistirmadan once icinden istemediginiz satirlari silebilirsiniz.)' -ForegroundColor DarkGray
if ($yazildi) { Start-Process notepad.exe $OutFile }
exit 0
