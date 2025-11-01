# API Documentation - Aplikasi Bencana

Dokumentasi ini menyediakan detail tentang endpoint API yang tersedia untuk modul Pengguna.

## Base URL

Semua URL yang dirujuk dalam dokumentasi ini menggunakan base URL berikut:
`http://<your-domain>/api/bencana`

---

## Endpoints Overview

### 1. Registrasi Pengguna Baru
Mendaftarkan pengguna baru ke dalam sistem.

- **Method**: `POST`
- **Endpoint**: `/pengguna`
- **Body Request**:
  ```json
  {
      "nama_lengkap": "Bima Sakti",
      "username": "bimasakti",
      "password": "password123"
  }
  ```
- **Success Response (201 Created)**:
  ```json
  {
      "nama_lengkap": "Bima Sakti",
      "username": "bimasakti",
      "updated_at": "2025-11-01T10:00:00.000000Z",
      "created_at": "2025-11-01T10:00:00.000000Z",
      "id": 1
  }
  ```

### 2. Login Pengguna
Mengautentikasi pengguna dan memberikan akses.

- **Method**: `POST`
- **Endpoint**: `/pengguna/login`
- **Body Request**:
  ```json
  {
      "username": "bimasakti",
      "password": "password123"
  }
  ```
- **Success Response (200 OK)**:
  ```json
  {
      "id": 1,
      "nama_lengkap": "Bima Sakti",
      "username": "bimasakti",
      "url_foto": null,
      "created_at": "2025-11-01T10:00:00.000000Z",
      "updated_at": "2025-11-01T10:00:00.000000Z"
  }
  ```
- **Error Response (401 Unauthorized)**:
  ```json
  {
      "message": "Username atau password salah"
  }
  ```

### 3. Mendapatkan Semua Pengguna
Mengambil daftar semua pengguna yang terdaftar.

- **Method**: `GET`
- **Endpoint**: `/pengguna`
- **Success Response (200 OK)**:
  ```json
  [
      {
          "id": 1,
          "nama_lengkap": "Bima Sakti",
          "username": "bimasakti",
          "url_foto": null,
          "created_at": "2025-11-01T10:00:00.000000Z",
          "updated_at": "2025-11-01T10:00:00.000000Z"
      },
      {
          "id": 2,
          "nama_lengkap": "Admin User",
          "username": "admin",
          "url_foto": null,
          "created_at": "2025-11-01T10:01:00.000000Z",
          "updated_at": "2025-11-01T10:01:00.000000Z"
      }
  ]
  ```

### 4. Mendapatkan Detail Pengguna
Mengambil informasi detail dari satu pengguna berdasarkan ID.

- **Method**: `GET`
- **Endpoint**: `/pengguna/{id}`
- **Success Response (200 OK)**:
  ```json
  {
      "id": 1,
      "nama_lengkap": "Bima Sakti",
      "username": "bimasakti",
      "url_foto": null,
      "created_at": "2025-11-01T10:00:00.000000Z",
      "updated_at": "2025-11-01T10:00:00.000000Z"
  }
  ```

### 5. Memperbarui Data Pengguna
Memperbarui data pengguna yang ada.

- **Method**: `PUT` / `PATCH`
- **Endpoint**: `/pengguna/{id}`
- **Body Request**:
  ```json
  {
      "nama_lengkap": "Bima Sakti Updated"
  }
  ```
- **Success Response (200 OK)**:
  ```json
  {
      "id": 1,
      "nama_lengkap": "Bima Sakti Updated",
      "username": "bimasakti",
      "url_foto": null,
      "created_at": "2025-11-01T10:00:00.000000Z",
      "updated_at": "2025-11-01T10:05:00.000000Z"
  }
  ```

### 6. Menghapus Pengguna
Menghapus pengguna dari sistem.

- **Method**: `DELETE`
- **Endpoint**: `/pengguna/{id}`
- **Success Response (200 OK)**:
  ```json
  {
      "message": "Pengguna deleted successfully"
  }
  ```

### 7. Upload Foto Profil
Mengunggah atau memperbarui foto profil pengguna.

- **Method**: `POST`
- **Endpoint**: `/pengguna/{id}/upload-photo`
- **Body Request**: `multipart/form-data`
  - **key**: `photo`
  - **value**: `[file gambar: jpg, jpeg, png]`
- **Success Response (200 OK)**:
  ```json
  {
      "message": "Photo uploaded successfully",
      "photo_url": "http://<your-domain>/storage/photos/profile_1_1667304300.png",
      "user": {
          "id": 1,
          "nama_lengkap": "Bima Sakti",
          "username": "bimasakti",
          "url_foto": "http://<your-domain>/storage/photos/profile_1_1667304300.png",
          "created_at": "2025-11-01T10:00:00.000000Z",
          "updated_at": "2025-11-01T10:05:00.000000Z"
      }
  }
  ```

---

## Status Code Reference

- `200 OK`: Permintaan berhasil.
- `201 Created`: Sumber daya berhasil dibuat.
- `400 Bad Request`: Permintaan tidak valid (misalnya, file tidak dikirim).
- `401 Unauthorized`: Autentikasi gagal (username/password salah).
- `404 Not Found`: Sumber daya yang diminta tidak ditemukan.
- `422 Unprocessable Entity`: Validasi data gagal (misalnya, field kosong atau format salah).
- `500 Internal Server Error`: Terjadi kesalahan pada server.

---

## Panduan Cepat Testing

1.  **Registrasi**: Gunakan endpoint `POST /pengguna` untuk membuat akun baru.
2.  **Login**: Gunakan endpoint `POST /pengguna/login` dengan username dan password yang baru dibuat.
3.  **Upload Foto**: Gunakan endpoint `POST /pengguna/{id}/upload-photo` dengan ID pengguna dari respons login untuk mengunggah foto profil.
4.  **Lihat Data**: Gunakan endpoint `GET /pengguna` atau `GET /pengguna/{id}` untuk memeriksa data.
