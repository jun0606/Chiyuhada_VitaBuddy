import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../l10n/app_localizations.dart';

/// 바코드 스캔 결과 모델
class BarcodeScanResult {
  final String rawValue;
  final BarcodeFormat format;
  final String formatDisplayName;
  final bool isValid;
  final int confidence; // 0-100
  final DateTime scannedAt;
  final int scanCount; // 동일 값이 몇 번 감지되었는지

  BarcodeScanResult({
    required this.rawValue,
    required this.format,
    required this.formatDisplayName,
    required this.isValid,
    required this.confidence,
    DateTime? scannedAt,
    this.scanCount = 1,
  }) : scannedAt = scannedAt ?? DateTime.now();

  String get displayValue => isValid ? rawValue : '유효하지 않은 바코드';

  /// 결과 복사 (일부 필드 변경)
  BarcodeScanResult copyWith({
    String? rawValue,
    BarcodeFormat? format,
    String? formatDisplayName,
    bool? isValid,
    int? confidence,
    DateTime? scannedAt,
    int? scanCount,
  }) {
    return BarcodeScanResult(
      rawValue: rawValue ?? this.rawValue,
      format: format ?? this.format,
      formatDisplayName: formatDisplayName ?? this.formatDisplayName,
      isValid: isValid ?? this.isValid,
      confidence: confidence ?? this.confidence,
      scannedAt: scannedAt ?? this.scannedAt,
      scanCount: scanCount ?? this.scanCount,
    );
  }

  @override
  String toString() {
    return 'BarcodeScanResult(value: $rawValue, format: $formatDisplayName, valid: $isValid, confidence: $confidence%)';
  }
}

/// 바코드 검증 유틸리티 클래스
class BarcodeValidator {
  /// 바코드 검증 및 결과 생성
  static BarcodeScanResult validateBarcode(Barcode barcode) {
    final rawValue = barcode.rawValue ?? '';
    final format = barcode.format;

    final displayName = _getFormatDisplayName(format);
    final isValid = _validateByFormat(rawValue, format);
    final confidence = _calculateConfidence(barcode, isValid);

    return BarcodeScanResult(
      rawValue: rawValue,
      format: format,
      formatDisplayName: displayName,
      isValid: isValid,
      confidence: confidence,
    );
  }

  /// 포맷별 검증 로직
  static bool _validateByFormat(String value, BarcodeFormat format) {
    if (value.isEmpty) return false;

    switch (format) {
      case BarcodeFormat.ean13:
        return _validateEAN13(value);
      case BarcodeFormat.ean8:
        return _validateEAN8(value);
      case BarcodeFormat.upca:
        return _validateUPCA(value);
      case BarcodeFormat.upce:
        return _validateUPCE(value);
      case BarcodeFormat.qrCode:
        return _validateQRCode(value);
      case BarcodeFormat.code128:
        return _validateCode128(value);
      case BarcodeFormat.code39:
        return _validateCode39(value);
      default:
        // 기타 포맷은 체크섬 정보가 없는 경우가 많으므로 길이만 확인 (대신 인식 신뢰도는 낮음)
        return value.length >= 5;
    }
  }

  /// EAN-13 검증 (13자리 숫자 + 체크섬)
  static bool _validateEAN13(String value) {
    if (value.length != 13 || !RegExp(r'^\d{13}$').hasMatch(value)) {
      return false;
    }

    // 체크섬 계산
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(value[i]);
      sum += digit * (i % 2 == 0 ? 1 : 3);
    }

    int checksum = (10 - (sum % 10)) % 10;
    int actualChecksum = int.parse(value[12]);

    return checksum == actualChecksum;
  }

  /// EAN-8 검증 (8자리 숫자 + 체크섬)
  static bool _validateEAN8(String value) {
    if (value.length != 8 || !RegExp(r'^\d{8}$').hasMatch(value)) {
      return false;
    }

    // 체크섬 계산 (EAN-13과 동일한 로직)
    int sum = 0;
    for (int i = 0; i < 7; i++) {
      int digit = int.parse(value[i]);
      sum += digit * (i % 2 == 0 ? 3 : 1);
    }

    int checksum = (10 - (sum % 10)) % 10;
    int actualChecksum = int.parse(value[7]);

    return checksum == actualChecksum;
  }

  /// UPC-A 검증 (12자리 숫자, 실제로는 11+체크섬)
  static bool _validateUPCA(String value) {
    if (value.length != 12 || !RegExp(r'^\d{12}$').hasMatch(value)) {
      return false;
    }

    // UPC-A 체크섬 검증
    int sum = 0;
    for (int i = 0; i < 11; i++) {
      int digit = int.parse(value[i]);
      sum += digit * (i % 2 == 0 ? 3 : 1);
    }

    int checksum = (10 - (sum % 10)) % 10;
    int actualChecksum = int.parse(value[11]);

    return checksum == actualChecksum;
  }

  /// UPC-E 검증 (8자리 압축 형태)
  static bool _validateUPCE(String value) {
    // UPC-E는 복잡한 변환 로직이 필요하므로 기본 검증만 수행
    return value.length == 8 && RegExp(r'^\d{8}$').hasMatch(value);
  }

  /// QR 코드 기본 검증
  static bool _validateQRCode(String value) {
    // QR 코드는 다양한 데이터 타입을 포함할 수 있으므로 기본 검증
    return value.length >= 3;
  }

  /// Code 128 검증
  static bool _validateCode128(String value) {
    // Code 128은 다양한 문자 지원, 기본 길이 검증
    return value.length >= 1;
  }

  /// Code 39 검증
  static bool _validateCode39(String value) {
    // Code 39은 대문자, 숫자, 일부 특수문자 지원
    return RegExp(r'^[A-Z0-9\-\.\$\/\+%\*\s]+$').hasMatch(value);
  }

  /// 신뢰도 계산
  static int _calculateConfidence(Barcode barcode, bool isValid) {
    int confidence = 40; // 기본 신뢰도 하향

    // 유효성 검증 통과 (체크섬 등)
    if (isValid) {
      confidence += 40;
    } else {
      // 검증 실패해도 포맷이 감지되면 어느 정도 신뢰 부여
      confidence += 10;
    }

    // 값 길이 (일반적인 바코드 길이 8~13자)
    final length = barcode.rawValue?.length ?? 0;
    if (length >= 8 && length <= 13) {
      confidence += 20;
    } else if (length >= 3) {
      confidence += 5;
    }

    return confidence.clamp(0, 100);
  }

  /// 포맷 표시명 변환 (번역 키 반환)
  static String _getFormatDisplayName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.ean13:
        return 'barcodeFormatEan13';
      case BarcodeFormat.ean8:
        return 'barcodeFormatEan8';
      case BarcodeFormat.upca:
        return 'barcodeFormatUpca';
      case BarcodeFormat.upce:
        return 'barcodeFormatUpce';
      case BarcodeFormat.qrCode:
        return 'barcodeFormatQrCode';
      case BarcodeFormat.code128:
        return 'barcodeFormatCode128';
      case BarcodeFormat.code39:
        return 'barcodeFormatCode39';
      case BarcodeFormat.code93:
        return 'barcodeFormatCode93';
      case BarcodeFormat.codabar:
        return 'barcodeFormatCodabar';
      case BarcodeFormat.itf:
        return 'barcodeFormatItf';
      case BarcodeFormat.aztec:
        return 'barcodeFormatAztec';
      case BarcodeFormat.dataMatrix:
        return 'barcodeFormatDataMatrix';
      case BarcodeFormat.pdf417:
        return 'barcodeFormatPdf417';
      default:
        return 'barcodeFormatUnknown';
    }
  }
}
