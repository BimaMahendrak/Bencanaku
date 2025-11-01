# 🚨 BencanaKu - Aplikasi Monitoring dan Peringatan Bencana Indonesia 🌊

**BencanaKu** adalah aplikasi mobile cross-platform yang dibangun dengan Flutter untuk menyediakan informasi gempa bumi terkini (bersumber dari BMKG) dan fitur peringatan darurat berbasis sensor bagi pengguna di Indonesia.

## ✨ Fitur Utama (Main Features)

* **Monitoring Gempa Bumi Terkini:** Menampilkan data gempa bumi terbaru (Magnitude, Kedalaman, Wilayah, Potensi) yang bersumber dari API BMKG.
* **Visualisasi Peta Interaktif:** Menampilkan lokasi episentrum gempa dan posisi pengguna pada peta interaktif (`flutter_map`).
* **Statistik Gempa Mingguan:** Menyajikan rekapitulasi jumlah dan klasifikasi gempa yang terjadi dalam 7 hari terakhir.
* **Emergency Alert Berbasis Sensor:** Memicu peringatan darurat secara otomatis ketika perangkat terdeteksi miring (misalnya, terjatuh) selama durasi tertentu menggunakan sensor akselerometer (`sensors_plus`).
* **Aksi Cepat Darurat:** Menyediakan tombol cepat untuk **Berbagi Lokasi** darurat melalui aplikasi lain (`share_plus`) dan **Panggilan Emergency** ke nomor 112 (`url_launcher`).
* **Notifikasi Push:** Mengirim notifikasi penting dan pengingat evakuasi menggunakan `awesome_notifications`.
* **Konversi Mata Uang:** Fitur utilitas untuk konversi cepat antara IDR, USD, dan MYR menggunakan API pihak ketiga.
* **Autentikasi & Profil:** Sistem login, register, edit profil, dan upload foto profil menggunakan layanan backend khusus.

---

## 🛠️ Teknologi yang Digunakan

| Kategori | Teknologi | Keterangan |
| :--- | :--- | :--- |
| **Framework** | **Flutter** (Dart) | Untuk pengembangan aplikasi multi-platform. |
| **Navigation** | `go_router` | Untuk routing yang deklaratif. |
| **Networking** | `http` | Untuk semua komunikasi API eksternal. |
| **Maps & Lokasi** | `flutter_map`, `geolocator`, `geocoding` | Menampilkan peta dan mendapatkan lokasi akurat pengguna. |
| **Sensors** | `sensors_plus` | Untuk deteksi kemiringan perangkat (Emergency Alert). |
| **Notifikasi** | `awesome_notifications` | Untuk notifikasi push darurat. |
| **Utilitas** | `intl`, `timezone`, `share_plus` | Untuk manajemen waktu, timezone, dan fitur berbagi. |

---

## 🌐 Integrasi API Eksternal

Aplikasi BencanaKu mengandalkan beberapa layanan web eksternal untuk mendapatkan data *real-time* dan fitur inti:

| Nama API | Fungsi | Endpoint Utama | Sumber File |
| :--- | :--- | :--- | :--- |
| **BMKG Gempaterkini** | Menyediakan data gempa bumi terkini dan arsip gempa. | `https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json` | `lib/controller/homeController.dart` |
| **Nominatim (OpenStreetMap)** | Melakukan *Reverse Geocoding* untuk mendapatkan nama kota/wilayah dari koordinat GPS pengguna. | `https://nominatim.openstreetmap.org/reverse` | `lib/controller/homeController.dart` |
| **ExchangeRate-API** | Menyediakan nilai tukar mata uang dunia untuk fitur konversi. | `https://api.exchangerate-api.com/v4/latest/{baseCurrency}` | `lib/services/currencyService.dart` |
| **Monitoring Web (Backend Internal)** | Digunakan untuk autentikasi pengguna (Login/Register), mengambil data profil, dan mengelola upload foto profil. | `https://monitoringweb.decoratics.id/api/bencana/...` | `lib/controller/loginController.dart`, `lib/controller/profileController.dart`, `lib/controller/registerController.dart` |

---

## 🚀 Prasyarat Instalasi (Installation Prerequisites)

Sebelum menjalankan project ini, pastikan Anda telah menginstal:

* **Flutter SDK**: Versi stabil (disarankan versi terbaru, minimum Dart `3.9.2` dan Flutter `3.35.0`).
* **Android Studio** / **Xcode**: Untuk build aplikasi native (Android/iOS).
* **Koneksi Internet**: Diperlukan untuk mengambil dependencies dan data API.

### Konfigurasi Khusus (Android)

Pastikan file `android/app/src/main/AndroidManifest.xml` menyertakan izin yang diperlukan untuk lokasi, telepon, dan notifikasi:

```xml
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    <uses-permission android:name="android.permission.CALL_PHONE" />
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## 📁 Struktur Project

Struktur direktori inti pada folder lib adalah sebagai berikut:

```
.
├── lib/
│   ├── Auntentikasi/         # UI untuk Login dan Register
│   │   ├── login.dart
│   │   └── register.dart
│   ├── Landing/              # Halaman utama aplikasi (Home, Profile, Emergency, Currency)
│   │   ├── home.dart
│   │   ├── emergency.dart
│   │   ├── profile.dart
│   │   ├── currency.dart
│   │   └── widgets/
│   ├── controller/           # Business logic dan state management (menggunakan ValueNotifier)
│   │   ├── homeController.dart
│   │   ├── emergencyController.dart
│   │   └── ... (Controller lainnya)
│   ├── services/             # Integrasi eksternal (API, Notifikasi, Session)
│   │   ├── notificationService.dart
│   │   ├── sessionService.dart
│   │   └── ... (Service lainnya)
│   ├── utils/                # Utility classes (misalnya timezoneHelper.dart)
│   ├── router/               # Konfigurasi navigasi (appRouter.dart)
│   └── main.dart             # Titik masuk aplikasi (main function)
├── assets/
│   ├── data/                 # Data statis (e.g., BKMG_data.json)
│   └── images/               # Aset gambar dan logo
└── ... (folder konfigurasi platform: android, ios, web, dll.)
```
---
## 🤝 Kontribusi

Kami menyambut kontribusi dari komunitas! Untuk berkontribusi:

### 1. Fork Repository
```bash
git fork https://github.com/yourusername/bencanaku.git
```

### 2. Create Feature Branch
```bash
git checkout -b feature/amazing-feature
```

### 3. Commit Changes
```bash
git commit -m 'Add: amazing feature'
```

### 4. Push to Branch
```bash
git push origin feature/amazing-feature
```

### 5. Create Pull Request
Buat Pull Request dengan deskripsi detail tentang perubahan yang dilakukan.
