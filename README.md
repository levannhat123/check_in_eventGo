# Check-in QR App

Ứng dụng Flutter hỗ trợ đăng nhập nhân sự và check-in vé sự kiện bằng QR, tích hợp Firebase + Supabase, tổ chức theo hướng Clean Architecture để dễ mở rộng và bảo trì.

## Demo Scope

- Đăng nhập tài khoản nhân sự (staff/admin logic theo role).
- Hiển thị danh sách sự kiện và thống kê vé đã bán.
- Quét mã QR để check-in vé theo sự kiện.
- Kiểm tra điều kiện vé: đúng sự kiện, trạng thái thanh toán, thời gian diễn ra, số lượt check-in còn lại.
- Cập nhật check-in theo số lượng còn lại.

## Tech Stack

- **Framework**: Flutter (Dart 3)
- **State Management**: `provider`
- **Routing**: `go_router`
- **Dependency Injection**: `get_it`
- **Backend/Services**:
  - `cloud_firestore` (event, order, ticket data)
  - `supabase_flutter` (auth/profile/storage)
- **Utilities**: `intl`, `mobile_scanner`, `image_picker`, `shared_preferences`
- **Codegen/Modeling**: `freezed`, `json_serializable`, `build_runner`

## Architecture

Project được chia lớp rõ ràng để thể hiện tư duy Fresher chuẩn:

- `core/`: constants, base classes, config, reusable widgets/utils
- `data/`: model + repository implementation
- `domain/`: entity/usecase/business rules
- `presentation/`: pages + view models
- `routers/`: điều hướng app
- `injection/`: đăng ký dependency tập trung

### Cấu trúc thư mục

```text
lib/
  core/
    base/
    config/
    constants/
    utils/
    widgets/
  data/
    models/
    repositories/
  domain/
    entities/
    usecase/
    utils/
  presentation/
    pages/
      auth/
      home/
    view_models/
  routers/
  injection/
  main.dart
```

## Điểm nhấn kỹ thuật

- Chuẩn hóa constants để tránh hard-code:
  - `AppStrings`, `AppColors`, `AppSizes`, `AppSpacing`, `AppStorageKey`.
- Tách business logic khỏi UI bằng ViewModel + UseCase.
- Tối ưu chất lượng code:
  - `dart format`, `dart fix`, lint sạch.
  - `flutter analyze` không lỗi.
  - test smoke chạy pass.

## Yêu cầu môi trường

- Flutter SDK `>=3.32.x` (khuyến nghị cùng version trong máy dev)
- Dart SDK theo Flutter
- Xcode / Android Studio (tùy nền tảng chạy)
- Tài khoản Firebase + Supabase

## Cấu hình trước khi chạy

1. **Firebase**
   - File `lib/firebase_options.dart` đã tồn tại.
   - Nếu đổi project Firebase, chạy lại FlutterFire CLI để regenerate file này.

2. **Supabase (.env với flutter_dotenv)**
   - Không lưu key trực tiếp trong source code.
   - Tạo file `.env` từ `.env.example`:
     - `SUPABASE_URL`
     - `SUPABASE_ANON_KEY`

3. **Firestore/Supabase schema**
   - Bảo đảm các collection/table và field đúng theo constants trong `lib/core/constants/app_storage_key.dart`.

## Cài đặt & chạy local

```bash
cp .env.example .env
# cập nhật giá trị thật trong file .env

flutter pub get
flutter analyze
flutter test
flutter run
```

## Build

```bash
# Android APK
flutter build apk --release

# iOS (trên macOS)
flutter build ios --release
```

## Lệnh hữu ích khi phát triển

```bash
# Format toàn bộ code
dart format lib test

# Auto-fix lint phổ biến
dart fix --apply

# Generate model/code từ freezed/json
flutter pub run build_runner build --delete-conflicting-outputs
```

## Routing hiện tại

- `/login`: màn hình đăng nhập
- `/home`: dashboard sự kiện + thống kê
- `/check_in`: màn hình quét QR theo `eventId`

## Quality Checklist (CV-ready)

- [x] Cấu trúc thư mục rõ theo tầng.
- [x] Không hard-code key/value quan trọng (gom vào constants).
- [x] Code format đồng nhất.
- [x] `flutter analyze` pass.
- [x] `flutter test` pass.



