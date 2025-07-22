# SatuLemari - Aplikasi Mobile (Flutter)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.4%2B-blue.svg)](https://dart.dev)

Aplikasi mobile untuk platform donasi dan rental pakaian **SatuLemari**. Dibangun dengan Flutter untuk pengalaman cross-platform yang mulus di Android dan iOS, menghubungkan mitra (pemilik pakaian) dengan pengguna yang membutuhkan pakaian untuk donasi atau sewa.

## ✨ Fitur Utama

- **Otentikasi Lengkap**: Pendaftaran, Login, dan Google Sign-In menggunakan Firebase Authentication.
- **Manajemen Donasi & Rental**: Alur lengkap mulai dari melihat item, mengajukan permintaan, hingga melihat riwayat transaksi.
- **Pencarian Cerdas & Rekomendasi**:
  - Pencarian item dengan filter kategori.
  - Rekomendasi item yang dipersonalisasi dan sedang tren, didukung oleh AI dari backend.
  - Analisis _intent_ pengguna dari input bahasa natural (speech-to-text).
- **Profil & Dashboard Pengguna**: Kelola profil, lihat statistik donasi/sewa, dan atur lokasi.
- **Geolokasi**: Tampilkan item dan mitra di peta interaktif, serta pilih lokasi dengan _location picker_.
- **Notifikasi Real-time**:
  - Notifikasi dalam aplikasi untuk status permintaan, dll.
  - Push Notifikasi (FCM) untuk menjaga pengguna tetap terinformasi.
- **Manajemen State Modern**: Menggunakan BLoC untuk manajemen state yang predictable dan scalable.
- **Desain UI Responsif & Modern**: Tampilan yang bersih, modern, dengan _shimmer effect_ saat loading dan _onboarding_ yang menarik.
- **Penanganan Offline**: Cek konektivitas internet dan menampilkan pesan yang sesuai.

## 🏗️ Arsitektur Aplikasi

Proyek ini mengadopsi arsitektur **Clean Architecture** yang dipisahkan berdasarkan fitur (_feature-first_), memastikan kode yang terorganisir, mudah diuji, dan scalable. Setiap fitur mandiri dan memiliki lapisan Data, Domain, dan Presentation sendiri.

```
lib/
├── core/                   # Kode inti yang digunakan di seluruh aplikasi
│   ├── constants/          # Konstanta aplikasi (warna, string, tema)
│   ├── di/                 # Dependency Injection setup (GetIt)
│   ├── errors/             # Custom Failures dan Exceptions
│   ├── network/            # Konfigurasi network (Dio interceptors, info konektivitas)
│   ├── services/           # Servis background (notifikasi, cache)
│   ├── usecases/           # Abstract use case base class
│   └── utils/              # Fungsi utilitas umum (validator, extension)
│
├── features/               # Modul-modul fitur aplikasi
│   └── (contoh: auth)/
│       ├── data/           # Lapisan Data: Implementasi repository & sumber data
│       │   ├── datasources/  # Komunikasi dengan API (remote) atau cache (local)
│       │   └── models/       # Model data untuk parsing JSON (DTOs)
│       │
│       ├── domain/         # Lapisan Domain: Logika bisnis inti (murni Dart)
│       │   ├── entities/     # Objek bisnis utama (Plain Dart Objects)
│       │   ├── repositories/ # Kontrak/abstract class untuk lapisan data
│       │   └── usecases/     # Aksi spesifik yang bisa dilakukan dalam fitur
│       │
│       └── presentation/   # Lapisan Presentation: UI dan manajemen state
│           ├── bloc/         # BLoC, Events, dan States
│           ├── pages/        # Halaman/layar utama dari fitur
│           └── widgets/      # Widget yang spesifik untuk fitur ini
│
├── shared/                 # Widget yang dapat digunakan kembali di berbagai fitur
│   └── widgets/            # Contoh: CustomButton, ProductCard, LoadingWidget
│
└── main.dart               # Entry point utama aplikasi dan setup routing
```

## 🛠️ Teknologi & Library Utama

- **Framework**: Flutter
- **Bahasa**: Dart
- **Arsitektur**: Clean Architecture + BLoC Pattern
- **Manajemen State**: `flutter_bloc`, `bloc`
- **Routing**: `go_router`
- **Dependency Injection**: `get_it`
- **Networking**: `dio`, `retrofit`
- **Database Lokal**: `shared_preferences` (untuk cache sederhana)
- **Otentikasi & Notifikasi**: `firebase_auth`, `google_sign_in`, `firebase_messaging`
- **Geolokasi & Peta**: `geolocator`, `geocoding`, `flutter_map`
- **UI & UX**:
  - `cached_network_image` untuk caching gambar.
  - `shimmer` untuk efek loading.
  - `image_picker` & `image_cropper` untuk manajemen gambar.
  - `smooth_page_indicator` untuk onboarding.
- **Code Generation**: `build_runner`, `json_serializable`, `retrofit_generator`
- **Lainnya**: `dartz` (Functional Programming), `intl` (Formatting), `url_launcher`.

## 📋 Prasyarat

- Flutter SDK (versi 3.x atau lebih baru)
- Dart SDK (versi 3.4 atau lebih baru)
- IDE seperti VS Code atau Android Studio
- Emulator Android atau Simulator iOS (atau perangkat fisik)
- Koneksi ke **SatuLemari Backend API**.

## 🔧 Setup & Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/dzuura/satu-lemari-app.git
cd satu-lemari-app
```

### 2. Konfigurasi Firebase

Aplikasi ini memerlukan konfigurasi Firebase untuk Otentikasi dan Notifikasi.

1.  Ikuti panduan [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup?platform=cli) untuk menghubungkan proyek Flutter Anda dengan proyek Firebase.
2.  Jalankan perintah berikut di root proyek:
    ```bash
    flutterfire configure
    ```
3.  Pilih proyek Firebase yang sesuai saat diminta. Ini akan secara otomatis membuat file `firebase_options.dart`.
4.  Pastikan Anda telah mengaktifkan **Authentication (Email/Password, Google)** dan **Cloud Messaging (FCM)** di Firebase Console.
5.  Untuk **Google Sign-In di Android**, pastikan Anda telah menambahkan **SHA-1 certificate fingerprint** ke pengaturan proyek Firebase Anda. Anda bisa mendapatkannya dengan menjalankan:
    ```bash
    cd android && ./gradlew signingReport
    ```

### 3. Konfigurasi Environment

1.  Buat file `.env` di root direktori proyek. Anda bisa menyalin dari contoh jika ada, atau buat baru.
2.  Isi file `.env` dengan variabel yang dibutuhkan, terutama URL base dari backend API.
    ```env
    BASE_URL=http://localhost:8080/api/v1
    ```
    _(Ganti dengan URL backend production jika perlu)_

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Jalankan Code Generator

Beberapa model dan network client memerlukan kode yang di-generate. Jalankan perintah ini:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Jalankan Aplikasi

```bash
flutter run
```

Aplikasi akan berjalan di emulator/simulator atau perangkat yang terhubung.

## 🤝 Berkontribusi

Kami menyambut kontribusi dari siapa saja!

1.  Fork repository ini.
2.  Buat branch fitur baru (`git checkout -b feature/nama-fitur-keren`).
3.  Lakukan perubahan dan commit (`git commit -m 'feat: Menambahkan fitur keren'`).
4.  Push ke branch Anda (`git push origin feature/nama-fitur-keren`).
5.  Buka sebuah Pull Request.

## 📝 Pesan Commit

Gunakan format _conventional commits_ untuk pesan commit yang rapi dan terstandar:

```
feat: Menambahkan halaman detail item
fix: Memperbaiki bug pada form login
docs: Memperbarui dokumentasi setup
refactor: Meningkatkan performa home page
style: Merapikan format kode pada widget profile
```

## 📄 Lisensi

Didistribusikan di bawah Lisensi MIT. Lihat file `LICENSE` untuk informasi lebih lanjut.

## 📞 Kontak

- **Email**: satulemariapp@gmail.com
- **Backend Repository**: [SatuLemari Backend](https://github.com/dzuura/satu-lemari)

---

**SatuLemari** - Menghubungkan kebaikan dengan kebutuhan melalui donasi dan penyewaan pakaian. 🌱👕
