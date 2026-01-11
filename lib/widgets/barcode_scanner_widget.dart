import 'dart:async';
import 'package:flutter/foundation.dart'; // kDebugMode 추가
import 'package:flutter/services.dart'; // HapticFeedback 추가

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/barcode_result.dart';
import '../l10n/app_localizations.dart';

/// 바코드 스캔을 위한 위젯
/// Camera 패키지 + Google ML Kit Barcode Scanning을 사용
class BarcodeScannerWidget extends StatefulWidget {
  final Future<void> Function(String) onBarcodeDetected;
  final VoidCallback onClose;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    required this.onClose,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner(); // 모든 포맷 지원
  bool _isInitialized = false; // 카메라 초기화 완료

  bool _hasPermission = false;
  bool _hasDetectedBarcode = false; // 바코드 감지 성공
  bool _hasCompletedScan = false; // 스캔 완료 상태 (중복 방지)
  String? _detectedBarcode; // 감지된 바코드 값
  final Map<String, int> _scanFrequency = {}; // 값 → 빈도수 (일관성 보장용)
  BarcodeScanResult? _stableResult; // 안정화된 결과
  DateTime? _lastDetectionTime;
  static const _shortCooldown = Duration(milliseconds: 500); // 짧은 쿨다운 (0.5초)
  static const _minConsistentScans = 3; // 일반 바코드용 최소 일치 수
  static const _minInvalidConsistentScans = 10; // 체크섬 오류 바코드용 (더 엄격함)
  bool _isFlashOn = false; // 플래시 상태
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // 카메라 권한 확인
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _hasPermission = false;
          _errorMessage =
              AppLocalizations.of(context)?.cameraPermissionRequired ??
              '카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
        });
        return;
      }

      setState(() => _hasPermission = true);

      // 사용 가능한 카메라 가져오기
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage =
              AppLocalizations.of(context)?.noCameraAvailable ??
              '사용 가능한 카메라가 없습니다.';
        });
        return;
      }

      // 후면 카메라 선택 (기본값)
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // 카메라 컨트롤러 초기화
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high, // High 해상도로 작은 바코드 인식률 향상
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, // ML Kit 최적화 포맷
      );

      await _cameraController!.initialize();

      // 이미지 스트림 리스너 설정 (실시간 바코드 인식)
      _cameraController!.startImageStream(_processCameraImage);

      setState(() {
        _isInitialized = true;
        _errorMessage = null;
      });
    } catch (e) {
      print('카메라 초기화 실패: $e');
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)?.cameraInitFailed(e.toString()) ??
            '카메라 초기화에 실패했습니다: $e';
      });
    }
  }

  /// 안정화된 결과 감지 처리 (카메라 스트림 중지 추가)
  void _onStableResultDetected(BarcodeScanResult result) {
    // 햅틱 피드백 제공 (진동)
    HapticFeedback.mediumImpact();

    // 개발자 모드 vs 일반 사용자 모드 처리
    if (kDebugMode) {
      // 개발자 모드: 검증 결과 화면 표시
      setState(() {
        _stableResult = result;
        _hasDetectedBarcode = true;
        _detectedBarcode = result.rawValue;
      });
      // 바코드 감지 성공 시 카메라 스트림 완전 중지
      _stopCameraStreamForResult();
    } else {
      // 일반 사용자 모드: 검색 신호 보내고 즉시 화면 닫기
      _hasCompletedScan = true; // ✅ 스캔 완료 표시
      widget.onBarcodeDetected(result.rawValue).then((_) {
        if (mounted) widget.onClose(); // ✅ 처리가 끝난 후 화면 닫기
      });
    }
  }

  /// 카메라 스트림 중지 (결과 표시용)
  void _stopCameraStreamForResult() async {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
      print('📷 카메라 스트림 중지 (바코드 감지 성공)');
    }
  }

  /// 바코드 결과 처리 (값 일관성 보장 + 체크섬 우선 순위)
  void _processBarcodeResult(BarcodeScanResult result) {
    final value = result.rawValue;
    _scanFrequency[value] = (_scanFrequency[value] ?? 0) + 1;

    final frequency = _scanFrequency[value] ?? 0;

    // 1. 체크섬 검증 통과한 경우 -> 즉시 또는 최소 2회 일치 시 수용 (정확도 극대화)
    if (result.isValid) {
      if (frequency >= 2 && _stableResult == null) {
        final stableResult = result.copyWith(scanCount: frequency);
        _onStableResultDetected(stableResult);
      }
    }
    // 2. 체크섬 검증 실패했으나 반복적으로 감지되는 경우 -> 매우 엄격한 기준으로 수용
    else {
      if (frequency >= _minInvalidConsistentScans && _stableResult == null) {
        final stableResult = result.copyWith(scanCount: frequency);
        _onStableResultDetected(stableResult);
      }
    }
  }

  /// 카메라 이미지에서 바코드 인식 (최종 간소화 버전)
  Future<void> _processCameraImage(CameraImage image) async {
    // 초기화 안됨, 이미 결과 있음, 또는 스캔 완료된 경우 중단
    if (!_isInitialized || _stableResult != null || _hasCompletedScan) {
      return;
    }

    // 짧은 쿨다운 체크 (0.5초)
    if (_lastDetectionTime != null &&
        DateTime.now().difference(_lastDetectionTime!) < _shortCooldown) {
      return;
    }

    try {
      // 이미지 변환
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) return;

      // 바코드 인식 (단축된 타임아웃: 2초)
      final barcodes = await _barcodeScanner
          .processImage(inputImage)
          .timeout(const Duration(milliseconds: 2000));

      // 바코드 감지 즉시 결과 처리 (UI 상태 변경 없음)
      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final scanResult = BarcodeValidator.validateBarcode(barcode);

        // 즉시 결과 처리 (다른 앱들과 동일한 패턴)
        _lastDetectionTime = DateTime.now();
        _processBarcodeResult(scanResult);
      }
    } catch (e) {
      // 오류 발생 시 무시하고 다음 프레임에서 재시도
    }
  }

  /// CameraImage를 Google ML Kit InputImage로 변환
  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    try {
      final camera = _cameraController!.description;
      final plane = image.planes[0];
      final bytes = plane.bytes;

      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      // 이미지 메타데이터 생성
      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: _rotationIntToImageRotation(camera.sensorOrientation),
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      print('이미지 변환 실패: $e');
      return null;
    }
  }

  /// 카메라 회전값을 InputImageRotation으로 변환
  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  /// 바코드 확인 및 결과 전달
  void _confirmBarcode() async {
    if (_detectedBarcode != null) {
      await widget.onBarcodeDetected(_detectedBarcode!);
      if (mounted) widget.onClose();
    }
  }

  /// 플래시 토글
  void _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      HapticFeedback.lightImpact();
    } catch (e) {
      print('플래시 토글 실패: $e');
    }
  }

  /// 카메라 스트림 재시작
  void _restartCameraStream() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // 현재 스트림 중지
      await _cameraController!.stopImageStream();

      // 잠시 대기 후 재시작
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted && _cameraController != null) {
        await _cameraController!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      print('카메라 스트림 재시작 실패: $e');
      // 실패 시 카메라 재초기화 시도
      _initializeCamera();
    }
  }

  /// 바코드 재스캔
  void _rescanBarcode() {
    // 모든 상태 완전 리셋
    setState(() {
      _hasDetectedBarcode = false;
      _hasCompletedScan = false; // ✅ 스캔 완료 상태 리셋
      _detectedBarcode = null;
      _lastDetectionTime = null;
      _scanFrequency.clear(); // 스캔 빈도수 리셋
      _stableResult = null; // 안정화된 결과 리셋
    });

    // 카메라 스트림 재시작 보장
    _restartCameraStream();
  }

  /// 바코드 포맷 번역 키를 실제 번역된 텍스트로 변환
  String _getTranslatedFormatName(BuildContext context, String formatKey) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return formatKey; // 폴백

    switch (formatKey) {
      case 'barcodeFormatEan13':
        return l10n.barcodeFormatEan13;
      case 'barcodeFormatEan8':
        return l10n.barcodeFormatEan8;
      case 'barcodeFormatUpca':
        return l10n.barcodeFormatUpca;
      case 'barcodeFormatUpce':
        return l10n.barcodeFormatUpce;
      case 'barcodeFormatQrCode':
        return l10n.barcodeFormatQrCode;
      case 'barcodeFormatCode128':
        return l10n.barcodeFormatCode128;
      case 'barcodeFormatCode39':
        return l10n.barcodeFormatCode39;
      case 'barcodeFormatCode93':
        return l10n.barcodeFormatCode93;
      case 'barcodeFormatCodabar':
        return l10n.barcodeFormatCodabar;
      case 'barcodeFormatItf':
        return l10n.barcodeFormatItf;
      case 'barcodeFormatAztec':
        return l10n.barcodeFormatAztec;
      case 'barcodeFormatDataMatrix':
        return l10n.barcodeFormatDataMatrix;
      case 'barcodeFormatPdf417':
        return l10n.barcodeFormatPdf417;
      case 'barcodeFormatUnknown':
        return l10n.barcodeFormatUnknown;
      default:
        return formatKey; // 폴백
    }
  }

  /// 상태별 텍스트 반환 (간소화)
  String get _statusText {
    if (!_isInitialized)
      return AppLocalizations.of(context)?.cameraInitializing ?? '카메라 초기화 중...';
    if (_hasDetectedBarcode)
      return AppLocalizations.of(context)?.barcodeDetected ?? '바코드 감지됨!';
    return AppLocalizations.of(context)?.pointCameraAtBarcode ??
        '바코드를 카메라에 비춰주세요\n(어디에나 바코드가 있으면 인식됩니다)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 스캐너 배경 블랙
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.barcodeScan ?? '바코드 스캔'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: AppLocalizations.of(context)?.flashToggle ?? '플래시 토글',
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: widget.onClose),
        ],
      ),
      body: _hasDetectedBarcode ? _buildResultView() : _buildScannerView(),
    );
  }

  /// 바코드 감지 결과 뷰
  Widget _buildResultView() {
    final result = _stableResult!;
    final isValid = result.isValid;
    final backgroundColor = isValid
        ? Colors.green.shade50
        : Colors.orange.shade50;
    final borderColor = isValid
        ? Colors.green.shade200
        : Colors.orange.shade200;
    final iconColor = isValid ? Colors.green : Colors.orange;

    return SafeArea(
      // 바코드 결과 화면에 SafeArea 추가
      child: Column(
        children: [
          // 바코드 감지 결과 표시
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 검증 상태 아이콘
                    Icon(
                      isValid ? Icons.check_circle : Icons.warning,
                      size: 64,
                      color: iconColor,
                    ),
                    const SizedBox(height: 16),

                    // 제목
                    Text(
                      isValid
                          ? AppLocalizations.of(context)?.barcodeVerified ??
                                '바코드 검증 완료!'
                          : AppLocalizations.of(context)?.invalidBarcode ??
                                '유효하지 않은 바코드',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 바코드 값
                    Text(
                      result.displayValue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // 검증 정보
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          // 타입 정보
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.qr_code,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${AppLocalizations.of(context)?.type ?? '타입'}: ${_getTranslatedFormatName(context, result.formatDisplayName)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // 신뢰도
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${AppLocalizations.of(context)?.confidenceLabel ?? '신뢰도'}: ${result.confidence}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // 스캔 횟수
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.repeat,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${AppLocalizations.of(context)?.scanCountLabel ?? '스캔 횟수'}: ${result.scanCount}회',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 버튼 영역
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmBarcode, // 검증 실패해도 확인 가능
                    icon: const Icon(Icons.check),
                    label: Text(
                      isValid
                          ? AppLocalizations.of(context)?.confirm ?? '확인'
                          : AppLocalizations.of(context)?.accept ?? '사용',
                    ), // 라벨 변경
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValid ? Colors.green : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _rescanBarcode,
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)?.rescan ?? '재스캔'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 바코드 스캐너 뷰
  Widget _buildScannerView() {
    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage ??
                  AppLocalizations.of(context)?.checkingCameraPermission ??
                  '카메라 권한을 확인하는 중...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: Text(
                AppLocalizations.of(context)?.requestPermission ?? '권한 요청',
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: openAppSettings,
              child: Text(
                AppLocalizations.of(context)?.openSettings ?? '설정으로 이동',
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.cameraInitializing ??
                  '카메라 초기화 중...',
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // 카메라 미리보기
        Positioned.fill(child: CameraPreview(_cameraController!)),

        // 스캔 오버레이
        CustomPaint(painter: _ScannerOverlayPainter(), child: Container()),

        // 하단 안내 텍스트 - SafeArea 적용으로 시스템 UI와 겹침 방지
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false, // 상단은 이미 카메라 뷰이므로 false
            bottom: true, // 하단 시스템 UI 고려
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom:
                    16 + MediaQuery.of(context).padding.bottom, // 시스템 하단 패딩 추가
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.supportedFormats ??
                        '지원 형식: QR코드, 바코드 (EAN-13, UPC-A 등)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        // 로딩 인디케이터 제거 (바코드 감지 즉시 결과 표시)
      ],
    );
  }
}

/// 스캐너 오버레이 페인터
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cornerLength = 20.0;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.7,
      height: size.width * 0.4,
    );

    // 사각형 테두리
    canvas.drawRect(rect, paint);

    // 모서리 코너 표시
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // 왼쪽 상단 코너
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(0, cornerLength),
      cornerPaint,
    );

    // 오른쪽 상단 코너
    canvas.drawLine(
      rect.topRight,
      rect.topRight + Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + Offset(0, cornerLength),
      cornerPaint,
    );

    // 왼쪽 하단 코너
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + Offset(0, -cornerLength),
      cornerPaint,
    );

    // 오른쪽 하단 코너
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + Offset(0, -cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
