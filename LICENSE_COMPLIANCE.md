# 라이선스 준수 문서
## 음식 검색 기능 라이선스 분석 및 준수 방안

### 1. Open Food Facts API
- **라이선스**: Open Database License (ODbL) v1.0 + Database Contents License (DbCL) v1.0
- **사용 조건**:
  - 데이터베이스 사용 시 출처 표시 필수
  - 데이터베이스 내용은 저작권 라이선스 부여 (상업적 사용 허용)
  - 파생 데이터베이스 생성 시 동일 라이선스로 배포
- **준수 방안**:
  - 앱 내 모든 검색 결과에 "Data from Open Food Facts" 표시
  - 데이터를 로컬에 캐시하되, 출처 정보 함께 저장
  - 데이터 재배포 또는 공유 금지

### 2. USDA FoodData Central API
- **라이선스**: Public Domain (US Government Work)
- **사용 조건**:
  - 저작권 없음, 라이선스 제한 없음
  - 출처 표시 권장 (강제 아님)
  - API 키 필요 (무료 발급)
  - Rate Limit: 1,000 requests/hour
- **준수 방안**:
  - 앱 내 검색 결과에 "Data from USDA FoodData Central" 표시 (권장)
  - 데이터 자유로운 로컬 저장 및 사용

### 3. Google ML Kit Barcode Scanning
- **라이선스**: Apache 2.0
- **사용 조건**:
  - 무료 오픈소스 라이선스
  - 상업적 사용 허용
  - Google ML Kit 무료 티어 사용 (1,000회/월)
- **준수 방안**:
  - 패키지 라이선스 준수 (소스 코드 표시 불필요)

### 4. 구현 시 준수사항
- **출처 표시**: 각 API별로 적절한 출처 표시
- **데이터 저장**: 개인 사용 범위 내 캐시 허용
- **프라이버시 정책**: 데이터 출처 명시
- **사용자 동의**: 선택적 기능으로 구현

### 5. 위험 관리
- **라이선스 변경**: 정기적 라이선스 검토
- **API 변경**: 폴백 시스템 구축
- **법적 검토**: 필요 시 전문가 상담

### 6. 문의처
- Open Food Facts: legal@openfoodfacts.org
- USDA FDC: https://fdc.nal.usda.gov/contact-us
- Google ML Kit: https://developers.google.com/ml-kit

최종 업데이트: 2026년 1월 6일
