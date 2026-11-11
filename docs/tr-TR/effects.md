---
title: Effects
description: Animasyonları, genel Hyprland bulanıklığını ve yüzey başına şeffaflığı yapılandırın.
---

**Kontrol Merkezi → Hyprland** içerir **Animasyonlar**, **Bulanıklık** ve **Sınırlar**, bunların **Gölge** sayfası pencere gölgesini kontrol eder. Şeffaflık etkinleştirme anahtarları ilgili Görünüm sayfalarındaki her yüzey ayarlarıdır.

Yüzey anahtarları bağımsızdır. Kontrol Merkezi Konfigürasyon sayfasının kendi Şeffaflık değeri ve Bulanıklık etkinleştirme anahtarı vardır; bulanıklığı global Bulanıklık değerlerini kullanır.

Kontrol Merkezi, `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`'de özel olarak oluşturulmuş bir profil ile Foot üzerinden başlatılır. Foot 1.28 ile şeffaflık `[colors-dark] alpha`'ye ve yüzey Bulanıklık anahtarı `[colors-dark] blur`'ye yansıtılır; normal Foot yapılandırması ve ARGVUS terminali bağımsız kalır.

## Animasyonlar ve Efektler anahtarları

Her ikisi de standart /effects ayarları aracılığıyla `hyprland.lua`'ya uygulanan iki bağımsız ana anahtar vardır:- **Animasyonlar** ( `/effects` `/effects/animations`) hareket eden her şeyi kontrol eder: çalışma alanı, pencere, kaybolma, çerçeve ve katman animasyonları.
- **Effects** is a shortcut for blur (

) and the transparency of Terminal, Launcher, Widget Telemetry, Control Panel and Taskbar (`/effects/blur_global_enabled` `/effects/transparency_<surface>_enabled` ). Turning it on or off writes all of them (and the Control Center transparency too). Each surface keeps its own transparency page, so Effects reads as **on when at least one of them is on** and as off only when every one is off.

Use `argvus effects-toggle animations status|enable|disable|toggle` and `argvus effects-toggle effects status|enable|disable|toggle`. The Control Panel Appearance card shows one switch for each. Turning a master switch off keeps every fine setting of the **Animations** and **Blur** pages (speeds, curves, per-leaf switches, blur size and passes), so turning it on again restores the same look. `effects status` prints `enabled` when blur or at least one of those transparency surfaces is enabled. Turning a surface's transparency off makes the whole Waybar surface opaque: besides the background, the translucent borders of the taskbar and the Widget Telemetry become the solid color they show over the theme background. Every effect is enabled by default on a fresh install, including on virtual machinesVe low-power sessions; only an explicit setting turns one off.

## Tüm efektler bir kerede

`argvus effects-toggle` bir bileşen olmadan animasyonlar, bulanıklık ve şeffaflık üzerinde birlikte işlem yapar: `status` yalnızca üçü de etkinleştirildiğinde `enabled` yazdırır, `enable` ve `disable` üçünün tümünü değiştirir ve `toggle`, `status` `enabled` olduğunda her şeyi kapatır, aksi takdirde açar. **SUPER + F6** bu geçişi çalıştırır. Tek bir grup üzerinde işlem yapmak için adlandırın: `argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`. Kontrol Merkezi'nin **Animasyonlar** sayfası bileşen başına formu kullanır, bu nedenle **Etkinleştir** anahtarı hâlâ yalnızca animasyonları değiştirir.

## Transparency

Her yüzeyin kendi **Şeffaflık** alt menüsü vardır ve etkinleştirme düğmesi ile değeri bulunur.

**Görünüm → Başlatıcılar** sayfası, resmi Rofi tabanlı başlatıcı ve seçici akışlarını kontrol eder: ana başlatıcı, emoji seçici, hesap makinesi, pano seçici, hile sayfaları ve Rofi çıkarılabilir cihaz menüleri. Şeffaflık değeri son arka plan alfasıdır; dolayısıyla `50`, yaklaşık olarak `0.50` değerinde etkili bir arka plan opaklığı anlamına gelir; metin, simgeler ve seçilen satırlar opak kalır. İle Transparency turned off, the launcher uses the active theme's own background color, fully opaque. Its Blur switch opts the `rofi` layer into the global Blur settings.

Her değer `0%` (opak) ile `100%` (tam şeffaf) arasında değişir. `+` ve `-` değerlerini %5 adımlarla kullanın, ardından yüzey sayfasında **Uygula** seçeneğini tıklayın. Sayfayı terk etmek, uygulanmamış taslağı iptal eder.

**Etkin** ve **Değer** arasında geçiş yapmak için `↑` ve `↓`'yu kullanın. **Değer** satırında, `+` ve `-`, odağı değiştirmeden taslağı ayarlar. **Eylemler**'i açmak için `Tab` tuşuna basın, ardından **[ Uygula ]**'yı etkinleştirin; `Esc` üst yüzey sayfasına geri döner.

## Animasyonlar

**Kontrol Merkezi → Hyprland → Animasyonlar**'ı açın. Sayfada bir **Etkinleştir** anahtarı ve **Özel eğriler** ve beş kategori içeren bir **Seçenekler** listesi bulunur. Her kategori kendi animasyonlarını listeler ve her animasyonun **Stil**, **Hız**, **Eğri** ve pencere açma ve kapama için **Açılma yüzdesi** içeren kendi sayfası vardır. Hyprland'in kapatabileceği animasyonlarda ayrıca **Etkinleştir** satırı bulunur.

Bu sayfalardaki her değer, Animasyon ağacının tamamı tarafından paylaşılan bir taslağa aittir. Herhangi birinin altında **[Uygula]** seçilinceye kadar hiçbir şey yazılmaz. Sayfalar arasında hareket etmek taslağı korur; Animasyonlar sayfasından uygulanmamış bir taslakla ayrılmak onay ister. Uygula, değiştirilen değerleri tek çağrıda yazar ve Hyprland'ı yeniden yükler. Üst kısımdaki **Etkinleştir** anahtarı genel animasyon durumudur (`effects.animations`): kapalı olduğunda, kendi anahtarı ne derse desin her animasyon devre dışı bırakılır.

Kontroller: `↑/↓` satırlar arasında hareket eder; `←/→` (veya `+/-`) seçilen değeri değiştirir ve **Stil** ve **Eğri** arasında geçiş yapar; `Enter` tam bir **Hız**, **Açılma yüzdesi** veya eğri parametresi yazar (aralık dışı değerler reddedilir) ve **Stil** ve **Eğri**'yi ileri doğru döndürür.

### Kategoriler ve animasyonlar| Category | Animation | Key (`effects.animation_<key>_*`) | Style (default) | Speed | Enable |
|---|---|---|---|---|---|
| Windows | Opening of windows | `opening` | `popin`, pop-in 87% | 4.1 | — |
| Windows | Closing of windows | `closing` | `popin`, pop-in 87% | 1.49 | — |
| Windows | Moving windows | `moving` | — | 4.79 | yes |
| Workspaces | Switching workspaces | `switching` | `fade` | 1.94 | — |
| Workspaces | Workspace entrance | `workspace_in` | `fade` | 1.21 | — |
| Workspaces | Workspace exit | `workspace_out` | `fade` | 1.94 | — |
| Workspaces | Special workspaces | `special_workspace` | `slide` | 5 | — |
| Layers & popups | Layer surfaces | `layers` | — | 3.81 | yes |
| Layers & popups | Layer entrance | `layers_in` | `fade` | 4 | — |
| Layers & popups | Layer exit | `layers_out` | `fade` | 1.5 | — |
| Layers & popups | Fade | `fade` | — | 3.03 | yes |
| Layers & popups | Fade in | `fade_in` | — | 1.73 | yes |
| Layers & popups | Fade out | `fade_out` | — | 1.46 | yes |
| Borders & effects | Border color | `border` | — | 5.39 | yes |
| Borders & effects | Border gradient angle | `border_angle` | — | 5 | yes |
| Other animations | Zoom factor | `zoom` | — | 7 | yes |
| Other animations | Monitor added | `monitor_added` | — | 5 | yes |

Hyprland 0.56.2'nin stok yapılandırmasında gönderdiği yaprakların varsayılanları (Special workspaces, Border gradient angle ve Monitor added dışındaki her satır) stok hızlar, stiller ve eğrilerdir. Bu üçü ARGVUS varsayılanlarını korur, çünkü stok yapılandırma onları tanımlamaz.

Her yaprak yalnızca Hyprland 0.56.2'nin onun için kabul ettiği stilleri sunar. Pencere açma ve kapama `slide`, `popin`, `slidefade`, `slidevert`, `slidefadevert` ve `gnomed` sunar. Katman giriş ve çıkışları `slide`, `popin`, `fade`, `slidefade`, `slidevert` ve `slidefadevert` sunar. Çalışma alanı yaprakları (değiştirme, giriş, çıkış ve özel çalışma alanları) `slide`, `fade`, `slidefade`, `slidevert` ve `slidefadevert` sunar, `popin` veya `gnomed` olmadan. Yaprağının listesi dışındaki bir saklı stil göz ardı edilir ve yaprak varsayılanını kullanır. Her animasyon `default` eğrisi ile başlar. Bir sayfa yalnızca animasyonunun desteklediği satırları sunar. Saklı anahtarlar `effects.animation_<key>_speed`, `_curve`, `_style` (sunulduğu yerde), `_popin` (pencere açma ve kapama) ve `_enabled`'dir (sunulduğu yerde).

### Curves

| Curve | Behavior | Parameters (key → default) |
|---|---|---|
| `default` | Bu animasyon için Hyprland 0.56.2 eğrisi gönderilir (örneğin`easeOutQuint`, `almostLinear`, `quick`, `linear` veya `easy`bahar). Stok eğrisi olmayan animasyonlar ARGVUS'un yerleşik Bézier'ını kullanır. | Düzeltildi. |
| `bezier` | İki kontrol noktasıyla şekillendirilmiş, hızlanan ve yavaşlayan düzgün hareket. | `bezier_x1` 0.23, `bezier_y1` 1, `bezier_x2` 0.32, `bezier_y2` 1 (x 0–1, y −2–3) |
| `spring` | Kütle, sertlik ve sönümleme ile fiziksel hareket; elastik bir etki için aşım yapabilir. | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 |
| `linear` | `(0, 0)`'dan `(1, 1)`'ya kadar animasyonun tamamı için sabit hız. | Sabit. |
| `ease_out` | `(0, 0)`'dan `(0.58, 1)`'ya kadar başlangıçta hızlı ve sonunda sorunsuz. | Sabit. |**Özel eğriler** altında, her eğrinin kendi sayfası vardır. Bézier dört kontrol noktasını düzenler, Spring kütle, sertlik ve sönümlemeyi düzenler ve Linear ve Ease-out sabit noktalarını gösterir. Bézier ve Spring değerleri, o eğriyi seçen her animasyona uygulanır.

Aralıklar ve adımlar: **Hız** 1–10 arası ondalıklarla (adım 0,1, varsayılan hızlar ondalıklıdır); **Pop-in yüzdesi** 1–100 arası tam sayılarla (adım 5, varsayılan 87); Bézier noktaları yukarıdaki gibi (adım 0,05); Yay kütlesi 0,5–10 (adım 0,1), sertlik 0,5–2000 (adım 10) ve sönümleme 0,5–200 (adım 1).

Sunulmuyor: Hyprland 0.56.2, pencereleri yeniden boyutlandırma, açılır pencereler veya gölge ve parıltı gradyan açıları için ayrı bir animasyona sahip değildir, bu nedenle sayfa onlar için satır göstermemektedir.

## Blur

Blur, katılmayı seçen her yüzey tarafından paylaşılan tek bir küresel Hyprland ayarıdır. **Kontrol Merkezi → Hyprland → Blur** bölümünü açın. Sayfada bir **Etkinleştir** anahtarı ve Hyprland’in `decoration:blur` parametrelerini Hyprland’in kullandığı adlarla gösteren bir **Değerler** listesi vardır:

| Row | Config key | Default | Range | `←/→` step |
|---|---|---|---|---|
| Size | `effects.blur_size` | `6` | 1–64 | 1 |
| Passes | `effects.blur_passes` | `2` | 1–8 | 1 |
| Brightness | `effects.blur_brightness` | `1` | 0–2 | 0.05 |
| Noise | `effects.blur_noise` | `0.00` | 0–1 | 0.01 |
| Contrast | `effects.blur_contrast` | `0.900000` | 0–2 | 0.05 |
| Vibrancy | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0.01 |
| Vibrancy darkness | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0.01 |

Taşımak için `↑/↓`, seçili değeri adımıyla değiştirmek için `←/→` (veya `+/-`), ve tam bir değer girmek için `Enter` kullanın; aralık dışındaki değerler reddedilir. Düzenlerken hiçbir şey yazılmaz: anahtar ve değerler, sayfanın altındaki **[ Uygula ]** seçilene kadar taslak olarak kalır. Uygula, değiştirilen tüm değerleri tek bir seferde yazar ve ardından Hyprland’i yeniden yükler. Uygulanmamış bir taslakla sayfadan ayrılmak onay ister.

Değerler Hyprland'e olduğu gibi iletilir; ARGVUS onları bir yüzdeden türetmez. Bir yüzeyin anahtarını değiştirmek değerleri değiştirmez.

## Shadow

Pencere gölgesi, **Kontrol Merkezi → Hyprland → Kenarlıklar → Gölge** altında bulunan global bir Hyprland ayarıdır. Şeffaflık ve bulanıklıktan bağımsızdır: varsayılan olarak kapalıdır ve bir yüzeyin şeffaflığını açıp kapatmak bunu değiştirmez.

| Row | Config key | Default | Range | `←/→` step |
|---|---|---|---|---|
| Enable | `effects.shadow_enabled` | `false` | — | — |
| Sharp | `effects.shadow_sharp` | `false` | — | — |
| Color | `effects.shadow_color` | empty (follows the accent) | empty or `RRGGBBAA` | — |
| Range | `effects.shadow_range` | `6` | 0–100 | 1 |
| Render power | `effects.shadow_render_power` | `6` | 1–10 | 1 |
| Offset X | `effects.shadow_offset_x` | `0` | −100 to 100 | 1 |
| Offset Y | `effects.shadow_offset_y` | `0` | −100 to 100 | 1 |
| Scale | `effects.shadow_scale` | `1.00` | 0–1 | 0.05 |

An empty color follows the accent of the active theme with alpha `99`, so the default blue accent gives `3590bd99`. Type eight hex digits (`RRGGBBAA`) to fix the color, or leave the prompt empty to follow the accent again. The color is read when the Hyprland configurationyüklenir, bu nedenle bir tema veya aksan değişikliğinden sonra, bir sonraki yapılandırma yeniden yüklemesinde yeni aksanı alır.

Bulanıklaştırma gibi, sayfa da bir taslağı düzenler: **[ Uygula ]** seçilene kadar hiçbir şey yazılmaz ve sayfayı uygulanmamış bir taslakla bırakmak onay ister.

## Kanonik durum ve uyumluluk dosyaları
Mantıksal tercih `$XDG_CONFIG_HOME/argvus/config.json` içinde saklanır. Küresel animasyon `effects.animations` kullanır; Animations değerleri yukarıda açıklanan `effects.animation_*` anahtarlarını kullanır. Küresel Blur anahtarı `effects.blur_global_enabled` olup, Blur değerleri yukarıda listelenen `effects.blur_*` anahtarlarını kullanır. Yüzey etkinleştirme durumları ve şeffaflık değerleri `effects.blur_control-center_enabled` ve `effects.transparency_control-center_value` gibi anahtarları kullanır. Şeffaflık değerleri `0–100` ile sınırlıdır; her Blur değeri kendi aralığıyla sınırlandırılmıştır ve `argvus-config` buna dışındaki yazımları reddeder. Etkinleştirme durumları, eksik geçersiz kılmalardan ayrı kalır.

Eski `effects.blur_global_value` yüzdesi artık okunmamaktadır. Hâlâ bunu içeren bir profil, anahtarı disk üzerinde etkisiz bir şekilde tutar ve Blur, değerleri uygulanana kadar yukarıdaki varsayılanları kullanır.

```text
$XDG_CONFIG_HOME/argvus/config.json
```

`data/generated/effects/<active-theme>.conf`, yalnızca `argvus config` tarafından yazılmıştır; `argvus effects-toggle`, `argvus config effects`'ye yetki devreder. Bir tema veya mod değişikliği, mevcut temanın dışa aktarılan görsel profilini yeniden uygular; mevcutsa `effects.conf`'den yüzeye özgü değerler de dahil edilir. Profilsiz temalar paketlenmiş efekt varsayılanlarını geri yükler. Efektleri değiştirdikten sonra temayı dışa aktarın, böylece bu değerler başka bir tema veya mod değişikliğinde korunur.

Bir yüzeyin Şeffaflık veya Bulanıklık anahtarını devre dışı bırakmak yalnızca o yüzeyi etkiler; kaydedilen sayısal değerler daha sonra yeniden etkinleştirme için saklanır.

## Profiles

Tema ihracatı, kanonik görünüm/efekt ayarlarını ve aktif temanın yüzey başına efekt projeksiyonunu içerir. Tema uygulandığında oluşturulan Waybar, Quickshell ve Hyprland çalışma zamanı dosyaları yeniden oluşturulur.

Tüm yüzey sayfaları taslaklarını `[ Apply ]` düğmesi ile birlikte uygular. Kontrol Merkezi etkiler yardımcısı aracılığıyla kanonik belgeyi yazar, `argvus-config`'nin etkiler ağacını projelendirmesine izin verir, etkilenen tüketicileri yeniden yükler ve etkin değeri geri okur. Oluşturulan dosyalar yetkili durum olarak içe aktarılmak yerine yeniden oluşturulur.

## Gece Lambası

**SUPER + Shift + B** parlaklık seçiciyi korur ve etkili durum/sıcaklık ile ayrı bir Gece Işığı anahtarı ekler. `argvus config display night-light status|toggle` çağrılır. Gece Işığı, parlaklık desteğinden bağımsız olarak Hyprland ve yanıt veren Hyprsunset >= 0.4.0 gerektirir. Aralık 1000–20000 K'dir; yapılandırma Kontrol Merkezi'nde **Masaüstü ve Girdi > Ekranlar > Gece Işığı** altında bulunur. Bir anahtar, zamanlama olmadan kalıcıdır veya zamanlamayla bir sonraki geçişe kadar geçici bir geçersiz kılma sağlar. Menüden iptal etmek hiçbir şeyi değiştirmez.
