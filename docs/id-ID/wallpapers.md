---
title: Wallpapers
description: Gunakan wallpaper ARGVUS bawaan dan kustom.
---

Wallpaper JPEG XL bawaan diinstal oleh `argvus-wallpapers` di bawah `/usr/share/backgrounds/argvus/`. Di **Control Center → Appearance → Wallpapers**, mereka diatur sebagai `Abstract` atau `Landscape`, kemudian berdasarkan `Dark` atau `Light`. File root `argvus-dark.jxl` dan `argvus-light.jxl` muncul di bawah grup fallback abstrak. Pergantian tema hanya menggunakan file abstrak di `abstract/dark` dan `abstract/light`; file lanskap adalah pilihan manual opsional. Tekan `SUPER + Y` untuk membuka layar Control Center ini secara langsung. Entri pertama juga menerima gambar kustom dari HOME; file yang dipilih menjadi status wallpaper kustom pengguna.

Entri pertama membuka pemilih berkas untuk gambar kustom. Wallpaper kustom yang dipilih disimpan sebagai `/appearance/wallpaper` bersama dengan `/appearance/wallpaper_custom` dalam konfigurasi kanonik, dan `argvus config` memproyeksikannya ke dalam konfigurasi wallpaper Hyprland yang digunakan oleh sesi. Wallpaper tetap aktif sampai tema atau mode berubah dan menerapkan kembali wallpaper tema tersebut. Ekspor tema aktif untuk menyertakan wallpaper saat ini dan pertahankan di tema yang diekspor. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` hanya merupakan input migrasi warisan.

Ketika sebuah tema diekspor, gambar wallpaper saat ini disertakan ketika dapat dibaca. Impor menginstal tema; menerapkannya mengaktifkan wallpaper-nya. Lihat [Mengimpor dan mengekspor tema](/docs/components/argvus-themes/import-and-export/).

Kontrol tampilan yang dihadapi pengguna menggunakan pembantu Hyprland `hypr-wallpaper-pick.sh`, yang mengirimkan jalur yang dipilih melalui `argvus config` alih-alih menyimpan status wallpaper itu sendiri. Jangan mengedit konfigurasi wallpaper yang dihasilkan secara langsung.
