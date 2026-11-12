---
title: Efek
description: Konfigurasikan animasi, keburaman Hyprland global, dan transparansi per permukaan.
---

Pusat Kontrol diluncurkan melalui Foot dengan profil khusus yang dihasilkan di `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. Dengan Foot 1.28, transparansi diproyeksikan ke `[colors-dark] alpha` dan saklar Blur permukaan ke `[colors-dark] blur`; konfigurasi Foot normal dan terminal ARGVUS tetap independen.

## Saklar Animasi dan Efek

There are two independent master switches, both applied to

 through the canonical `hyprland.lua` /effects/animations  `/effects`  settings:

- **Animations** (

) controls everything that moves: workspace, window, fade, border and layer animations.
- **Efek** adalah pintasan untuk blur ( `/effects/animations` `/effects/blur_global_enabled`) dan transparansi Terminal, Peluncur, Telemetri Widget, Panel Kontrol, dan Bilah Tugas (`/effects/transparency_<surface>_enabled`). Menghidupkan atau mematikannya akan menulis semuanya (dan transparansi Pusat Kontrol juga). Setiap permukaan menyimpan halaman transparansinya sendiri, sehingga Efek dibaca sebagai **aktif ketika setidaknya salah satu dari mereka aktif** dan mati hanya ketika semuanya mati.Use

 dan `argvus effects-toggle animations status|enable|disable|toggle`. Kartu Tampilan Panel Kontrol menunjukkan satu tombol untuk masing-masing tombol. Mematikan tombol master akan menjaga setiap pengaturan halus pada halaman **Animasi** dan **Blur** (kecepatan, kurva, peralihan per daun, ukuran blur, dan lintasan), jadi menyalakannya kembali akan mengembalikan tampilan yang sama. `argvus effects-toggle effects status|enable|disable|toggle` mencetak `effects status` `enabled` ketika buram atau setidaknya salah satu permukaan transparansi tersebut diaktifkan. Menonaktifkan transparansi permukaan akan membuat seluruh permukaan Waybar menjadi buram: selain latar belakang, batas transparan bilah tugas dan Telemetri Widget menjadi warna solid yang ditampilkan di atas latar belakang tema. Setiap efek diaktifkan secara default pada instalasi baru, termasuk pada mesin virtual dan sesi berdaya rendah; hanya pengaturan eksplisit yang mematikannya.

## Semua efek sekaligus

`argvus effects-toggle` tanpa komponen bertindak pada animasi, blur dan transparansi secara bersamaan: `status` mencetak `enabled` hanya ketika ketiganya diaktifkan, `enable` dan `disable` mengganti ketiganya, dan `toggle` mematikan semuanya ketika `status` adalah `enabled` dan aktif sebaliknya. **SUPER + F6** menjalankan tombol ini. Untuk bertindak dalam satu grup, beri nama: `argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`. Halaman **Animasi** di Pusat Kontrol menggunakan formulir per komponen, sehingga tombol **Aktifkan** tetap hanya mengubah animasi saja.

## Transparansi

Setiap permukaan memiliki submenu **Transparansi** sendiri dengan tombol dan nilai pengaktifan. Halaman **Penampilan → Peluncur** mengontrol alur peluncur dan pemilih resmi berbasis Rofi: peluncur utama, pemilih emoji, kalkulator, pemilih papan klip, lembar contekan, dan menu perangkat yang dapat dilepas Rofi. Nilai Transparansinya adalah alfa latar belakang akhir, jadi `50` berarti opasitas latar belakang efektif sekitar `0.50`; teks, ikon, dan baris yang dipilih tetap buram. Dengan Transparansi dimatikan, peluncur menggunakan warna latar belakang tema aktif, sepenuhnya buram. Sakelar Blur-nya memilih lapisan `rofi` ke dalam pengaturan Blur global.Setiap nilai berkisar dari `0%` (tidak tembus pandang) hingga `100%` (sepenuhnya tembus pandang). Gunakan `+` dan `-` dalam langkah 5%, kemudian pilih **Terapkan** di halaman permukaan. Meninggalkan halaman akan membatalkan draft yang belum diterapkan.

Gunakan `↑` dan `↓` untuk berpindah antara **Enable** dan **Value**. Pada baris **Value**, `+` dan `-` menyesuaikan draf tanpa mengubah fokus. Tekan `Tab` untuk membuka **Actions**, lalu aktifkan **[ Apply ]**; `Esc` kembali ke halaman permukaan induk.

## Animasi

Buka **Pusat Kontrol → Hyprland → Animasi**. Halaman ini memiliki tombol **Aktifkan** dan daftar **Opsi** dengan **Kurva khusus** dan lima kategori. Setiap kategori mencantumkan animasinya, dan setiap animasi memiliki halamannya sendiri dengan **Gaya**, **Kecepatan**, **Kurva** dan, untuk membuka dan menutup jendela, **Persentase pop-in**. Animasi yang dapat dimatikan Hyprland juga memiliki baris **Enable**.

Setiap nilai pada halaman ini termasuk dalam satu draf yang dibagikan oleh seluruh pohon Animasi. Tidak ada yang ditulis sampai **[ Terapkan ]** dipilih di bagian bawah salah satu dari mereka. Berpindah antar halaman akan mempertahankan drafnya; meninggalkan halaman Animasi dengan draf yang belum diterapkan meminta konfirmasi. Terapkan, tulis nilai yang diubah dalam satu panggilan dan muat ulang Hyprland. Tombol **Aktifkan** di bagian atas adalah status animasi global (`effects.animations`): jika mati, setiap animasi dinonaktifkan, apa pun yang tertulis di tombolnya.

Kontrol: `↑/↓` berpindah antar baris; `←/→` (atau `+/-`) mengubah nilai dan siklus yang dipilih **Gaya** dan **Kurva**; `Enter` mengetik **Kecepatan**, **Persentase pop-in** atau parameter kurva yang tepat (nilai di luar rentang ditolak), dan memutar **Gaya** dan **Kurva** ke depan.

### Kategori dan animasi

| Kategori | Animasi | Kunci (`effects.animation_<key>_*`) | Gaya (default) | Kecepatan | Aktifkan |
|---|---|---|---|---|---|
| jendela | Pembukaan jendela | `opening` | `popin`, muncul 87% | 4.1 | — |
| jendela | Menutup jendela | `closing` | `popin`, muncul 87% | 1.49 | — |
| jendela | Memindahkan jendela | `moving` | — | 4.79 | ya |
| Ruang Kerja | Berpindah ruang kerja | `switching` | `fade` | 1.94 | — |
| Ruang Kerja | Pintu masuk ruang kerja | `workspace_in` | `fade` | 1.21 | — |
| Ruang Kerja | Keluar ruang kerja | `workspace_out` | `fade` | 1.94 | — |
| Ruang Kerja | Ruang kerja khusus | `special_workspace` | `slide` | 5 | — |
| Lapisan & popup | Permukaan lapisan | `layers` | — | 3.81 | ya |
| Lapisan & popup | Pintu masuk lapisan | `layers_in` | `fade` | 4 | — |
| Lapisan & popup | Lapisan keluar | `layers_out` | `fade` | 1.5 | — |
| Lapisan & popup | Memudar | `fade` | — | 3.03 | ya |
| Lapisan & popup | Memudar | `fade_in` | — | 1.73 | ya |
| Lapisan & popup | Memudar | `fade_out` | — | 1.46 | ya |
| Perbatasan & efek | Warna batas | `border` | — | 5.39 | ya |
| Perbatasan & efek | Sudut gradien batas | `border_angle` | — | 5 | ya |
| Animasi lainnya | Faktor pembesaran | `zoom` | — | 7 | ya |
| Animasi lainnya | Monitor ditambahkan | `monitor_added` | — | 5 | ya |

Default daun yang dikirimkan Hyprland 0.56.2 dalam konfigurasi stoknya (setiap baris kecuali Ruang kerja khusus, Sudut gradien perbatasan, dan Monitor ditambahkan) adalah kecepatan, gaya, dan kurva stok. Ketiganya tetap menggunakan default ARGVUS, karena konfigurasi stok tidak menentukannya.Setiap daun hanya menawarkan gaya yang diterima Hyprland 0.56.2. Penawaran pembukaan dan penutupan jendela `slide`, `popin`, `slidefade`, `slidevert`, `slidefadevert` dan `gnomed`. Penawaran lapisan masuk dan keluar `slide`, `popin`, `fade`, `slidefade`, `slidevert` dan `slidefadevert`. Daun ruang kerja (peralihan, masuk, keluar, dan ruang kerja khusus) menawarkan `slide`, `fade`, `slidefade`, `slidevert` dan `slidefadevert`, tanpa `popin` atau `gnomed`. Gaya yang disimpan di luar daftar daunnya diabaikan dan daun tersebut menggunakan gaya defaultnya. Setiap animasi dimulai dengan kurva `default`. Sebuah halaman hanya menawarkan baris yang didukung animasinya. Kunci yang disimpan adalah `effects.animation_<key>_speed`, `_curve`, `_style` (where offered), `_popin` (window opening and closing) and `_enabled` (where offered).

### kurva

| Kurva | Perilaku | Parameter (kunci → default) |
|---|---|---|
| `default` | Kurva Hyprland 0.56.2 dikirim untuk animasi itu (misalnya `easeOutQuint`, `almostLinear`, `quick`, `linear`atau`easy`musim semi). Animasi tanpa kurva stok menggunakan Bézier bawaan ARGVUS. | Diperbaiki. |
| `bezier` | Gerakan halus yang dipercepat dan diperlambat, dibentuk oleh dua titik kontrol. | `bezier_x1` 0.23, `bezier_y1` 1, `bezier_x2` 0.32, `bezier_y2` 1 (x 0–1, y −2–3) |
| `spring` | Gerakan fisik dengan massa, kekakuan, dan peredaman; dapat melampaui untuk efek elastis. | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 |
| `linear` | Kecepatan konstan untuk seluruh animasi, dari `(0, 0)` to `(1, 1)`. | Fixed. |
| `ease_out` | Cepat di awal dan halus di akhir, dari `(0, 0)` to `(0.58, 1)`. | Fixed. |

Di bawah **Kurva Kustom**, setiap kurva memiliki halamannya sendiri. Bézier mengedit empat titik kontrolnya, Spring mengedit massa, kekakuan, dan redaman, dan Linear serta Ease-out menampilkan titik tetap mereka. Nilai Bézier dan Spring berlaku untuk setiap animasi yang memilih kurva tersebut.

Rentang dan langkah: **Kecepatan** 1–10 dengan desimal (langkah 0,1, kecepatan stok dalam desimal); **Persentase pop-in** 1–100 dalam bilangan bulat (langkah 5, stok 87); Bézier poin seperti di atas (langkah 0,05); Massa pegas 0,5–10 (langkah 0,1), kekakuan 0,5–2000 (langkah 10) dan peredaman 0,5–200 (langkah 1).Tidak ditawarkan: Hyprland 0.56.2 tidak memiliki animasi terpisah untuk mengubah ukuran jendela, untuk popup, atau untuk sudut gradien bayangan dan cahaya, jadi halaman tidak menampilkan baris untuk mereka.

## Kabur

Blur adalah satu pengaturan global Hyprland, yang dibagikan oleh setiap permukaan yang memilih untuk ikut. Buka **Control Center → Hyprland → Blur**. Halaman ini memiliki sakelar **Enable** dan daftar **Values** dengan parameter `decoration:blur` Hyprland, di bawah nama yang digunakan Hyprland:

| Baris | Kunci konfigurasi | Bawaan | Rentang | Langkah `←/→` |
|---|---|---|---|---|
| Ukuran | `effects.blur_size` | `6` | 1–64 | 1 |
| Lulus | `effects.blur_passes` | `2` | 1–8 | 1 |
| Kecerahan | `effects.blur_brightness` | `1` | 0–2 | 0,05 |
| Kebisingan | `effects.blur_noise` | `0.00` | 0–1 | 0,01 |
| Kontras | `effects.blur_contrast` | `0.900000` | 0–2 | 0,05 |
| Semangat | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0,01 |
| Kegelapan yang cerah | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0,01 |

Gunakan `↑/↓` untuk memindahkan, `←/→` (atau `+/-`) untuk mengubah nilai yang dipilih berdasarkan langkahnya, dan `Enter` untuk mengetikkan nilai yang tepat; nilai di luar rentang ditolak. Tidak ada yang tertulis saat Anda mengedit: tombol dan nilai tetap berada di draf hingga **[ Terapkan ]** di bagian bawah halaman yang dipilih. Terapkan penulisan setiap nilai yang diubah dalam satu panggilan, dan memuat ulang Hyprland setelahnya. Meninggalkan halaman dengan draf yang belum diterapkan akan meminta konfirmasi.

Nilai-nilai diteruskan ke Hyprland sebagaimana adanya; ARGVUS tidak memperolehnya dari persentase. Mengubah saklar satu permukaan tidak mengubah nilainya.## Shadow

Bayangan jendela adalah pengaturan global Hyprland, di bawah **Control Center → Hyprland → Borders → Shadow**. Hal ini independen dari transparansi dan blur: secara default dimatikan, dan mengaktifkan atau menonaktifkan transparansi sebuah permukaan tidak mengubahnya.

| Baris | Kunci konfigurasi | Bawaan | Rentang | Langkah `←/→` |
|---|---|---|---|---|
| Aktifkan | `effects.shadow_enabled` | `false` | — | — |
| Tajam | `effects.shadow_sharp` | `false` | — | — |
| Warna | `effects.shadow_color` | kosong (mengikuti aksen) | kosong atau `RRGGBBAA` | — |
| Rentang | `effects.shadow_range` | `6` | 0–100 | 1 |
| Kekuatan render | `effects.shadow_render_power` | `6` | 1–10 | 1 |
| Mengimbangi X | `effects.shadow_offset_x` | `0` | −100 hingga 100 | 1 |
| Mengimbangi Y | `effects.shadow_offset_y` | `0` | −100 hingga 100 | 1 |
| Skala | `effects.shadow_scale` | `1.00` | 0–1 | 0,05 |

Warna kosong mengikuti aksen dari tema aktif dengan alfa `99`, sehingga aksen biru default memberikan `3590bd99`. Ketik delapan digit heksadesimal (`RRGGBBAA`) untuk mengatur warna, atau biarkan prompt kosong untuk kembali mengikuti aksen. Warna akan dibaca saat konfigurasi Hyprland dimuat, jadi setelah perubahan tema atau aksen, warna baru akan diterapkan pada pemuatan konfigurasi berikutnya.

Seperti Blur, halaman mengedit draft: tidak ada yang ditulis sampai **[ Terapkan ]** dipilih, dan meninggalkan halaman dengan draft yang belum diterapkan meminta konfirmasi.

## Status kanonik dan file kompatibilitas

Preferensi logis disimpan di `$XDG_CONFIG_HOME/argvus/config.json`. Animasi global menggunakan `effects.animations`; nilai Animations menggunakan kunci `effects.animation_*` yang dijelaskan di atas. Saklar Blur global adalah `effects.blur_global_enabled`, dan nilai Blur menggunakan kunci `effects.blur_*` yang tercantum di atas. Status enable permukaan dan nilai transparansi menggunakan kunci seperti `effects.blur_control-center_enabled` dan `effects.transparency_control-center_value`. Nilai transparansi dibatasi hingga `0–100`; setiap nilai Blur dibatasi ke jangkauannya sendiri, dan `argvus-config` menolak penulisan di luar itu. Status enable tetap terpisah dari override yang hilang.

Persentase `effects.blur_global_value` sebelumnya tidak lagi dibaca. Profil yang masih mengandungnya menyimpan kunci di disk tanpa efek, dan Blur menggunakan default di atas hingga nilainya diterapkan.

```text
$XDG_CONFIG_HOME/argvus/config.json
```

`data/generated/effects/<active-theme>.conf` adalah proyeksi efek, ditulis hanya oleh `argvus config`; `argvus effects-toggle` mendelegasikan ke `argvus config effects`. Pergantian tema atau mode menerapkan kembali profil visual tema yang aktif, termasuk nilai per-permukaan dari `effects.conf` bila ada. Tema tanpa profil mengembalikan default efek yang dikemas. Ekspor tema setelah mengubah efek jika Anda ingin nilai-nilai tersebut tetap ada setelah pergantian tema atau mode berikutnya.

Menonaktifkan saklar Transparansi atau Blur pada suatu permukaan hanya memengaruhi permukaan tersebut; nilai numerik yang disimpan tetap tersimpan untuk diaktifkan kembali nanti. Ekspor tema

## Profil

mencakup pengaturan tampilan/efek kanonik dan proyeksi efek per-permukaan dari tema aktif. File runtime Waybar, Quickshell, dan Hyprland yang dihasilkan dibuat ulang saat tema diterapkan.

Semua halaman permukaan menerapkan draf mereka bersama dengan tombol `[ Apply ]`. Pusat Kontrol menulis dokumen kanonik melalui pembantu efek, membiarkan `argvus-config` memproyeksikan pohon efek, memuat ulang konsumen yang terpengaruh dan membaca kembali nilai efektif. File yang dihasilkan dibuat ulang alih-alih diimpor sebagai status otoritatif.

## Cahaya Malam

**SUPER + Shift + B** mempertahankan pemilih kecerahan dan menambahkan tombol Lampu Malam terpisah dengan status/suhu efektif. Itu memanggil `argvus config display night-light status|toggle`. Cahaya Malam memerlukan Hyprland dan Hyprsunset >= 0.4.0 yang merespons, terlepas dari dukungan kecerahan. Kisarannya adalah 1000–20000 K; konfigurasi ada di **Desktop & Input > Tampilan > Lampu Malam** di Pusat Kontrol. Peralihan bersifat persisten tanpa penjadwalan, atau penggantian yang mudah berubah until the next transition with scheduling. Cancelling the menu changes nothing.
