---
title: Duvar Kağıtları
description: Yerleşik ve özel ARGVUS duvar kağıtlarını kullanın.
---

`argvus-wallpapers` tarafından `/usr/share/backgrounds/argvus/` altında yerleşik JPEG XL duvar kağıtları kuruludur. **Kontrol Merkezi → Görünüm → Duvar Kağıtları** bölümünde, `Abstract` veya `Landscape` olarak düzenlenmiş, ardından `Dark` veya `Light` altına sıralanmıştır. Root `argvus-dark.jxl` ve `argvus-light.jxl` dosyaları soyut yedekleme grupları altında görünür. Tema değiştirme yalnızca `abstract/dark` ve `abstract/light` içindeki soyut dosyaları kullanır; manzara dosyaları isteğe bağlı manuel seçimlerdir. Bu Kontrol Merkezi ekranını doğrudan açmak için `SUPER + Y` tuşuna basın. İlk giriş ayrıca HOME'dan özel bir görüntü kabul eder; seçilen dosya kullanıcının özel duvar kağıdı durumu olur.

İlk giriş, özel bir görüntü için bir dosya seçiciyi açar. Seçilen bir özel duvar kağıdı, kanonik yapılandırmada `/appearance/wallpaper_custom` ile birlikte `/appearance/wallpaper` olarak depolanır ve Soyut, bunu oturum tarafından tüketilen Hyprland duvar kağıdı yapılandırmasına yansıtır. Bir tema veya mod değişikliği o temanın duvar kağıdını yeniden uygulayana kadar etkin kalır. Geçerli duvar kağıdını eklemek ve dışa aktarılan temada korumak için etkin temayı dışa aktarın. Manzara yalnızca eski bir geçiş girişidir.

Bir tema dışa aktarıldığında, mevcut duvar kağıdı görüntüsü okunabilir durumda ise dahil edilir. İçe aktarma, temayı kurar; bunu uygulamak duvar kağıdını etkinleştirir. Bkz. [Temaları içe ve dışa aktarma](/docs/components/argvus-themes/import-and-export/).

Kullanıcıya yönelik görünüm kontrolleri, seçilen yolu kendisi duvar kağıdı durumunu saklamak yerine `argvus config` üzerinden işleyen Hyprland yardımcısı  `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` `hypr-wallpaper-pick.sh` `argvus config` 'yu kullanır. Oluşturulan duvar kağıdı yapılandırmasını doğrudan düzenlemeyin.
