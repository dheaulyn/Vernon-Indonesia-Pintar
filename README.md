# 🎓 Website Yayasan Vernon Indonesia Pintar

Proyek ini adalah *website company profile* dan portal informasi resmi untuk Yayasan Vernon Indonesia Pintar. Dibangun menggunakan **Flutter Web** dengan integrasi **Supabase** sebagai *backend* dan *Database as a Service* (DBaaS) untuk kebutuhan *Content Management System* (CMS).

---

## 🚀 Fitur Utama

Aplikasi ini dibagi menjadi dua bagian utama: **User View (Halaman Publik)** dan **Admin Dashboard (CMS)**.

### 🌟 Halaman Publik (User View)
*   **Beranda Dinamis (Hero Section):** Menampilkan *banner* dan informasi utama yang datanya mengalir langsung (*stream*) dari *database*.
*   **Informasi Program Kurikulum:** Menampilkan daftar program pembelajaran yang aktif secara dinamis.
*   **Testimoni Responsif:** Menampilkan ulasan alumni dengan antarmuka grid kotak yang rapi dan responsif.
*   **Statistik Yayasan:** Menampilkan angka *Batch Aktif* dan *Total Alumni* secara *real-time* yang ditarik dari konfigurasi Environment.

### 🔐 Admin Dashboard (Content Management System)
Sistem memiliki dua level akses (Role-Based Access Control) untuk menjaga keamanan data:
1.  **Super Admin:**
    *   Memiliki akses penuh ke seluruh sistem.
    *   Bisa menambah, mengedit, dan menghapus akun Admin baru.
    *   Bisa mengubah semua konfigurasi dan konten aplikasi.
2.  **Admin Biasa:**
    *   Akses terbatas hanya pada manajemen konten.
    *   Bisa menambah, mengedit, dan mengelola data Program, Hero, dan Testimoni.

---

## 🛠️ Tech Stack & Dependencies

*   **Framework Frontend:** Flutter SDK (Web Target)
*   **Bahasa Pemrograman:** Dart
*   **Backend & Database:** Supabase (PostgreSQL, Authentication, Storage)
*   **Environment Management:** flutter_dotenv

---

## ⚙️ Persyaratan Sistem (Prerequisites)

Sebelum menjalankan proyek ini, pastikan sistem komputermu sudah terpasang:
*   Flutter SDK (versi terbaru)
*   Web Browser (Google Chrome disarankan untuk proses *debugging*)
*   Visual Studio Code (atau IDE pilihanmu)

---

## 💻 Cara Instalasi & Menjalankan Proyek (Local Setup)

Ikuti langkah-langkah di bawah ini untuk menjalankan proyek secara lokal di komputermu:

### 1. Clone Repositori
Clone repositori ini dari Github ke komputer lokal kamu.

```bash
git clone [https://github.com/ThunderID/Website-YayasanVIP.git](https://github.com/ThunderID/Website-YayasanVIP.git)
cd Website-YayasanVIP
```

### 2. Install Package/Dependencies
Unduh semua *library* pendukung yang dibutuhkan aplikasi.

```bash
flutter pub get
```

### 3. Konfigurasi Environment Variables (.env) ⚠️ PENTING
Aplikasi ini membutuhkan konfigurasi API dan data yayasan agar dapat berjalan.
1. Cari file bernama `.env.example` di dalam folder utama proyek.
2. *Copy* atau duplikat file tersebut, lalu ubah nama hasil duplikatnya menjadi `.env`.
3. Buka file `.env` dan lengkapi datanya seperti di bawah ini:

```text
# --- Supabase Konfigurasi ---
# Minta kredensial asli kepada Super Admin / Lead Developer
SUPABASE_URL=https://[PROJECT-ID].supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```

> **Catatan Keamanan:** File `.env` sudah dimasukkan ke dalam `.gitignore`. JANGAN PERNAH melakukan commit file `.env` yang berisi kredensial asli ke dalam repositori Github!

### 4. Jalankan Aplikasi
Jalankan aplikasi dengan target *browser* Chrome.

```bash
flutter run -d chrome
```