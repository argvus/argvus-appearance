---
title: Yazı tipleri ve simgeler
description: ARGVUS tarafından kullanılan yazı tiplerini ve simge temalarını yapılandırın.
---

`argvus-fonts`, birlikte gelen yazı tiplerini `/usr/share/fonts/` altında kurar; `argvus-icons` ARGVUS simge temalarını kurar. `argvus-appearance` ve Kontrol Merkezi bu varlıkları masaüstü temasıyla bağlar.

## Birincil yazı tipi

ARGVUS varsayılan birincil yazı tipi **IBM Plex Mono** olup, `Regular` stilindedir. Bu, Kontrol Merkezi'nde sunulan yazı tipi hedefleri tarafından kullanılan varsayılan ailedir. Paketlenmiş `argvus-fonts` paketi, IBM Plex Mono yazı tipini ve masaüstü tarafından kullanılan destekleyici simge/terminal ailelerini sağlar.

Aç **Kontrol Merkezi → Yazı Tipleri** ile bireysel hedefleri yapılandırabilirsiniz:

- görev çubuğu;
- telemetri/sistem bilgisi;
- Kontrol Paneli;
- ARGVUS sistem arayüzü;
- uygulamalar;
- terminal;
- tarayıcı.

Varsayılan boyutlar hedefe özeldir: görev çubuğu, sistem ve terminal `13` kullanır; telemetri ve Denetim Masası `14` kullanır; uygulamalar `12` kullanır; ve tarayıcı `10` kullanır. Bu varsayılanlar Yazı Tipleri sayfasından geri yüklenebilir.

## Simge teması

Etkin simge teması, config.json içinde `appearance.icon_theme` olarak kanonik şekilde saklanır. Boş bir değer (varsayılan), aktif temanın modunun ARGVUS simge temasını seçer: koyu temalar için  `config.json` `Argvus Dark Icons` ve açık temalar için `Argvus Light Icons`, her ikisi de `argvus-icons` tarafından kurulmuştur.

`sh/icon-switch.sh`, geçerli temayı çözer ve bunu her tüketiciye uygular:

- GNOME ayarları: `org.gnome.desktop.interface icon-theme`;
- GTK 3 ve GTK 4: `gtk-icon-theme-name` ARGVUS ve yerel `settings.ini` dosyalarında;
- Qt: `icon_theme` yönetilen `qt6ct.conf` içinde ve ARGVUS tarafından oluşturulduğunda yerel `qt6ct.conf` içinde.

Temalar `/usr/share/icons`, `$XDG_DATA_HOME/icons` ve `~/.icons` içinde aranır. Yüklü olmayan yapılandırılmış bir tema veya `/` içeren ya da `..` olan bir değer, aynı modun varsayılanına geri döner ve bir mesaj kaydeder, böylece masaüstü hiçbir zaman eksik bir temayı göstermez. Bir tema veya mod değişikliği, mevcutsa dışa aktarılan tema profilinin simge seçimini kullanır, aksi takdirde paketlenmiş mod varsayılanını geri yükler. Özelleştirilmiş simge seçimini değişiklikler arasında korumak için temayı dışa aktarın.

Kontrol Merkezi'ndeki yazı tipi kontrollerini kullanın. Yazı tipi tercihleri `config.json` içinde kanoniktir, aile, stil ve boyut için `fonts.targets.<target>`'de artı olarak anti-aliasing, ipucu verme, altpiksel sırası ve DPI için `fonts.rendering`'de bulunur. Kontrol Merkezi, bunları `argvus-config` boyunca korur; kendi kullanıcı dosyalarını yazmaz. `argvus-config` daha sonra `data/generated/fonts.conf`'yi projekte eder ve `data/waybar/argvus-taskbar.css` ile `data/waybar/argvus-widget-telemetry.css` içindeki sınırlı yazı tipi bloğunu yeniden yazar, böylece bu blokların dışındaki yazı tipi düzenlemeleri bir yazı tipi değişikliğinde korunur. Terminal ve GTK fontconfig kuralları yerel adaptör hedefi olarak kalır. Paket, kurulum sırasında yazı tipi önbellek güncellemesini çalıştırır.

Görev çubuğu modülünün oluşturulması, yayınlamadan önce ortaya çıkan JSONC'yi doğrular. Yardımcı programlar modülü listeleri, yalnızca üzerine gelindiğinde genişleyici içeren çekmece dahil etkin tercihleri temel alarak yeniden oluşturulur. Çalışma alanı simgesi modu, `{windows}`'u `{name}` ile birlikte render eder. Sistem tepsisi görünürlüğü yalnızca arka plan uygulama simgelerini etkiler.


Yardımcı grup projektörü, Opsiyonel modüllerde etkinleştirildiğinde ve görev çubuğu şablonu tarafından tanımlandığında özel/ai'yi korur. Onun nf-md-robot simgesi (U+F06A9) paylaşılan AI ajanları menüsünü açar; kullanılabilirlik, tüm diğer yardımcı simgeler devre dışı bırakıldığında da dahil olmak üzere modül tarafından kontrol edilmeye devam eder.


Yapay Zeka simgesi görünürlüğü /taskbar/icons/ai_agents_enabled tarafından kontrol edilir (varsayılan true), Kontrol Merkezi > Görünüm > Görev Çubuğu > Simgeler > İsteğe bağlı modüller > Yapay Zeka Ajanları altında gösterilir. Projektör, her uygulamada devre dışı bırakılmış durumu dikkate alır ve sadece Yapay Zeka Ajanları etkinleştirildiğinde yardımcı grubu korur.

Görev çubuğu projeksiyonu, `/taskbar/icons/update_status_enabled` doğru olduğunda Güncelleme Durumunu Araçlar ve ağ/performans grubu arasında ayrı bir gruba yerleştirir. Ayrıca eski oluşturulmuş yapılandırmaları modül tanımı ile yükseltir.

Yardımcı `argvus window-mode-menu`; `argvus window-mode-menu --status` Waybar JSON yayar. Master `argvus` paketi ile birlikte gönderilir. Mevcut özelleştirilmiş görev çubuğu kopyaları korunur: katılmak için paketlenmiş şablondan `custom/window-mode` modül tanımını ve grup girişini ekleyin veya Kontrol Merkezi'ni kullanın. Görünüm projektörü, tanımı mevcut olduğunda modülü korur, diğer yardımcı simgeler devre dışı olsa bile.

`window-bar` ve `window-controls` tema tüketicileri renklerini bg, fg ve accent'ten alır. Başlık çubuğu renkleri `argvus windows decorations` üzerinden yeniden yüklenir; pencere çubuğu kendi oluşturulan stil sayfasına uyar. Döşeme/Yüzen, Sticky/Aralıklı görünüm geometrisinden bağımsızdır.
