<div align="center">
  <img src="https://drive.google.com/uc?export=view&id=1aKMuVTTZfrKqlsPLQNjhgxPMZwT1D3jp" alt="SatuLemari Logo" width="200"/>
  
  # SatuLemari - Aplikasi Mobile (Flutter)
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
  [![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
  [![Dart Version](https://img.shields.io/badge/Dart-3.4%2B-blue.svg)](https://dart.dev)
</div>

**"Satu Pakaian, Seribu Senyuman"**

Aplikasi mobile untuk platform donasi, rental, dan thrifting pakaian **SatuLemari**. Dibangun dengan Flutter untuk pengalaman cross-platform yang mulus di Android dan iOS, menghubungkan mitra (pemilik pakaian) dengan pengguna yang membutuhkan pakaian untuk donasi, sewa, atau pembelian secondhand.

## ✨ Fitur Utama

- **Otentikasi Lengkap**: Pendaftaran, Login, dan Google Sign-In menggunakan Firebase Authentication dengan FCM token management otomatis.
- **Tiga Kategori Layanan**:
  - **Donasi**: Ajukan permintaan donasi pakaian gratis
  - **Rental**: Sewa pakaian untuk acara khusus
  - **Thrifting**: Beli pakaian secondhand dengan harga terjangkau
- **Manajemen Request Komprehensif**: Alur lengkap mulai dari melihat item, mengajukan permintaan (donasi/rental/thrifting), hingga melihat riwayat transaksi dengan detail lengkap.
- **Chat Interaktif dengan AI**:
  - Chatbot pintar dengan saran otomatis dan quick replies.
  - Manajemen sesi chat dengan kemampuan hapus pesan dan riwayat.
  - Sistem typing indicator untuk pengalaman chat yang natural.
  - Multiple chat sessions dengan navigasi yang mudah.
- **Pencarian Cerdas & Rekomendasi**:
  - Pencarian item dengan filter kategori dan speech-to-text.
  - Rekomendasi item yang dipersonalisasi dan sedang tren, didukung oleh AI dari backend.
  - Analisis _intent_ pengguna dari input bahasa natural.
  - Saran AI berdasarkan preferensi dan item serupa.
- **Notifikasi Komprehensif**:
  - Sistem notifikasi in-app dengan statistik yang detail.
  - Push Notifikasi (FCM) untuk menjaga pengguna tetap terinformasi.
  - Manajemen notifikasi dengan fitur mark as read, delete, dan bulk actions.
- **Profil & Dashboard Pengguna**: 
  - Kelola profil dengan edit foto dan informasi personal.
  - Dashboard statistik donasi/sewa/thrifting yang komprehensif.
  - Location picker dengan peta interaktif untuk mengatur alamat.
- **Sistem Order & Pembayaran**: 
  - Create order untuk rental dan thrifting dengan detail lengkap.
  - Integrasi pembayaran QRIS untuk transaksi yang mudah.
  - Tracking status order dari proses hingga selesai.
- **Geolokasi**: Tampilkan item dan mitra di peta interaktif, serta pilih lokasi dengan _location picker_ yang presisi.
- **Manajemen State Modern**: Menggunakan BLoC untuk manajemen state yang predictable dan scalable.
- **Desain UI Responsif & Modern**: 
  - Tampilan yang bersih, modern, dengan _shimmer effect_ saat loading.
  - _Onboarding_ yang menarik dengan smooth page indicators.
  - Full-screen image viewer untuk detail item.
- **Penanganan Offline**: Cek konektivitas internet dan menampilkan pesan yang sesuai dengan connectivity wrapper.

## 🏗️ Arsitektur Aplikasi

Proyek ini mengadopsi arsitektur **Clean Architecture** yang dipisahkan berdasarkan fitur (_feature-first_), memastikan kode yang terorganisir, mudah diuji, dan scalable. Setiap fitur mandiri dan dibagi menjadi **3 lapisan utama**:

- **Data Layer**: Menangani komunikasi dengan API, database lokal, dan parsing data
- **Domain Layer**: Berisi logika bisnis murni, entities, dan use cases 
- **Presentation Layer**: Mengatur UI, state management dengan BLoC, dan interaksi user

```
lib/
├── core/                   # Kode inti yang digunakan di seluruh aplikasi
│   ├── constants/          # Konstanta aplikasi (warna, string, tema, URLs)
│   ├── di/                 # Dependency Injection setup (GetIt)
│   ├── errors/             # Custom Failures dan Exceptions
│   ├── models/             # Model umum (Pagination, dll)
│   ├── network/            # Konfigurasi network (Auth interceptor, network info)
│   ├── services/           # Servis background (notifikasi, cache, token refresh)
│   ├── usecases/           # Abstract use case base class
│   └── utils/              # Fungsi utilitas umum (validator, extension, FAB manager)
│
├── features/               # Modul-modul fitur aplikasi
│   ├── auth/               # 🔐 OTENTIKASI: Login, Register, Google Sign-In
│   ├── browse/             # 🔍 PENCARIAN: Smart search, AI suggestions, speech-to-text
│   ├── category_items/     # 📂 KATEGORI: Tampil item berdasarkan kategori
│   ├── chat/               # 💬 CHAT AI: Chatbot dengan multiple sessions
│   ├── debug/              # 🔧 DEBUG: Tools untuk development dan debugging
│   ├── history/            # 📋 RIWAYAT: History request & detail transaksi
│   ├── home/               # 🏠 BERANDA: Dashboard utama, kategori, rekomendasi
│   ├── item_detail/        # 📄 DETAIL ITEM: Info lengkap item dengan full-screen viewer
│   ├── main/               # 🧭 NAVIGASI: Bottom navigation & routing utama
│   ├── notification/       # 🔔 NOTIFIKASI: In-app dan push notifications
│   ├── onboarding/         # 👋 ONBOARDING: Welcome screens untuk user baru
│   ├── order/              # 🛒 ORDER: Create order, detail order, pembayaran QRIS
│   ├── profile/            # 👤 PROFIL: Edit profil, dashboard stats, location picker
│   ├── request/            # 📝 REQUEST: Buat permintaan donasi/rental/thrifting
│   └── splash/             # 🚀 SPLASH: Loading screen awal aplikasi
│
│   └── (contoh: auth)/     # Setiap fitur dibagi menjadi 3 lapisan:
│       ├── data/           # 📡 DATA LAYER: Implementasi repository & sumber data
│       │   ├── datasources/  # Komunikasi dengan API (remote) atau cache (local)
│       │   └── models/       # Model data untuk parsing JSON (DTOs)
│       │
│       ├── domain/         # 🧠 DOMAIN LAYER: Logika bisnis inti (murni Dart)
│       │   ├── entities/     # Objek bisnis utama (Plain Dart Objects)
│       │   ├── repositories/ # Kontrak/abstract class untuk lapisan data
│       │   └── usecases/     # Aksi spesifik yang bisa dilakukan dalam fitur
│       │
│       └── presentation/   # 🎨 PRESENTATION LAYER: UI dan manajemen state
│           ├── bloc/         # BLoC, Events, dan States
│           ├── pages/        # Halaman/layar utama dari fitur
│           ├── widgets/      # Widget yang spesifik untuk fitur ini
│           └── utils/        # Utilities khusus fitur (hanya ada di order/)
│
├── shared/                 # Widget yang dapat digunakan kembali
│   └── widgets/            # Custom components (buttons, cards, dialogs, dll)
│
└── main.dart               # Entry point utama aplikasi
```

### 📱 Fitur Utama per Modul

- **🏠 Home**: Dashboard dengan kategori (Donasi, Rental, Thrifting), rekomendasi personal, dan trending items
- **🔍 Browse**: Pencarian cerdas dengan filter, voice search, dan AI suggestions  
- **📂 Category Items**: Browse item berdasarkan kategori yang dipilih
- **📄 Item Detail**: Detail lengkap item dengan galeri foto dan full-screen viewer
- **📝 Request**: Form permintaan untuk ketiga kategori dengan widget khusus:
  - `donation_request_sheet.dart` - Form donasi
  - `rental_request_sheet.dart` - Form rental
  - `thrifting_request_sheet.dart` - Form thrifting
- **🛒 Order**: Sistem pemesanan lengkap dengan pembayaran QRIS untuk rental dan thrifting
- **📋 History**: Riwayat semua permintaan dan transaksi dengan detail lengkap
- **💬 Chat**: AI assistant dengan multiple chat sessions dan smart suggestions
- **🔔 Notification**: Manajemen notifikasi in-app dan push notifications
- **👤 Profile**: Edit profil, dashboard statistik, dan location picker dengan map
- **🔧 Debug**: Tools untuk development dan debugging

## 🛠️ Teknologi & Library Utama

- **Framework**: Flutter
- **Bahasa**: Dart
- **Arsitektur**: Clean Architecture + BLoC Pattern
- **Manajemen State**: `flutter_bloc`, `bloc`, `equatable`, `rxdart`
- **Dependency Injection**: `get_it`
- **Networking**: `dio`, `retrofit`, `http`, `connectivity_plus`, `internet_connection_checker`
- **Cookie & Session**: `cookie_jar`, `dio_cookie_manager`
- **Database Lokal**: `shared_preferences` (untuk cache sederhana)
- **Otentikasi & Notifikasi**: 
  - `firebase_core`, `firebase_auth`, `firebase_messaging`
  - `google_sign_in`, `flutter_local_notifications`
- **Geolokasi & Peta**: `geolocator`, `geocoding`, `flutter_map`, `latlong2`
- **UI & UX**:
  - `cached_network_image` untuk caching gambar
  - `shimmer` untuk efek loading
  - `image_picker` & `image_cropper` untuk manajemen gambar
  - `smooth_page_indicator` untuk onboarding
  - `flutter_staggered_grid_view` untuk grid layout
  - `photo_view` untuk full-screen image viewer
- **Pembayaran & QR**: `qr_flutter` untuk generate QR code pembayaran
- **Speech & Input**: `speech_to_text` untuk voice input
- **Code Generation**: `build_runner`, `json_serializable`, `retrofit_generator`
- **Functional Programming**: `dartz` untuk Either pattern
- **Utilities**: `intl`, `uuid`, `tuple`, `mime`, `url_launcher`, `flutter_dotenv`

## 📋 Prasyarat

- Flutter SDK (versi 3.x atau lebih baru)
- Dart SDK (versi 3.4 atau lebih baru)
- IDE seperti VS Code atau Android Studio
- Emulator Android atau Simulator iOS (atau perangkat fisik)
- Koneksi ke **SatuLemari Backend API**

## 🔧 Setup & Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/rezaluthfi/satu-lemari-app.git
cd satu-lemari-app
```

### 2. Konfigurasi Firebase

Aplikasi ini memerlukan konfigurasi Firebase untuk Otentikasi dan Notifikasi.

1. Ikuti panduan [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup?platform=cli) untuk menghubungkan proyek Flutter Anda dengan proyek Firebase.
2. Jalankan perintah berikut di root proyek:
   ```bash
   flutterfire configure
   ```
3. Pilih proyek Firebase yang sesuai saat diminta. Ini akan secara otomatis membuat file `firebase_options.dart`.
4. Pastikan Anda telah mengaktifkan **Authentication (Email/Password, Google)** dan **Cloud Messaging (FCM)** di Firebase Console.
5. Untuk **Google Sign-In di Android**, pastikan Anda telah menambahkan **SHA-1 certificate fingerprint** ke pengaturan proyek Firebase Anda. Anda bisa mendapatkannya dengan menjalankan:
   ```bash
   cd android && ./gradlew signingReport
   ```

### 3. Konfigurasi Environment

1. Buat file `.env` di root direktori proyek. Anda bisa menyalin dari contoh jika ada, atau buat baru.
2. Isi file `.env` dengan variabel yang dibutuhkan, terutama URL base dari backend API.
   ```env
   API_BASE_URL=http://localhost:8080/api/v1
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

### 6. Setup App Icon (Opsional)

Jika Anda ingin menggunakan icon kustom:

```bash
dart run flutter_launcher_icons
```

### 7. Jalankan Aplikasi

```bash
flutter run
```

Aplikasi akan berjalan di emulator/simulator atau perangkat yang terhubung.

## 🎯 Flow Aplikasi

### Alur Pengguna Utama:
1. **Onboarding** → **Splash Screen** → **Authentication**
2. **Home Dashboard** → Pilih kategori (Donasi/Rental/Thrifting)
3. **Browse Items** → **Item Detail** → **Create Request/Order**
4. **Payment** (untuk Rental & Thrifting) → **Order Tracking**
5. **History** untuk melihat semua transaksi
6. **Chat AI** untuk bantuan dan rekomendasi
7. **Profile Management** dan **Notifications**

### Tipe Request:
- **🎁 Donasi**: Gratis, hanya perlu approval dari mitra
- **👔 Rental**: Sewa dengan durasi tertentu, pembayaran via QRIS
- **🛍️ Thrifting**: Beli secondhand, pembayaran sekali via QRIS

## 🤝 Berkontribusi

Kami menyambut kontribusi dari siapa saja!

1. Fork repository ini.
2. Buat branch fitur baru (`git checkout -b feat/nama-fitur-keren`).
3. Lakukan perubahan dan commit (`git commit -m 'feat: Menambahkan fitur keren'`).
4. Push ke branch Anda (`git push origin feature/nama-fitur-keren`).
5. Buka sebuah Pull Request.

## 📝 Pesan Commit

Gunakan format _conventional commits_ untuk pesan commit yang rapi dan terstandar:

```
feat: Menambahkan kategori thrifting pada request
fix: Memperbaiki bug pada notifikasi push
docs: Memperbarui dokumentasi setup dengan kategori baru
refactor: Meningkatkan performa home page
style: Merapikan format kode pada widget profile
```

## 📄 Lisensi

Didistribusikan di bawah Lisensi MIT. Lihat file `LICENSE` untuk informasi lebih lanjut.

## 📞 Kontak

- **Email**: satulemariapp@gmail.com
- **Backend Repository**: [SatuLemari Backend](https://github.com/dzuura/satu-lemari)
- **Issues**: [GitHub Issues](https://github.com/rezaluthfi/satu-lemari-app/issues)

---

**SatuLemari** - "Satu Pakaian, Seribu Senyuman" 🌱👕💚
