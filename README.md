# 🎮 GoodbyeDPI Türkiye - Roblox Görsel Düzeltmesi

> Roblox'ta menü, simge, avatar ve kapak görselleri yüklenmiyor mu? Bu paket GoodbyeDPI Türkiye'yi Roblox için ayarlar ve **internetinizde hangi ayarın gerçekten çalıştığını kendisi bulur.**

[⬇️ Son sürümü indir](https://github.com/LiXRDev/GoodbyeDPI-Turkey-Roblox-Fix/releases/latest) · [🌐 Tanıtım sayfası](https://lixrdev.github.io/GoodbyeDPI-Turkey-Roblox-Fix/) · [🇬🇧 English](#-english)

---

## ✨ Neler var?

- **Akıllı Seçici:** Dört DNS profilini sırayla çalıştırıp Roblox sunucularına gerçekten bağlanmayı dener. Çalışanlar arasından en hızlısını seçer ve hatırlar. (Ping'e bakmaz, gerçek bağlantıya bakar.)
- **Roblox ile başlat:** GoodbyeDPI'ı açar, Roblox kapanınca kendiliğinden kapatır. Siyah pencereyle uğraşmazsınız.
- **Son profili hatırlar:** Bir kez doğru ayarı bulduktan sonra tek tuşla açarsınız.
- **Sorun raporu:** Çalışmazsa tek tuşla rapor üretir. Her bilgi için ayrı ayrı onayınız istenir, rapor yalnızca bilgisayarınızda kalır.
- **Güncelleme kontrolü:** Yeni sürüm çıkınca menüde haber verir.
- **VPN değildir:** Trafiğiniz üçüncü bir sunucuya yönlendirilmez. Sadece paketlerin DPI sistemlerine takılmasını engeller.

---

## 🚀 Hızlı başlangıç

1. [Releases](https://github.com/LiXRDev/GoodbyeDPI-Turkey-Roblox-Fix/releases/latest) sayfasından zip dosyasını indirin.
2. Zip'i **bir klasöre çıkarın**. Zip'in içinden doğrudan çalıştırmayın, dosyalar eksik açılır.
3. `DNSTEST.bat` dosyasına çift tıklayın. Yönetici izni isteyecek, onaylayın.
4. Dil seçin, ardından menüden **1 (Akıllı Seçici)** tuşuna basın. 2-3 dakika sürer.
5. Bundan sonra Roblox oynamak için menüden **2 (Roblox ile başlat)** yeterli.

> ⚠️ **Yönetici izni şarttır.** GoodbyeDPI ağ paketlerini değiştirmek için bir sürücü (WinDivert) kullanır ve bu yönetici izni olmadan çalışmaz.

---

## 📋 Menü

| Tuş | Ne yapar |
| --- | --- |
| **1** | Akıllı Seçici: en hızlı çalışan profili bulur ve kaydeder |
| **2** | Roblox ile başlat: Roblox kapanınca GoodbyeDPI de kapanır |
| **3** | Son kullanılan profili başlatır |
| **4-7** | Profili elle seçin: Google, Cloudflare, AdGuard, Quad9 |
| **8** | Roblox önbelleğini (Temp) temizler |
| **9** | Güncellemeleri kontrol eder |
| **A** | Sorun raporu oluşturur |
| **B** | Çıkış |

İsterseniz hizmet olarak da kurabilirsiniz: `service_install_roblox_dnsredir_turkey.cmd` bilgisayar açılışında arka planda çalıştırır, `service_remove.cmd` kaldırır. (Hizmet çalışırken Akıllı Seçici test yapamaz, önce kaldırın.)

---

## ❓ Sık sorulan sorular

**Çalışmıyor, ne yapmalıyım?**
1. Menüden **1** ile Akıllı Seçici'yi çalıştırın. Hangi profilin sizde işe yaradığını bulur.
2. Antivirüs engelliyor olabilir (aşağıya bakın).
3. Menüden **8** ile Roblox önbelleğini temizleyin ve Roblox'u yeniden açın.
4. Hâlâ olmuyorsa menüden **A** ile rapor alıp [Issues](https://github.com/LiXRDev/GoodbyeDPI-Turkey-Roblox-Fix/issues) bölümüne yapıştırın.

**Antivirüs ne yapıyor?**
Kaspersky ve benzeri gelişmiş antivirüsler kendi ağ taramaları nedeniyle GoodbyeDPI'ın çalışmasına engel olabilir. Görseller hâlâ yüklenmiyorsa antivirüsün ağ koruması / SSL tarama özelliğini geçici olarak kapatmayı ya da Windows Defender'a geçmeyi deneyin. Sorun raporu hangi antivirüsün aktif olduğunu gösterir.

**Her internet sağlayıcısında çalışır mı?**
Garanti edemem. Sağlayıcıya göre hangi profilin işe yaradığı değişir, Akıllı Seçici bu yüzden var. Hiçbir profil çalışmazsa rapor alıp Issues'a yazın, birlikte bakalım.

**Hangi Windows sürümleri destekleniyor?**
Windows 10 ve 11 önerilir. Akıllı Seçici, rapor ve güncelleme kontrolü PowerShell 3 ve üzerini ister, Windows 7'de çalışmayabilir. Klasik profil dosyaları (`roblox_dnsredir*.cmd`) eski sistemlerde de kullanılabilir.

**Verilerim bir yere gönderiliyor mu?**
Hayır. Araç kullanıcı verisi göndermez. Güncelleme kontrolü yalnızca GitHub'dan en son sürüm bilgisini okur, Akıllı Seçici yalnızca Roblox adreslerine bağlanmayı dener, rapor ise `rapor.txt` olarak sadece sizin bilgisayarınızda oluşur.

**Nasıl kaldırırım?**
Siyah GoodbyeDPI penceresini kapatmanız yeterli. Hizmet kurduysanız `service_remove.cmd` dosyasını çalıştırın. Klasörü silmek her şeyi kaldırır.

---

## 🔐 Güvenlik ve şeffaflık

- Yönetici izniyle çalışan bir araç olduğu için indirmeden önce doğrulamanız doğru olur. Sürüm notlarındaki **SHA256** değerini zip'inkiyle karşılaştırabilirsiniz (PowerShell: `Get-FileHash dosya.zip`).
- Tüm betikler (`.bat`, `.cmd`, `.ps1`) düz metindir, açıp okuyabilirsiniz.
- `ayar.ini` yalnızca bilinen dört profil dosyasının adını saklar, başka bir dosyayı çalıştırmaz.
- Başka bir kaynaktan indirdiğiniz kopyalara güvenmeyin, yalnızca bu deponun Releases sayfasını kullanın.

---

## 📁 Dosyalar

| Dosya | Görevi |
| --- | --- |
| `DNSTEST.bat` | Ana menü. Buradan başlayın |
| `akilli_secici.ps1` | Profilleri test edip en hızlısını bulur |
| `roblox_ile_baslat.ps1` | Roblox'la birlikte açıp kapatır |
| `sorun_raporu.ps1` | Onayınızla sorun raporu oluşturur |
| `roblox_dnsredir*.cmd` | Dört DNS profili (Quad9, Google, Cloudflare, AdGuard) |
| `service_install_roblox_dnsredir_turkey.cmd`, `service_remove.cmd` | Hizmet olarak kur / kaldır |
| `x86`, `x86_64` | GoodbyeDPI dosyaları |
| `ayar.ini` | Son kullanılan profil (kendiliğinden oluşur) |

---

## ⚖️ Yasal uyarı

> Bu yazılım ve betikler yalnızca **eğitim, araştırma ve erişim sorunlarını giderme** amacıyla açık kaynak olarak paylaşılmıştır.
>
> Kullanımından doğabilecek her türlü yasal ve teknik sorumluluk tamamen **kullanıcıya** aittir. Bu proje Roblox veya GoodbyeDPI geliştiricileriyle resmi bir bağlantıya sahip değildir.

## 🙏 Teşekkürler

- Orijinal GoodbyeDPI: [ValdikSS/GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI)
- Türkiye uyarlaması: [cagritaskn/GoodbyeDPI-Turkey](https://github.com/cagritaskn/GoodbyeDPI-Turkey) (bu proje ondan türetilmiştir, doğrudan bir bağlantımız yoktur)
- Bu deponun betikleri MIT lisansı altındadır. Dahil edilen GoodbyeDPI bileşenleri kendi lisanslarına tabidir.

---

## 🇬🇧 English

**Roblox images, avatars or menus not loading in Turkey?** This package configures [GoodbyeDPI Turkey](https://github.com/cagritaskn/GoodbyeDPI-Turkey) for Roblox and **finds the profile that actually works on your connection.** It is not a VPN: your traffic is not routed through a third-party server.

[⬇️ Download the latest release](https://github.com/LiXRDev/GoodbyeDPI-Turkey-Roblox-Fix/releases/latest)

### Quick start

1. Download the zip from [Releases](https://github.com/LiXRDev/GoodbyeDPI-Turkey-Roblox-Fix/releases/latest) and **extract it to a folder**.
2. Double-click `DNSTEST.bat` and accept the administrator prompt (required by GoodbyeDPI's WinDivert driver).
3. Choose a language, then press **1** (Smart Picker). It tests all four profiles against real Roblox servers and picks the fastest one that works.
4. From then on, press **2** (Start with Roblox): GoodbyeDPI starts and stops automatically when Roblox closes.

### Notes

- The menu and the new tools are available in English, but the Smart Picker, "Start with Roblox" and problem report screens are currently in Turkish.
- Antivirus products such as Kaspersky can block GoodbyeDPI. If images still don't load, try Windows Defender or disable network scanning of your antivirus temporarily.
- The report (`A`) asks permission for every item and stays on your computer; paste it into an [issue](https://github.com/LiXRDev/GoodbyeDPI-Turkey-Roblox-Fix/issues) if you need help.
- Windows 10/11 recommended. The new tools need PowerShell 3+.
- Provided for education, research and troubleshooting access problems. You are responsible for how you use it. Not affiliated with Roblox or the GoodbyeDPI authors.
