# VitaBuddy (치유하다 VitaBuddy)

> **모바일 다이어트 헬스케어 앱**  
> BMI 기반 아바타 시각화로 즐겁게 다이어트하세요!

---

## 📱 지원 플랫폼

| 플랫폼 | 상태 | 최소 버전 |
|--------|------|----------|
| **Android** | ✅ 지원 | Android 8.0+ |
| **iOS** | ✅ 지원 | iOS 12.0+ |
| Web/Windows/macOS/Linux | ❌ 미지원 | - |

> **참고**: 자세한 플랫폼 정책은 [platform_policy.md](./docs/platform_policy.md)를 참조하세요.

---

## 🎯 주요 기능

- 🧍 **BMI 기반 아바타 시각화**: 실시간으로 변화하는 나만의 아바타
- 🍽️ **식사 칼로리 추적**: 간편한 음식 입력 및 칼로리 계산
- 📊 **체중 기록 및 차트**: 시각적인 진행 상황 추적
- 🏃 **운동 기록 시스템**: 
  - **자동 기록**: Android Health Connect 및 iOS HealthKit 연동
  - **수동 기록**: 12가지 운동 모드 및 MET 기반 칼로리 자동 계산
  - **순 칼로리**: 섭취량과 소모량을 계산하여 '순 칼로리(Net Calories)' 관리
- 🔔 **알림 시스템**: 체중 체크 리마인더 및 동기부여 메시지

---

## 🛠️ 기술 스택

- **Framework**: Flutter 3.9.0+
- **State Management**: Provider
- **Database**: Hive + SQLite
- **Health Integration**: health, workmanager
- **Animation**: Flame Engine
- **Charts**: FL Chart

---

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK 3.9.0 이상
- Android Studio (Android 개발)
- Xcode (iOS 개발, macOS 전용)

### 헬스 데이터 연동 설정

#### Android
- **Health Connect** 앱 설치가 필요합니다 (Android 14 미만).
- 앱 실행 시 '걸음 수', '소모 칼로리', '운동' 권한을 허용해야 합니다.

#### iOS
- **건강(Health)** 앱 접근 권한이 필요합니다.
- `Info.plist`에 권한 설명이 포함되어 있습니다.

### 설치 및 실행

```bash
# 저장소 클론
git clone <repository-url>
cd Chiyuhada_VitaBuddy

# 의존성 설치
flutter pub get

# Hive 모델 생성
flutter packages pub run build_runner build

# Android 실행
flutter run -d <android-device>

# iOS 실행 (macOS에서만 가능)
flutter run -d <ios-device>
```

### 개발 환경 (Windows에서 개발하는 경우)

```bash
# Windows에서 UI 테스트 (개발 전용)
flutter run -d windows
```

> **중요**: Windows 빌드는 개발/테스트 전용이며, 실제 배포는 Android/iOS만 진행합니다.
> **참고**: 헬스 데이터 연동 기능은 실제 모바일 기기에서만 동작합니다.

---

## 📁 프로젝트 구조

```
lib/
├── avatar/          # 아바타 시스템
├── models/          # 데이터 모델
├── providers/       # 상태 관리
├── screens/         # 화면
├── services/        # 비즈니스 로직
│   ├── health_data_service.dart       # 헬스 데이터 연동
│   └── background_calorie_service.dart # 백그라운드 동기화
└── widgets/         # 재사용 위젯
```

---

## 📖 문서

- [개발 진행도 보고서](./docs/vitabuddy_development_status.md)
- [플랫폼 지원 정책](./docs/platform_policy.md)
- [구현 계획](./docs/implementation_plan.md)
- [운동 기록 시스템 작업 내역](./exercise_tracking_tasks.md)

---

## 🤝 기여하기

현재 개발 중인 프로젝트입니다. 기여 가이드라인은 추후 제공될 예정입니다.

---

## 📄 라이선스

이 프로젝트의 라이선스 정보는 추후 제공될 예정입니다.

---

## 📞 문의

프로젝트 관련 문의사항이 있으시면 이슈를 생성해주세요.

---

**개발 상태**: 🚧 진행 중 (85% 완료)  
**최종 업데이트**: 2025-11-26
