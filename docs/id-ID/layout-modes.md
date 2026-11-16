---
title: Mode tata letak
description: Pilih tata letak desktop Sticky atau Spaced.
---

Sticky menjaga jendela dan permukaan shell tetap kompak. Spaced menggunakan celah yang lebih besar, sudut yang membulat, dan margin taskbar yang lebih lebar. Mode tata letak bersifat independen dari tema yang dipilih; mengganti mode akan menerapkan kembali geometri mode tersebut.

Pilih mode di **Control Center → Appearance → Desktop → Appearance Mode** atau buka pemilihnya dengan `SUPER + Shift + M`. Pengaturan kanonik adalah `/layout/variant`, dengan nilai `sticky` dan `spaced`. ID tema Spaced yang telah diselesaikan menggunakan akhiran `-spaced`. Nilai `float` yang ada dan ID `-float` tetap dapat dibaca untuk kompatibilitas.

`argvus layout-mode-menu` (SUPER + Shift + M): Pilih Sticky atau Spaced dengan ↑/↓. Empat kartu di kanan menggabungkan jendela ubin atau mengambang dengan taskbar atas atau bawah; ←/→ bergerak tanpa berputar. Klik untuk memilih, Enter untuk menerapkan, Escape untuk membatalkan. Mode yang tidak dipilih diredupkan; pratinjau memakai tema dan wallpaper saat ini. Status tertunda tetap terlihat dan kegagalan dapat dicoba lagi.
