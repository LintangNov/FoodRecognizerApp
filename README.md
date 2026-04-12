# Food Recognizer App

Aplikasi Flutter berbasis Machine Learning yang mampu mengidentifikasi jenis makanan melalui kamera atau galeri, serta menyajikan informasi nutrisi menggunakan integrasi Gemini AI. Proyek ini merupakan bagian dari kurikulum pembelajaran **Expert Multi-Platform AI App Development IDCamp 2025 & Dicoding Indonesia**.

## Fitur Utama
- **Food Classification**: Klasifikasi jenis makanan lokal menggunakan model TFLite (Food-Classifier).
- **Nutrition Insight**: Mendapatkan detail kalori dan kandungan gizi melalui Gemini API.
- **Optimized Inference**: Proses analisis dengan teknik multi-threading dan image-processing pada Isolate.
- **Cloud Model Management**: Sinkronisasi model TFLite menggunakan Firebase ML.

## Tech Stack
- **Framework**: Flutter
- **AI/ML**: TensorFlow Lite (tflite_flutter), Firebase ML.
- **Generative AI**: Google Gemini API.
- **Security**: Envied (API Key Obfuscation).

## 📝 Catatan Pengembangan
- Android SDK: Dikompilasi menggunakan Android SDK 36.

- Java Version: Membutuhkan JDK 17 untuk kompatibilitas Gradle yang stabil.

- Optimasi: Implementasi resizing gambar ke 224x224 dan normalisasi piksel dilakukan untuk memastikan performa maksimal pada perangkat mobile.

---

## Untuk Reviewer

Demi keamanan, file `.env` dan file hasil *generate* `env.g.dart` **sengaja tidak disertakan** dalam repositori ini (masuk dalam `.gitignore`). Ikuti langkah berikut untuk menjalankan aplikasi:

### 1. Persiapan API Key
Buat file bernama `.env` di folder utama proyek (sejajar dengan `pubspec.yaml`), lalu isi dengan:

GEMINI_API_KEY=MASUKKAN_API_

### 2. Generate Code
Jalankan perintah berikut di terminal untuk men-generate file env.g.dart secara otomatis:
```
Bash
flutter pub get
dart run build_runner build -d
```

### 3. Jalankan Aplikasi
```
Bash
flutter run
