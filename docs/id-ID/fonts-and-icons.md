---
title: Fonts and icons
description: Konfigurasikan font dan tema ikon yang digunakan oleh ARGVUS.
---

`argvus-fonts` menginstal font bawaan di bawah `/usr/share/fonts/`; `argvus-icons` menginstal tema ikon ARGVUS. `argvus-appearance` dan Pusat Kontrol menghubungkan aset ini ke tema desktop.

## Font utama

Font utama default ARGVUS adalah **IBM Plex Mono**, dengan gaya `Regular`. Ini adalah keluarga default yang digunakan oleh target font yang ditampilkan di Control Center. Paket `argvus-fonts` yang disertakan menyediakan IBM Plex Mono dan keluarga ikon/terminal pendukung yang digunakan oleh desktop.

Buka **Control Center → Fonts** untuk mengonfigurasi target individu:

- taskbar;
- telemetry/system information;
- Control Panel;
- ARGVUS system interface;
- applications;
- terminal;
- browser.

Ukuran default bersifat spesifik sesuai target: taskbar, sistem, dan terminal menggunakan `13`; telemetri dan Panel Kontrol menggunakan `14`; aplikasi menggunakan `12`; dan browser menggunakan `10`. Default ini dapat dikembalikan dari halaman Font.

## Tema ikon

Tema ikon aktif disimpan secara kanonik sebagai `appearance.icon_theme` di `config.json`. Nilai kosong (default) memilih tema ikon ARGVUS dari mode tema aktif: `Argvus Dark Icons` untuk tema gelap dan `Argvus Light Icons` untuk tema terang, keduanya diinstal oleh `argvus-icons`.

`sh/icon-switch.sh` menyelesaikan tema yang efektif dan menerapkannya ke setiap pengguna:

- GNOME settings: `org.gnome.desktop.interface icon-theme`;
- GTK 3 dan GTK 4: `gtk-icon-theme-name`di ARGVUS dan asli`settings.ini` files;
- Qt: `icon_theme`dalam yang dikelola`qt6ct.conf`, dan dalam bahasa asli`qt6ct.conf` saat itu dihasilkan oleh ARGVUS.

Tema dicari di `/usr/share/icons`, `$XDG_DATA_HOME/icons` dan `~/.icons`. Tema yang dikonfigurasi tetapi tidak terpasang, atau nilai yang mengandung `/` atau adalah `..`, kembali ke default mode yang sama dan mencatat pesan, sehingga desktop tidak pernah mengarah pada tema yang hilang. Pergantian tema atau mode menggunakan pilihan ikon dari profil tema yang diekspor saat tersedia, jika tidak maka mengembalikan default mode yang dikemas. Ekspor tema untuk mempertahankan pilihan ikon kustom saat berganti-ganti.

Gunakan kontrol font di Pusat Kontrol. Preferensi font adalah kanonik di `config.json`, di `fonts.targets.<target>` untuk keluarga, gaya, dan ukuran serta `fonts.rendering` untuk antialiasing, hinting, urutan subpiksel, dan DPI. Pusat Kontrol mempertahankannya melalui `argvus-config`; ia tidak menulis file konsumen sendiri. `argvus-config` kemudian memproyeksikan `data/generated/fonts.conf` dan menulis ulang blok font terbatas di dalam `data/waybar/argvus-taskbar.css` dan `data/waybar/argvus-widget-telemetry.css`, sehingga pengeditan font di luar blok tersebut tetap ada setelah perubahan font. Aturan terminal dan fontconfig GTK tetap menjadi target adaptor asli. Paket menjalankan pembaruan cache font selama instalasi.

Generasi modul taskbar memvalidasi JSONC yang dihasilkan sebelum dipublikasikan. Daftar modul utilitas dibangun kembali dari preferensi yang diaktifkan, termasuk pengembang laci hanya dalam mode hover. Mode ikon workspace menampilkan `{windows}` di samping `{name}`. Visibilitas baki sistem hanya mempengaruhi ikon aplikasi latar belakang.


Proyektor grup utilitas mempertahankan custom/ai saat diaktifkan dalam Modul Opsional dan didefinisikan oleh template bilah tugas. Glyph nf-md-robot-nya (U+F06A9) membuka menu agen AI bersama; ketersediaan tetap dikontrol oleh modul, termasuk ketika semua ikon utilitas lainnya dinonaktifkan.


Visibilitas ikon AI dikontrol oleh /taskbar/icons/ai_agents_enabled (default true), ditampilkan di bawah Control Center > Appearance > Taskbar > Icons > Optional modules > AI Agents. Proyektor menghormati status nonaktif pada setiap penerapan dan mempertahankan grup utilitas ketika hanya AI Agents yang diaktifkan.

Proyektor taskbar menempatkan Status Pembaruan dalam grup terpisah antara Utilitas dan grup jaringan/kinerja ketika `/taskbar/icons/update_status_enabled` bernilai benar. Ini juga meningkatkan konfigurasi yang dibuat sebelumnya dengan definisi modul.

Bantuan adalah `argvus window-mode-menu`; `argvus window-mode-menu --status` mengeluarkan JSON Waybar. Ini dikirimkan oleh paket master `argvus`. Salinan taskbar yang telah dikustomisasi sebelumnya dipertahankan: tambahkan definisi modul `custom/window-mode` dan entri grup dari template paket untuk berpartisipasi, atau gunakan Control Center. Proyektor tampilan mempertahankan modul ketika definisinya ada, bahkan jika ikon utilitas lain dinonaktifkan.

Konsumen tema `window-bar` dan `window-controls` memperoleh warnanya dari bg, fg, dan aksen. Warna bilah judul dimuat ulang melalui `argvus windows decorations`; bilah jendela mengikuti stylesheet yang dihasilkan. Tile/Floating bersifat independen dari geometri tampilan Sticky/Spaced.
