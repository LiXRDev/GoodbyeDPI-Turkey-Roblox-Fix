$ErrorActionPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# ---- HER YENI SURUMDE SADECE BU SATIRI GUNCELLE ----
$ToolVersion = '1.2.0'
# ----------------------------------------------------

$OutFile = Join-Path $PSScriptRoot 'rapor.txt'
$lines = New-Object System.Collections.Generic.List[string]

# Rapora satir ekler ve ayni satiri ekranda da gosterir (ne paylasildigini gorebilesiniz)
function Add-Line($t) {
    $lines.Add([string]$t)
    Write-Host ([string]$t)
}

# Her otomatik bilgi icin tek tek onay ister. Bos birakirsaniz HAYIR sayilir.
function Ask-Consent([string]$title, [string]$what) {
    Write-Host ''
    Write-Host ('>> ' + $title) -ForegroundColor Cyan
    Write-Host ('   Paylasilacak bilgi: ' + $what)
    $a = Read-Host '   Bu bilgiyi rapora eklemeyi onayliyor musunuz? (E = Evet, H = Hayir, bos birakirsaniz Hayir)'
    return ($a -match '^\s*[EeYy]')
}

# Onaylanmayan bolumun verisi toplanmaz, rapora sadece "paylasilmadi" notu dusulur
function Skip-Section([string]$title) {
    $lines.Add('--- ' + $title + ' ---')
    $lines.Add('Kullanici paylasmak istemedi.')
    $lines.Add('')
    Write-Host '   Atlandi. Bu bilgi toplanmadi ve rapora eklenmeyecek.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host '=== GoodbyeDPI Roblox Fix - Sorun Raporu ===' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Bu arac bilgisayarinizdan bazi bilgileri toplayip rapor.txt dosyasina yazar.'
Write-Host 'Her bilgi icin AYRI AYRI onayiniz istenecek. Onaylamadiginiz bilgi toplanmaz,'
Write-Host 'diger bilgilerle devam edilir. Rapor sizin genel IP adresinizi, kullanici adinizi'
Write-Host 'veya bilgisayar adinizi icermez. Rapor sadece bu bilgisayarda kaydedilir,'
Write-Host 'paylasip paylasmamak size aittir. Tarih ve arac surumu rapora her zaman eklenir.'
Write-Host ''
Write-Host 'Once sizin yazacaginiz bilgiler (hepsi istege bagli, bos birakabilirsiniz):' -ForegroundColor Cyan

$isp = Read-Host 'Internet saglayiciniz (orn. Turk Telekom, Turkcell Superonline, Vodafone)'
$cmdUsed = Read-Host 'Hangi .cmd/.bat dosyasini denediniz?'
$problem = Read-Host 'Sorunu kisaca yazin (orn. avatarlar yuklenmiyor)'

Write-Host ''
Write-Host '--- Rapor icerigi (ekranda gorunen her satir rapora yazilir) ---' -ForegroundColor Green
Add-Line '=== GoodbyeDPI Roblox Fix - Sorun Raporu ==='
Add-Line ('Tarih: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm'))
Add-Line ('Arac surumu: ' + $ToolVersion)
Add-Line ('Internet saglayici: ' + $isp)
Add-Line ('Denenen dosya: ' + $cmdUsed)
Add-Line ('Sorun: ' + $problem)
Add-Line ''

# --- 1) Windows surumu ---
if (Ask-Consent '1/5 Windows surumu' 'Windows adi, surum numarasi ve 32/64 bit bilgisi (orn. Windows 11 Pro 10.0.22631, 64-bit)') {
    Add-Line '--- Sistem ---'
    $os = Get-CimInstance Win32_OperatingSystem
    if ($os) {
        Add-Line ('Windows: ' + $os.Caption + ' ' + $os.Version + ' (' + $os.OSArchitecture + ')')
    } else { Add-Line 'Bilgi alinamadi' }
    Add-Line ''
} else { Skip-Section 'Sistem' }

# --- 2) Antivirus ---
if (Ask-Consent '2/5 Antivirus' 'Yuklu antivirus urunlerinin adi ve su an acik mi kapali mi oldugu') {
    Add-Line '--- Antivirus ---'
    $av = Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntiVirusProduct
    if ($av) {
        $eskiGibi = $false
        foreach ($p in $av) {
            $hex = ([Convert]::ToString([int]$p.productState, 16)).PadLeft(6, '0')
            $st = $hex.Substring(2, 2)
            $sig = $hex.Substring(4, 2)
            switch ($st) {
                '10' { $durum = 'AKTIF - su an kullanilan' }
                '11' { $durum = 'Beklemede (pasif)'; $eskiGibi = $true }
                '01' { $durum = 'Suresi dolmus'; $eskiGibi = $true }
                default { $durum = 'KAPALI - kullanilmiyor'; $eskiGibi = $true }
            }
            if ($st -eq '10') {
                if ($sig -eq '00') { $durum = $durum + ', imzalar guncel' } else { $durum = $durum + ', imzalar eski olabilir' }
            }
            Add-Line ($p.displayName + ' : ' + $durum)
        }
        if ($eskiGibi) {
            Add-Line 'Not: KAPALI veya Beklemede gorunen urunler eskiden kaldirilmis programlarin kalintisi olabilir.'
        }
    } else { Add-Line 'Bilgi alinamadi' }
    Add-Line ''
} else { Skip-Section 'Antivirus' }

# --- 3) DNS ---
if (Ask-Consent '3/5 DNS ayarlari' 'Ag baglantilarinizda ayarli DNS sunucu adresleri (orn. 8.8.8.8 veya modem adresi 192.168.1.1)') {
    Add-Line '--- DNS Ayarlari ---'
    $dns = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses }
    if ($dns) {
        foreach ($d in $dns) { Add-Line ($d.InterfaceAlias + ': ' + ($d.ServerAddresses -join ', ')) }
    } else { Add-Line 'Bilgi alinamadi' }
    Add-Line ''
} else { Skip-Section 'DNS Ayarlari' }

# --- 4) GoodbyeDPI durumu ---
if (Ask-Consent '4/5 GoodbyeDPI durumu' 'GoodbyeDPI su an calisiyor mu ve servis olarak kurulu mu') {
    Add-Line '--- GoodbyeDPI Durumu ---'
    $proc = Get-Process | Where-Object { $_.ProcessName -like '*goodbyedpi*' }
    if ($proc) { Add-Line 'Process: CALISIYOR' } else { Add-Line 'Process: calismiyor' }
    $svc = Get-Service | Where-Object { $_.Name -like '*goodbye*' -or $_.DisplayName -like '*goodbye*' }
    if ($svc) {
        foreach ($s in $svc) { Add-Line ('Servis: ' + $s.Name + ' - ' + $s.Status) }
    } else { Add-Line 'Servis: kurulu degil' }
    Add-Line ''
} else { Skip-Section 'GoodbyeDPI Durumu' }

# --- 5) Roblox baglanti testleri ---
if (Ask-Consent '5/5 Roblox baglanti testleri' 'Roblox sunucularina (roblox.com ve rbxcdn.com alan adlari) erisilip erisilemedigi, 1 dakika kadar surebilir') {
    Add-Line '--- Roblox Baglanti Testleri ---'
    $hosts = @(
        'www.roblox.com',
        'apis.roblox.com',
        'thumbnails.roblox.com',
        'assetdelivery.roblox.com',
        't0.rbxcdn.com',
        'css.rbxcdn.com'
    )
    foreach ($h in $hosts) {
        $dnsRes = 'DNS cozulemedi'
        $r = Resolve-DnsName $h -Type A -DnsOnly | Where-Object { $_.IPAddress } | Select-Object -First 1
        if ($r) { $dnsRes = 'DNS ok' }

        $http = ''
        try {
            $resp = Invoke-WebRequest -Uri ('https://' + $h) -Method Head -TimeoutSec 8 -UseBasicParsing
            $http = 'OK (' + $resp.StatusCode + ')'
        } catch {
            if ($_.Exception.Response) {
                $http = 'OK (HTTP ' + [int]$_.Exception.Response.StatusCode + ')'
            } else {
                $http = 'HATA: ' + $_.Exception.Message
            }
        }
        Add-Line ($h + ' | ' + $dnsRes + ' | ' + $http)
    }
    Add-Line ''
} else { Skip-Section 'Roblox Baglanti Testleri' }

$lines | Set-Content -Path $OutFile -Encoding UTF8

Write-Host ''
Write-Host ('Rapor hazir: ' + $OutFile) -ForegroundColor Green
Write-Host 'Yukaridaki satirlarin hepsi rapor.txt dosyasina yazildi. Istediginiz satiri silip paylasabilirsiniz.'
Write-Host 'Dosyanin icerigini kopyalayip GitHub Issues kismina yapistirabilirsiniz.'
Start-Process notepad.exe $OutFile