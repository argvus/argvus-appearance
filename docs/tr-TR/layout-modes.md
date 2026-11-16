---
title: Düzen modları
description: Sticky veya Aralıklı masaüstü düzenini seçin.
---

Sticky pencere ve kabuk yüzeylerini kompakt tutar. Spaced daha geniş boşluklar, yuvarlatılmış köşeler ve daha geniş görev çubuğu kenar boşlukları kullanır. Düzen modu seçilen temadan bağımsızdır; modlar değiştirildiğinde o modun geometrisi tekrar uygulanır.

**Kontrol Merkezi → Görünüm → Masaüstü → Görünüm Modu** yolunu izleyerek modu seçin veya `SUPER + Shift + M` ile seçicisini açın. Kanonik ayar `/layout/variant`’dir ve değerleri `sticky` ve `spaced`’dir. Çözümlenmiş Spaced tema kimlikleri `-spaced` son ekini kullanır. Mevcut `float` değerleri ve `-float` kimlikleri uyumluluk için okunabilir durumda kalır.

`argvus layout-mode-menu` (SUPER + Shift + M): **Tab / Shift+Tab**: Sticky/Spaced ⇄ Tile/Floating · Taskbar Top/Bottom. ↑/↓ ile Sticky veya Spaced seçin. Sağdaki dört kart döşenmiş veya yüzen pencereleri üstte veya altta görev çubuğuyla birleştirir; ↑/↓/←/→ uçta başa dönmez. Seçmek için tıklayın, uygulamak için Enter, iptal için Escape kullanın. Seçili olmayan mod soluktur; önizlemeler geçerli tema ve duvar kâğıdını kullanır. Bekleyen durum görünür kalır ve hata durumunda yeniden denenebilir.

Tema ve mod seçicileri oturum açılış ekranı olmadan ilerlemeyi kendi pencerelerinde gösterir. Yeniden yüklemeden önce görev çubuğunun son konumu hazırlanır; gerekli yeniden başlatmalar tek bir systemd işleminde birleştirilir.
