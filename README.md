#  Rumah Sewa Biru Laut — Frontend

<div align="center">

**Aplikasi Frontend (Flutter Web) untuk Sistem Sewa Rumah Kos Biru Laut**

🟢 **Status**: Sedang Development | Terintegrasi dengan Laravel Backend

[🌐 Live Demo](https://rumahsewabl-fe.web.app) · [📋 Backend Repo](https://github.com/Mikhael-agung/RumahSewaBL-BE) · [⚙️ Setup](#️-setup--instalasi)

</div>

---

##  Informasi Project

| Field | Detail |
|---|---|
| **Project** | Rumah Sewa Biru Laut |
| **Platform** | Flutter Web (Mobile-ready) |
| **Backend** | Laravel 13 + JWT |
| **Database** | MySQL |
| **Deployment** | Firebase Hosting |

---

##  Alur Aplikasi

```mermaid
flowchart TD
    A[Login Screen] --> B{Role?}
    B -->|Penyewa| C[Home - Daftar Kamar]
    C --> D[Detail Kamar → Booking]
    D --> E[Payment Screen → Upload Bukti]
    E --> F[Backend Verifikasi]
    B -->|Manager / Admin| G[Admin Dashboard]
```

---

##  Flow Koneksi ke Backend

### Arsitektur Koneksi

```mermaid
flowchart LR
    A[Flutter App] --> B[Dio HTTP Client]
    B --> C[Request Interceptor]
    C --> D[Attach JWT Token]
    D --> E[Base URL /api]
    E --> F[Laravel Backend]
    F --> G[Response]
    G --> H[Response Interceptor]
    H --> A
```

### Cara Kerja

1. **Dio Instance (Singleton)** — dikelola di `lib/core/network/dio_client.dart`
2. **Request Interceptor** — otomatis attach `Authorization: Bearer <token>` + set `Content-Type: application/json`
3. **Response Interceptor** — handle error (401, 403, 422) dan refresh token logic
4. **Base URL** — dikelola terpusat di `lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  static const String baseUrl =
      'https://rumahsewabl-be-production.up.railway.app/api';

  // Auth
  static const String login   = '/login';
  static const String logout  = '/logout';

  // Payment
  static const String uploadPayment   = '/payments/upload';
  static const String paymentHistory  = '/payments/history';
  static const String pendingPayments = '/payments/pending';
}
```

---

### Sequence Diagram — Login Flow

```mermaid
sequenceDiagram
    participant User
    participant FlutterApp
    participant DioClient
    participant LaravelBE
    participant Database

    User->>FlutterApp: Masukkan email & password
    FlutterApp->>DioClient: POST /api/login
    DioClient->>LaravelBE: Request + JSON Body
    LaravelBE->>Database: Validasi user
    Database-->>LaravelBE: User data + role
    LaravelBE-->>DioClient: Response {token, user, role}
    DioClient-->>FlutterApp: Success
    FlutterApp->>FlutterApp: Simpan token ke Secure Storage
    FlutterApp-->>User: Login berhasil + Redirect Home
```

### Sequence Diagram — Upload Bukti Pembayaran

```mermaid
sequenceDiagram
    participant Penyewa
    participant FlutterApp
    participant DioClient
    participant LaravelBE
    participant Storage
    participant Database

    Penyewa->>FlutterApp: Pilih file bukti bayar
    FlutterApp->>DioClient: POST /api/payments/upload (multipart/form-data)
    DioClient->>LaravelBE: Kirim file + token
    LaravelBE->>LaravelBE: Validasi token & role
    LaravelBE->>Storage: Simpan file bukti
    LaravelBE->>Database: Simpan data payment
    LaravelBE-->>DioClient: Response {message, payment_id}
    DioClient-->>FlutterApp: Success
    FlutterApp-->>Penyewa: "Bukti berhasil diupload"
```

### Flow Authentication

```
User Login
  → Backend return: token + user data + role
  → Token disimpan di flutter_secure_storage
  → Setiap request protected auto-attach token
  → Jika 401 Unauthorized → Redirect ke Login Screen
```

---

## ⚙️ Setup & Instalasi

```bash
git clone https://github.com/Mikhael-agung/RumahSewaBL-FE.git
cd RumahSewaBL-FE

flutter pub get
flutter run -d chrome
```

> Ubah `baseUrl` sesuai environment (development/production) di `ApiConstants`.

---

## Struktur Folder

```
lib/
├── core/
│   ├── constants/       # ApiConstants, AppConstants
│   ├── network/         # Dio client + interceptors
│   ├── utils/
│   └── theme/
├── features/
│   ├── auth/
│   ├── payment/
│   ├── room/
│   └── admin/
├── shared/
└── main.dart
```

---

## Role & Akses

| Role | Fitur Utama |
|---|---|
| `penyewa` | Booking, Upload Bukti Bayar, Riwayat |
| `manager` | Verifikasi Pembayaran |
| `administrator` | Full Management |

---

##  Progress Development

### Sprint 1 — Minggu 10

- [x] Auth + JWT Integration
- [x] Payment Upload & History
- [x] Dio Client + Interceptor
- [x] Responsive UI

###  Next Sprint

- [ ] Booking System
- [ ] Admin Dashboard
- [ ] Notifikasi

---

<div align="center">

*Last updated: 24 Mei 2026*

</div>
