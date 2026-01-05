import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/data_migration_service.dart';
import '../services/calorie_state_calculator.dart';
import '../services/background_calorie_service.dart';
import '../services/health_data_service.dart';
import '../services/sleep_data_manager.dart';
import '../services/enhanced_metabolism_calculator.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/advanced_avatar_widget.dart';
import '../avatar/body_measurements.dart';
import '../avatar/avatar_animations.dart';
import '../avatar/face_expressions.dart';
import '../avatar/clothing_colors.dart';
import '../avatar/body_poses.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class AppProvider with ChangeNotifier, WidgetsBindingObserver {
  UserProfile? _userProfile;

  // 칼로리 관리 (개선된 구조)
  double _intakeCalories = 0.0; // 섭취 칼로리 (식사)
  double _exerciseBurnedCalories = 0.0; // 운동 소모 칼로리 (기록된 운동)
  double _activityCalories = 0.0; // 움직임 칼로리 소비 (실시간 웨어러블 데이터)
  int _exerciseTotalMinutes = 0; // 오늘 총 운동 시간(분)

  // 목표 설정 (신체 데이터 기반 동적 계산)
  double _tdeeCalories = 0.0; // 계산된 TDEE (유지) - 초기화 시 계산
  double _goalCalories = 0.0; // 사용자 목표 - 초기화 시 설정
  String _calorieMode = 'maintain'; // maintain/loss/bulk

  bool _isLoading = false;
  String? _errorMessage;

  // 날짜 변경 감지용
  DateTime _lastCheckedDate = DateTime.now();
  Timer? _midnightTimer; // 자정 체크용 타이머
  Timer? _tdeeUpdateTimer; // TDEE 갱신용 타이머 (1분마다)
  Timer? _activityCaloriesTimer; // 움직임 칼로리 실시간 업데이트 타이머 (5분마다)

  // 알림 Hysteresis (과식 경고)
  DateTime? _lastOverLimitNotificationTime;

  static const String _keyLastUpdate = 'calorie_last_update_ms';
  static const String _keyCurrentCalories = 'calorie_current_value';
  static const String _keyCalorieMode = 'calorie_mode';
  static const String _keyGoalCalories = 'goal_calories';
  static const String _keyLocale = 'app_locale'; // 언어 설정 키
  static const String _keyLanguageSet = 'is_language_set'; // 첫 실행 언어 설정 여부

  // 아바타 상태
  AvatarAnimationType _currentAnimationType = AvatarAnimationType.idle;
  FaceExpressionType _currentExpression = FaceExpressionType.neutral;
  BodyPose _currentPose = BodyPose.neutral;

  // 새로운 데이터 요소를 위해 추가
  double _manualExerciseBurnedCalories = 0.0; // 수동으로 입력된 운동 소모 칼로리

  // 언어 설정
  Locale _locale = const Locale('ko'); // 기본값 한국어
  bool _isLanguageSet = false; // 언어 설정 완료 여부 (첫 실행 판단)

  // 타임존 설정
  String _timezoneName = 'Asia/Seoul'; // 기본 타임존

  // 타임존 Getters/Setters
  String get timezoneName => _timezoneName;
  List<String> get availableTimezones =>
      NotificationService().getAvailableTimezones();
  String get currentTimezoneName =>
      NotificationService().getCurrentTimezoneName();

  /// 타임존 설정 (동적)
  Future<void> setTimezone(String timezoneName) async {
    try {
      // 타임존이 유효한지 검증
      final availableTimezones = NotificationService().getAvailableTimezones();
      if (!availableTimezones.contains(timezoneName)) {
        developer.log('⚠️ 유효하지 않은 타임존: $timezoneName, 기본값 사용');
        timezoneName = 'Asia/Seoul';
      }

      _timezoneName = timezoneName;

      // NotificationService에 타임존 설정 적용
      await NotificationService().setTimezone(timezoneName);

      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_timezone', timezoneName);

      developer.log('✅ 앱 타임존 설정: $timezoneName');
      notifyListeners();
    } catch (e) {
      developer.log('❌ 타임존 설정 실패: $e');
      // 실패 시 기본 타임존으로 복귀
      _timezoneName = 'Asia/Seoul';
    }
  }

  // 자동 표정 로테이션
  Timer? _expressionTimer;
  final bool _autoRotationEnabled = true;

  // 플래시 효과 이벤트
  String? _flashEvent; // 'food' 또는 'exercise'

  // Getters
  UserProfile? get userProfile => _userProfile;
  Locale get locale => _locale;
  bool get isLanguageSet => _isLanguageSet;

  // 기본 칼로리 값 (기존 호환성)
  double get currentCalories => _intakeCalories; // 섭취

  /// 운동 소모 칼로리 표시용 (통합 계산)
  double get currentBurnedCalories {
    // 1. Health Connect 실시간 활동량 우선 (가장 정확함)
    if (_activityCalories > 0) {
      return _activityCalories;
    }

    // 2. 수동 기록된 운동 칼로리 (Health Connect 미사용 시)
    if (_manualExerciseBurnedCalories > 0) {
      return _manualExerciseBurnedCalories;
    }

    // 3. 전체 운동 기록 합산 (fallback)
    return _exerciseBurnedCalories;
  }

  double get dailyCalorieGoal => _goalCalories; // 목표

  // 새로운 칼로리 계산
  double get tdeePerMinute => _tdeeCalories / 1440;

  /// TDEE 기반 시간 소모 (운동 시간 제외)
  ///
  /// 실시간 BMR 및 활동 대사량 누적 계산 (Phase 16)
  double get tdeeBurnedCalories {
    if (_userProfile == null) return 0.0;

    final now = DateTime.now();

    // 1. 00:00부터 현재까지의 누적 TDEE (BMR + 활동)
    double accumulatedTDEE =
        EnhancedMetabolismCalculator.calculateAccumulatedTDEE(
          _userProfile!,
          now,
        );

    // 2. 운동 시간 중복 제거
    // 운동 중에는 '활동 칼로리'가 적용되므로, 해당 시간만큼의 '일반 TDEE 소모'는 차감해야 함
    // (Health Connect 데이터는 BMR이 포함되지 않은 Active Calories임을 가정)
    if (_exerciseTotalMinutes > 0) {
      final double dailyTDEE =
          EnhancedMetabolismCalculator.calculateEnhancedTDEE(_userProfile!);

      // 비수면 시간 기준 분당 활동 대사량 추정
      final double avgBurnPerMinute = dailyTDEE / 1440.0;

      // 운동 시간만큼 차감 (단, 0보다 작아지지 않게)
      accumulatedTDEE -= (avgBurnPerMinute * _exerciseTotalMinutes);
    }

    return max(0.0, accumulatedTDEE);
  }

  /// 총 소모 칼로리 (Health Connect 최신 활동량 + 수동 기록 + TDEE)
  /// _activityCalories는 Health Connect에서 가져온 오늘 총 활동 소모량임
  /// _exerciseBurnedCalories는 수동 + 자동 세션 소모량임 (중복 주의)
  double get totalBurnedCalories {
    // Health Connect 활동량(_activityCalories)은 이미 우리가 동기화한 세션 칼로리를 포함하고 있음.
    // 따라서 '수동 입력'된 칼로리만 별도로 합산해주어야 함.
    // _intakeCalories - totalBurnedCalories 로 계산되므로, totalBurnedCalories 가 높을수록 순칼로리가 낮아짐.
    return _activityCalories +
        _manualExerciseBurnedCalories +
        tdeeBurnedCalories;
  }

  /// 잔여 칼로리 (더 먹을 수 있는 양)
  /// = 목표 - 섭취 + (운동 + TDEE 소모)
  double get remainingCalories =>
      _goalCalories - _intakeCalories + totalBurnedCalories;

  /// 순 칼로리 (체중 증감 예측용)
  double get netCalories => _intakeCalories - totalBurnedCalories;

  // 기존 호환성
  double get totalCalories => _intakeCalories;
  double get calorieProgress => _intakeCalories / _goalCalories;

  // 상태
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isProfileComplete => _userProfile != null;
  String get calorieMode => _calorieMode;
  AvatarAnimationType get currentAnimationType => _currentAnimationType;
  FaceExpressionType get currentExpression => _currentExpression;
  BodyPose get currentPose => _currentPose;
  String? get flashEvent => _flashEvent; // 플래시 이벤트

  // BMI 관련
  double get bmi => _userProfile?.getBMI() ?? 0.0;
  String get bmiCategory => _userProfile?.getBMICategory() ?? 'unknown';

  // 칼로리 상태
  bool get isOverCalorieLimit => _intakeCalories > _goalCalories;
  bool get isNearLimit => _intakeCalories > _goalCalories * 0.8;

  // 수면 모드 상태
  bool _isSleepMode = false;
  bool get isSleepMode => _isSleepMode;

  // 웨어러블 연결 상태
  bool _isWearableConnected = false;
  String? _connectedPlatformName; // "Health Connect" 또는 "HealthKit"
  bool _hasHealthPermission = false;
  DateTime? _lastHealthSyncTime;

  // 현재 진행 중인 운동 정보
  String? _currentActivityName; // "달리기", "걷기" 등
  int? _currentActivityMinutes; // 경과 시간 (분)
  double? _currentActivityCalories; // 소모 칼로리
  double? _currentActivityDistance; // 거리 (km)

  // 웨어러블 상태 Getters
  bool get isWearableConnected => _isWearableConnected;
  String? get connectedPlatformName => _connectedPlatformName;
  bool get hasHealthPermission => _hasHealthPermission;
  DateTime? get lastHealthSyncTime => _lastHealthSyncTime;
  String? get currentActivityName => _currentActivityName;
  int? get currentActivityMinutes => _currentActivityMinutes;
  double? get currentActivityCalories => _currentActivityCalories;
  double? get currentActivityDistance => _currentActivityDistance;

  // 초기화
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Lifecycle observer 등록
    WidgetsBinding.instance.addObserver(this);
    _lastCheckedDate = DateTime.now();

    try {
      await _loadLocaleSettings(); // 언어 설정 로드
      await _loadTimezoneSettings(); // 타임존 설정 로드
      await NotificationService().initialize();
      // Hive 초기화 보장 (중복 초기화 방지)
      if (!Hive.isBoxOpen('userProfile')) {
        await Hive.openBox<UserProfile>('userProfile');
        developer.log('📦 Hive userProfile 박스 초기화 완료');
      }
      var box = Hive.box<UserProfile>('userProfile');

      // 1. 프로필 로드 우선 (마이그레이션이 데이터를 건드리기 전에 원본 확보)
      _userProfile = box.get('profile');
      developer.log('📖 Hive에서 프로필 로드: ${_userProfile != null ? '성공' : '없음'}');

      // 2. 데이터가 있으면 마이그레이션 실행 (필드 업데이트 등)
      if (_userProfile != null) {
        try {
          await DataMigrationService.migrateUserProfiles(box);
          // 마이그레이션 후 갱신된 데이터 다시 로드
          _userProfile = box.get('profile');
          developer.log('🔄 프로필 마이그레이션 완료');
        } catch (e) {
          developer.log('⚠️ 마이그레이션 중 오류 발생 (데이터는 유지됨): $e');
        }
      }

      // 3. Hive에 데이터가 없으면 SharedPreferences 백업 확인 (복구 시도)
      if (_userProfile == null) {
        developer.log('⚠️ Hive에서 프로필을 찾을 수 없습니다. SharedPreferences 백업 확인 중...');
        final backupProfile = await _loadUserProfileFromPrefs();
        if (backupProfile != null) {
          _userProfile = backupProfile;
          await box.put('profile', _userProfile!); // 복구된 데이터 Hive에 재저장
          developer.log('✅ SharedPreferences에서 프로필 복구 성공!');

          // 복구된 데이터 검증
          final verifyProfile = box.get('profile');
          if (verifyProfile != null) {
            developer.log('✅ Hive에 복구된 프로필 저장 검증 성공');
          } else {
            developer.log('❌ Hive에 복구된 프로필 저장 실패');
          }
        } else {
          developer.log('ℹ️ 복구할 백업 데이터가 없습니다.');
        }
      }

      if (_userProfile != null) {
        // TDEE 계산
        _tdeeCalories = _userProfile!.getEnhancedTDEE();

        // 저장된 목표 및 모드 로드
        final prefs = await SharedPreferences.getInstance();
        _calorieMode = prefs.getString(_keyCalorieMode) ?? 'maintain';

        // 저장된 목표가 있으면 사용, 없으면 TDEE 기본값
        if (prefs.containsKey(_keyGoalCalories)) {
          _goalCalories = prefs.getDouble(_keyGoalCalories)!;
        } else {
          _goalCalories = _tdeeCalories;
        }

        await _scheduleWeightCheckReminder();

        developer.log('✅ 프로필 로드: ${_userProfile!.name}');
        developer.log('   TDEE: ${_tdeeCalories.toInt()} kcal');
        developer.log(
          '   목표: ${_goalCalories.toInt()} kcal ($_calorieMode 모드)',
        );
      }

      await _loadTodayCalories();

      // 헬스 데이터 동기화
      syncHealthData();

      // 웨어러블 상태 확인
      checkWearableStatus();

      // 백그라운드 서비스 초기화
      await _initializeBackgroundService();

      // 식사 패턴 알림 설정 (패턴이 있는 경우)
      if (_userProfile != null && _userProfile!.hasMealPattern()) {
        final mealPattern = _userProfile!.getMealPattern();
        if (mealPattern != null) {
          developer.log('🍽️ 식사 패턴 알림 설정 시작');
          await NotificationService().setupMealPatternNotifications(
            mealPattern,
          );
          developer.log('✅ 식사 패턴 알림 설정 완료');
        }
      }

      // 자정 체크 타이머 시작
      _scheduleMidnightCheck();

      // TDEE 갱신 타이머 시작 (1분마다 UI 업데이트)
      _startTDEEUpdateTimer();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = '초기화 오류: $e';
      developer.log('❌ 초기화 실패: $e');
    } finally {
      // ✅ 웰컴 그리팅: notifyListeners 이전에 greeting 상태로 설정
      developer.log('=== 웰컴 그리팅 설정 시작 ===');
      _currentExpression = FaceExpressionType.greeting;
      _currentPose = BodyPose.greeting;
      developer.log('✅ 표정 설정: ${_currentExpression.toString()}');
      developer.log('✅ 포즈 설정: ${_currentPose.toString()}');
      resetExpressionTimer(); // 자동 로테이션 일시 중지

      _isLoading = false;
      notifyListeners(); // 이제 greeting 상태로 UI 업데이트됨

      developer.log('👋 웰컴 그리팅 시작 (초기화 완료) - 3초 대기 중...');

      // 3초 후 정상 상태로 복귀
      Future.delayed(const Duration(seconds: 3), () {
        if (_isDisposed) return; // 안전장치
        developer.log('⏰ 3초 경과 - 웰컴 그리팅 종료, 상태 복귀 시작');
        _updateAvatarByCalorieStatus();
        startAutoExpressionRotation();
        developer.log('=== 웰컴 그리팅 종료 ===');
      });
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _expressionTimer?.cancel();
    _midnightTimer?.cancel();
    _tdeeUpdateTimer?.cancel();
    _activityCaloriesTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 백그라운드 진입 시 필요한 작업
    } else if (state == AppLifecycleState.resumed) {
      _checkDateChange();

      // 데이터 새로고침 및 자동 동기화
      _loadTodayCalories();
      syncHealthData(); // 앱 복귀 시 자동 동기화 트리거
      notifyListeners();
    }
  }

  // 날짜 변경 확인 및 데이터 리로드
  Future<void> _checkDateChange() async {
    final now = DateTime.now();
    if (now.day != _lastCheckedDate.day ||
        now.month != _lastCheckedDate.month ||
        now.year != _lastCheckedDate.year) {
      developer.log(
        '📅 날짜 변경 감지: ${_lastCheckedDate.toString()} -> ${now.toString()}',
      );
      _lastCheckedDate = now;

      // 날짜가 바뀌면 데이터 리로드 (새로운 날의 데이터는 0부터 시작)
      await _loadTodayCalories();
      notifyListeners();
    }
  }

  // 언어 설정 로드
  Future<void> _loadLocaleSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLanguageSet = prefs.getBool(_keyLanguageSet) ?? false;
      final String? languageCode = prefs.getString(_keyLocale);

      developer.log('🌐 언어 설정 로드 시작');
      developer.log('   _keyLanguageSet 값: $_isLanguageSet');
      developer.log('   _keyLocale 값: $languageCode');

      if (languageCode != null) {
        _locale = Locale(languageCode);
        developer.log('✅ 언어 설정 로드 성공: ${_locale.languageCode}');
      } else {
        developer.log('⚠️ 저장된 언어 코드 없음');
      }

      // 첫 실행 감지: 언어 설정이 없으면 한국어 기본값 사용하되 첫 실행으로 처리
      if (!_isLanguageSet) {
        developer.log('🚩 첫 실행 감지: 언어 설정이 완료되지 않음');
        _locale = const Locale('ko'); // 기본값 한국어
        // 하지만 _isLanguageSet은 false로 유지해서 언어 선택 화면 표시
      }

      developer.log(
        '🌐 최종 언어 상태: locale=${_locale.languageCode}, isSet=$_isLanguageSet',
      );
    } catch (e) {
      developer.log('❌ 언어 설정 로드 실패: $e');
      // 오류 시 기본값 사용
      _locale = const Locale('ko');
      _isLanguageSet = false;
    }
  }

  // 타임존 설정 로드
  Future<void> _loadTimezoneSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedTimezone = prefs.getString('app_timezone');

      if (savedTimezone != null) {
        _timezoneName = savedTimezone;
        // NotificationService에 타임존 설정 적용
        await NotificationService().setTimezone(savedTimezone);
        developer.log('🕐 타임존 설정 로드: $savedTimezone');
      } else {
        // 기본 타임존 설정 (기기 로케일 기반)
        final deviceTimezone = DateTime.now().timeZoneName;
        _timezoneName = deviceTimezone;
        await setTimezone(deviceTimezone);
        developer.log('🕐 기본 타임존 설정: $deviceTimezone');
      }
    } catch (e) {
      developer.log('❌ 타임존 설정 로드 실패: $e');
      // 실패 시 기본 타임존 사용
      _timezoneName = 'Asia/Seoul';
    }
  }

  // 언어 설정 변경
  Future<void> setLocale(Locale newLocale) async {
    developer.log('🌐 setLocale 호출: ${newLocale.languageCode}');

    if (_locale == newLocale && _isLanguageSet) {
      developer.log('🌐 이미 설정된 언어이므로 건너뜀');
      return;
    }

    _locale = newLocale;
    _isLanguageSet = true;
    NotificationLocalizations.setLanguageCode(newLocale.languageCode);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLocale, newLocale.languageCode);
      await prefs.setBool(_keyLanguageSet, true);

      // 저장 검증
      final savedLocale = prefs.getString(_keyLocale);
      final savedIsSet = prefs.getBool(_keyLanguageSet);

      developer.log('✅ 언어 설정 저장 완료: locale=$savedLocale, isSet=$savedIsSet');
      developer.log('🌐 언어 변경 성공: ${newLocale.languageCode}');
    } catch (e) {
      developer.log('❌ 언어 설정 저장 실패: $e');
      // 저장 실패 시 플래그 되돌리기
      _isLanguageSet = false;
    }
  }

  // 자정 체크 예약
  void _scheduleMidnightCheck() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1); // 내일 00:00
    final duration = tomorrow.difference(now);

    _midnightTimer?.cancel(); // 기존 타이머 취소
    _midnightTimer = Timer(duration, () {
      developer.log('🌙 자정 도달 - 칼로리 초기화 실행');
      _checkDateChange(); // 날짜 변경 체크 및 초기화
      _scheduleMidnightCheck(); // 다음 자정 예약
    });
  }

  // TDEE 갱신 타이머 시작
  void _startTDEEUpdateTimer() {
    _tdeeUpdateTimer?.cancel();

    // 1분마다 UI 업데이트 (TDEE는 시간 경과에 따라 변함)
    _tdeeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      // 수면 상태 확인
      if (_userProfile != null) {
        final wasSleepMode = _isSleepMode;
        _isSleepMode = await SleepDataManager().isAsleep(_userProfile!);

        if (wasSleepMode != _isSleepMode) {
          developer.log('💤 수면 모드 변경: $_isSleepMode');
        }
      }

      // 값은 getter에서 계산되므로 알림만 보내면 됨
      notifyListeners();
    });

    // 움직임 칼로리 실시간 업데이트 타이머 시작 (5분마다)
    _startActivityCaloriesTimer();
  }

  // 움직임 칼로리 실시간 업데이트 타이머 시작
  void _startActivityCaloriesTimer() {
    _activityCaloriesTimer?.cancel();

    // 5분마다 움직임 칼로리 소비량 업데이트
    _activityCaloriesTimer = Timer.periodic(const Duration(minutes: 5), (
      _,
    ) async {
      await _updateRealtimeActivityCalories();
    });
  }

  // 실시간 움직임 칼로리 소비량 업데이트
  Future<void> _updateRealtimeActivityCalories() async {
    try {
      if (!hasHealthPermission) {
        developer.log('ℹ️ 헬스 권한 없음 - 움직임 칼로리 업데이트 건너뜀');
        return;
      }

      final healthService = HealthDataService();
      final realtimeCalories = await healthService
          .getRealtimeActivityCalories();

      // 움직임 칼로리 소비량 업데이트
      if (_activityCalories != realtimeCalories) {
        _activityCalories = realtimeCalories;
        developer.log('🏃 움직임 칼로리 소비 업데이트: ${realtimeCalories.toInt()} kcal');

        // UI 실시간 업데이트
        notifyListeners();
      }
    } catch (e) {
      developer.log('❌ 실시간 움직임 칼로리 업데이트 실패: $e');
    }
  }

  // 의상 색상 업데이트
  Future<void> updateClothingColors(ClothingColors colors) async {
    if (_userProfile == null) return;

    // toJson()은 Map<String, dynamic>을 반환하므로 Map<String, int>로 변환
    final colorMap = <String, int>{
      'braColor': colors.braColor.value,
      'tightsColor': colors.tightsColor.value,
    };

    final updatedProfile = _userProfile!.copyWith(clothingColors: colorMap);
    await saveUserProfile(updatedProfile);
  }

  Future<void> updateWeight(double newWeight) async {
    if (_userProfile == null) return;

    final updatedProfile = _userProfile!.copyWith(initialWeight: newWeight);
    await saveUserProfile(updatedProfile);
    await saveUserProfile(updatedProfile);
  }

  // 목표 칼로리 및 모드 업데이트
  Future<void> updateCalorieGoal(double goal, String mode) async {
    _goalCalories = goal;
    _calorieMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyGoalCalories, goal);
    await prefs.setString(_keyCalorieMode, mode);

    notifyListeners();
    _saveCalorieDataToPrefs(); // 목표 변경 후 저장
    developer.log('🎯 목표 업데이트: ${goal.toInt()} kcal ($mode)');
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Hive 박스 초기화 보장 (더욱 견고하게)
      Box<UserProfile> box;
      if (!Hive.isBoxOpen('userProfile')) {
        try {
          box = await Hive.openBox<UserProfile>('userProfile');
          developer.log('✅ Hive userProfile 박스 새로 초기화');
        } catch (e) {
          developer.log('❌ Hive 박스 초기화 실패: $e');
          throw Exception('데이터베이스 초기화 실패: $e');
        }
      } else {
        box = Hive.box<UserProfile>('userProfile');
      }

      // 프로필 저장 시도 (더욱 안전하게)
      try {
        await box.put('profile', profile);
        developer.log('✅ 프로필 Hive 저장 성공');
      } catch (e) {
        developer.log('❌ 프로필 Hive 저장 실패: $e');
        throw Exception('프로필 저장 실패: $e');
      }

      _userProfile = profile;

      // TDEE 계산 및 저장
      _tdeeCalories = profile.getEnhancedTDEE();
      _goalCalories = _tdeeCalories; // 기본값은 TDEE로 설정

      // SharedPreferences에 프로필 데이터 저장 (백그라운드 작업용)
      try {
        await _saveUserProfileToPrefs(profile);
        developer.log('✅ SharedPreferences에 프로필 백업 완료');
      } catch (e) {
        developer.log('⚠️ 프로필 백업 실패 (Hive 저장은 성공함): $e');
        // 백업 실패는 치명적이지 않으므로 무시하고 진행
      }

      // 칼로리 데이터도 함께 저장
      await _saveCalorieDataToPrefs();
      developer.log('✅ 칼로리 데이터 저장 완료');

      _errorMessage = null;
      developer.log('🎉 프로필 저장 작업 전체 완료');
    } catch (e) {
      _errorMessage = '프로필 저장 오류: $e';
      developer.log('❌ 프로필 저장 실패: $e');
      throw e; // 상위로 예외 전파
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 오늘 칼로리 로드 (섭취 + 소비 + 운동 시간)
  Future<void> _loadTodayCalories() async {
    try {
      String today = DateTime.now().toIso8601String().split('T')[0];

      // 섭취 칼로리
      _intakeCalories = await DatabaseService().getTotalCaloriesForDate(today);

      // 운동 전체 소모 칼로리 (수동 + 자동 합산)
      _exerciseBurnedCalories = await DatabaseService()
          .getTotalBurnedCaloriesForDate(today);

      // 수동 입력 운동 칼로리만 별도 조회 (중복 합산 방지용)
      final allRecords = await DatabaseService().getExerciseRecordsForDate(
        today,
      );
      _manualExerciseBurnedCalories = allRecords
          .where(
            (r) =>
                (r['source'] ?? 'manual').toString().toLowerCase() == 'manual',
          )
          .fold<double>(
            0.0,
            (sum, r) => sum + (r['calories_burned'] as num? ?? 0).toDouble(),
          );

      // 오늘 총 운동 시간 계산 (TDEE 차감용)
      _exerciseTotalMinutes = allRecords.fold<int>(
        0,
        (sum, record) => sum + (record['duration_minutes'] as int? ?? 0),
      );

      developer.log(
        '📊 칼로리 로드: 섭취 ${_intakeCalories.toInt()}, 수동운동 ${_manualExerciseBurnedCalories.toInt()}, 전체운동 ${_exerciseBurnedCalories.toInt()}, 운동시간 $_exerciseTotalMinutes분',
      );

      // 🎭 칼로리 로드 후 아바타 상태 업데이트
      _updateAvatarByCalorieStatus();

      // 실시간 활동 칼로리 즉시 로드 (Health Connect)
      await _updateRealtimeActivityCalories();

      _saveCalorieDataToPrefs(); // 로드 후 저장 (동기화)
    } catch (e) {
      _errorMessage = '데이터 로드 오류: $e';
      developer.log('❌ 칼로리 로드 실패: $e');
    }
  }

  // 음식 섭취 추가
  Future<void> addFoodIntake(
    int foodId,
    double quantity,
    double calories,
  ) async {
    try {
      developer.log('🍔 음식 추가 시작: $calories kcal');
      await DatabaseService().addFoodIntake(foodId, quantity, calories);
      _intakeCalories += calories;

      developer.log('📊 현재 섭취: $_intakeCalories / 목표: $_goalCalories');

      // 🎭 음식 섭취 시 아바타 반응은 홈 화면으로 돌아간 후 실행
      // (home_screen.dart에서 triggerCeremony() 호출)
      // triggerFoodAddedCeremony(); // 제거: 즉시 실행하지 않음

      // 플래시 효과 트리거
      _flashEvent = 'food';
      notifyListeners();

      // 플래시 이벤트 초기화
      await Future.delayed(const Duration(milliseconds: 300));
      _flashEvent = null;
      _saveCalorieDataToPrefs(); // 음식 추가 후 저장
      notifyListeners();
    } catch (e) {
      _errorMessage = '음식 추가 오류: $e';
      developer.log('❌ 음식 추가 실패: $e');
      notifyListeners();
    }
  }

  /// 🎭 칼로리 상태별 아바타 자동 업데이트
  void _updateAvatarByCalorieStatus() {
    try {
      developer.log('🎭 아바타 상태 업데이트 시작');

      if (_goalCalories == 0) {
        developer.log('⚠️ 목표 칼로리가 0입니다. 임시 값(2000)으로 설정하여 진행합니다.');
        _goalCalories = 2000.0; // 안전장치
      }

      final percentage = _intakeCalories / _goalCalories;
      developer.log(
        '📊 섭취 비율: ${(percentage * 100).toStringAsFixed(1)}% ($_intakeCalories / $_goalCalories)',
      );

      FaceExpressionType newExpression;
      BodyPose newPose;

      // 🟢 이상적 범위 (80-100%)
      if (percentage >= 0.8 && percentage <= 1.0) {
        developer.log('🟢 이상적 범위 감지');
        newExpression = FaceExpressionType.satisfied;
        newPose = BodyPose.cheer;
        developer.log('😊 만족 - 칼로리 달성! 환호하는 아바타');
      }
      // 🔴 과식 (120% 초과)
      else if (percentage > 1.2) {
        developer.log('🔴 과식 범위 감지');
        newExpression = FaceExpressionType.stuffed;
        newPose = BodyPose.refuse; // bendForward → refuse (숙이기 불가)
        developer.log('😰 과식 - 더 이상 못 먹겠는 아바타');
      }
      // 😔 낮은 칼로리 (50% 미만)
      else if (percentage < 0.5) {
        developer.log('💙 저칼로리 범위 감지');
        newExpression = FaceExpressionType.hungry;
        newPose = BodyPose.touchBelly;
        developer.log('😔 에너지 부족 - 배고픈 아바타');
      }
      // 🙂 보통 범위 (50-80%)
      else {
        developer.log('⚪ 보통 범위 감지');
        newExpression = FaceExpressionType.neutral;
        newPose = BodyPose.neutral;
        developer.log('🙂 보통 상태 - 중립 아바타');
      }

      // 상태 변경이 있을 때만 업데이트
      if (_currentExpression != newExpression || _currentPose != newPose) {
        _currentExpression = newExpression;
        _currentPose = newPose;

        // 수동 변경이 아니므로 타이머 리셋은 하지 않음 (자동 로테이션 흐름 유지)
        notifyListeners();
      }
    } catch (e, stackTrace) {
      developer.log('❌ 아바타 상태 업데이트 실패: $e');
      developer.log('❌ 스택 트레이스: $stackTrace');
      // 오류 발생 시 중립 상태로 복귀
      _currentExpression = FaceExpressionType.neutral;
      _currentPose = BodyPose.neutral;
      notifyListeners();
    }
  }

  /// 💪 운동 완료 시 아바타 축하 반응
  Future<void> celebrateExercise() async {
    setExpression(FaceExpressionType.satisfied);
    setPose(BodyPose.armsUp);
    developer.log('💪 운동 완료 - 뿌듯한 아바타');

    // 플래시 효과 트리거
    _flashEvent = 'exercise';
    notifyListeners();

    // 3초 후 정상 상태로 복귀
    await Future.delayed(const Duration(seconds: 3));
    _flashEvent = null;
    _updateAvatarByCalorieStatus();
  }

  /// 🎉 목표 달성 시 아바타 축하 반응
  Future<void> celebrateGoalAchievement() async {
    setExpression(FaceExpressionType.happy);
    setPose(BodyPose.cheer);
    developer.log('🎉 목표 달성 - 환호하는 아바타');

    // 5초 후 정상 상태로 복귀
    await Future.delayed(const Duration(seconds: 5));
    _updateAvatarByCalorieStatus();
  }

  // 히스토리 요약 데이터 가져오기 (단일 - 오늘/어제 등)
  Future<Map<String, dynamic>> getHistorySummary() async {
    try {
      final summaries = await DatabaseService().getDailySummaries(limit: 1);
      if (summaries.isNotEmpty) {
        return summaries.first;
      }
      return {'total_days': 0, 'avg_calories': 0.0};
    } catch (e) {
      developer.log('히스토리 요약 로드 오류: $e');
      return {'total_days': 0, 'avg_calories': 0.0};
    }
  }

  // 히스토리 목록 가져오기 (복수)
  Future<List<Map<String, dynamic>>> getHistorySummaries({
    int limit = 30,
  }) async {
    try {
      return await DatabaseService().getDailySummaries(limit: limit);
    } catch (e) {
      developer.log('히스토리 목록 로드 오류: $e');
      return [];
    }
  }

  // 아바타 관련 메서드
  Widget buildAvatarWidget({double? height, double? width}) {
    if (_userProfile == null) {
      return const SizedBox();
    }

    // 현재 상태에 따른 아바타 렌더링
    return AdvancedAvatarWidget(
      bmi: bmi,
      height: _userProfile!.height,
      gender: _userProfile!.gender,
      lifestyle: _mapActivityLevelToLifestylePattern(
        _userProfile!.activityLevel,
      ),
      expression: _currentExpression,
      pose: _currentPose,
      clothingColors: _userProfile!.getClothingColors(),
    );
  }

  // 표정 설정
  void setExpression(FaceExpressionType expression, {bool autoReturn = false}) {
    _currentExpression = expression;
    notifyListeners();

    if (autoReturn) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_currentExpression == expression) {
          _currentExpression = FaceExpressionType.neutral;
          notifyListeners();
        }
      });
    }

    // 🔧 수동으로 표정을 설정할 때는 자동 로테이션 일시 중지
    resetExpressionTimer();
  }

  // 포즈 설정
  void setPose(BodyPose pose, {bool autoReturn = false}) {
    _currentPose = pose;
    notifyListeners();

    if (autoReturn) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_currentPose == pose) {
          _currentPose = BodyPose.neutral;
          notifyListeners();
        }
      });
    }

    // 🔧 수동으로 포즈를 설정할 때는 자동 로테이션 일시 중지
    resetExpressionTimer();
  }

  // 자동 표정 로테이션 시작
  void startAutoExpressionRotation() {
    if (!_autoRotationEnabled) return;
    _expressionTimer?.cancel();
    _scheduleNextExpression();
  }

  void resetExpressionTimer() {
    _expressionTimer?.cancel();
  }

  /// 웰컴 그리팅 트리거 (홈 화면 진입 시 호출)
  void triggerWelcomeGreeting() {
    developer.log('=== 홈 화면 진입 - 웰컴 그리팅 시작 ===');

    // 현재 표정/포즈를 greeting으로 변경
    _currentExpression = FaceExpressionType.greeting;
    _currentPose = BodyPose.greeting;
    developer.log('✅ 표정 설정: ${_currentExpression.toString()}');
    developer.log('✅ 포즈 설정: ${_currentPose.toString()}');

    // 자동 로테이션 일시 중지
    resetExpressionTimer();

    notifyListeners();

    developer.log('👋 웰컴 그리팅 표시 중 - 3초 대기...');

    // 3초 후 정상 상태로 복귀
    Future.delayed(const Duration(seconds: 3), () {
      if (_isDisposed) return;
      developer.log('⏰ 3초 경과 - 웰컴 그리팅 종료, 상태 복귀');
      _updateAvatarByCalorieStatus();
      startAutoExpressionRotation();
      developer.log('=== 웰컴 그리팅 종료 ===');
    });
  }

  /// 음식 추가 시 승리 세리머니 트리거
  void triggerFoodAddedCeremony() {
    developer.log('=== 음식 추가 - 승리 세리머니 시작 ===');

    // 승리 포즈와 행복한 표정 설정
    _currentExpression = FaceExpressionType.happy;
    _currentPose = BodyPose.victory;

    // 자동 로테이션 일시 중지
    resetExpressionTimer();

    notifyListeners();

    // 3초 후 정상 상태로 복귀 (애니메이션 2.3초 + 여유)
    Future.delayed(const Duration(seconds: 3), () {
      if (_isDisposed) return;
      developer.log('⏰ 3초 경과 - 승리 세리머니 종료, 상태 복귀');
      _updateAvatarByCalorieStatus();
      startAutoExpressionRotation();
    });
  }

  void _scheduleNextExpression() {
    if (!_autoRotationEnabled) return;

    final seconds = 5 + Random().nextInt(11);
    _expressionTimer = Timer(Duration(seconds: seconds), () {
      _rotateExpression();
      _scheduleNextExpression();
    });
  }

  void _rotateExpression() {
    // ✅ greeting 중이면 로테이션 하지 않음 (웰컴 그리팅 보호)
    if (_currentPose == BodyPose.greeting) {
      developer.log('👋 greeting 상태이므로 자동 로테이션 건너뜀');
      return;
    }

    final calorieState = CalorieStateCalculator.getState(
      _intakeCalories,
      _goalCalories,
    );
    final currentBMI = bmi;

    final expressionList =
        CalorieStateCalculator.getExpressionRotationListWithBMI(
          calorieState,
          currentBMI,
        );

    final currentIndex = expressionList.indexOf(_currentExpression);
    FaceExpressionType nextExpression;

    if (currentIndex == -1 || currentIndex >= expressionList.length - 1) {
      nextExpression = expressionList.first;
    } else {
      nextExpression = expressionList[currentIndex + 1];
    }

    // 표정 변경
    _currentExpression = nextExpression;

    // 포즈도 상태에 맞게 업데이트
    _currentPose = CalorieStateCalculator.getRecommendedPose(
      calorieState,
      currentBMI,
    );

    notifyListeners();
  }

  // 헬퍼 메서드들
  LifestylePattern _mapActivityLevelToLifestylePattern(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return LifestylePattern.sedentary;
      case 'very_active':
        return LifestylePattern.athletic;
      default:
        return LifestylePattern.active;
    }
  }

  Future<void> _scheduleWeightCheckReminder() async {
    try {
      await NotificationService().scheduleWeightCheckReminder(
        hour: 8,
        minute: 0,
      );
    } catch (e) {
      _errorMessage = '알림 예약 오류: $e';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadTodayCalories();
    notifyListeners();
  }

  // 헬퍼 메서드들
  String getGenderFromProvider() {
    return _userProfile?.gender ?? 'female';
  }

  double getHeightFromProvider() {
    return _userProfile?.height ?? 170.0;
  }

  double getWeightFromProvider() {
    return _userProfile?.initialWeight ?? 60.0;
  }

  // Convenience Getters
  double get weight => _userProfile?.initialWeight ?? 60.0;
  double get height => _userProfile?.height ?? 170.0;
  int get age => _userProfile?.age ?? 25;
  String get gender => _userProfile?.gender ?? 'female';

  void setAnimationType(AvatarAnimationType animationType) {
    _currentAnimationType = animationType;
    notifyListeners();
  }

  /// 축하 애니메이션 트리거 (칼로리 목표 달성 시 등)
  void triggerCeremony() {
    try {
      print('🎉 [DEBUG] triggerCeremony() 시작');

      // 칼로리 상태에 따라 적절한 표정과 포즈 설정
      final calorieStatus = CalorieStateCalculator.getState(
        _intakeCalories,
        _goalCalories,
      );

      print(
        '🎉 [DEBUG] 칼로리 상태: $calorieStatus (섭취: $_intakeCalories, 목표: $_goalCalories)',
      );

      if (calorieStatus == CalorieState.optimal ||
          calorieStatus == CalorieState.achieved) {
        // 이상적인 칼로리 섭취 - 기쁜 표정
        print('😊 [DEBUG] optimal/achieved - happy + armsUp');
        setExpression(FaceExpressionType.happy, autoReturn: true);
        setPose(BodyPose.armsUp, autoReturn: true);
      } else if (calorieStatus == CalorieState.veryLow ||
          calorieStatus == CalorieState.low) {
        // 너무 적게 섭취 - 배고픈 표정
        print('😢 [DEBUG] veryLow/low - hungry + touchBelly');
        setExpression(FaceExpressionType.hungry, autoReturn: true);
        setPose(BodyPose.touchBelly, autoReturn: true);
      } else if (calorieStatus == CalorieState.exceeded ||
          calorieStatus == CalorieState.excessive) {
        // 과다 섭취 - 거부 표정
        print('😰 [DEBUG] exceeded/excessive - refuse + refuse');
        setExpression(FaceExpressionType.refuse, autoReturn: true);
        setPose(BodyPose.refuse, autoReturn: true);
      }

      print('🎉 [DEBUG] triggerCeremony() 완료');
    } catch (e, stackTrace) {
      print('❌ [DEBUG] triggerCeremony() 실패: $e');
      print('❌ [DEBUG] 스택 트레이스: $stackTrace');
      // 오류 시 기본 상태로 복귀
      setExpression(FaceExpressionType.neutral, autoReturn: true);
      setPose(BodyPose.neutral, autoReturn: true);
    }
  }

  Widget buildAvatarPreviewWidget({
    String? name,
    double? height,
    double? weight,
    String? gender,
    int? age,
    String? activityLevel,
  }) {
    final previewHeight = height ?? 170.0;
    final previewWeight = weight ?? 60.0;
    final previewGender = gender ?? 'female';
    final previewActivityLevel = activityLevel ?? 'moderate';
    final previewBMI =
        previewWeight / ((previewHeight / 100) * (previewHeight / 100));

    return AdvancedAvatarWidget(
      bmi: previewBMI,
      height: previewHeight,
      gender: previewGender,
      lifestyle: _mapActivityLevelToLifestylePattern(previewActivityLevel),
    );
  }

  // ========== Phase 3: 백그라운드 서비스 ==========

  /// 백그라운드 서비스 초기화
  Future<void> _initializeBackgroundService() async {
    try {
      await BackgroundCalorieService.initialize();

      // 프로필이 있으면 데이터 저장
      if (_userProfile != null) {
        await _saveUserProfileToPrefs(_userProfile!);

        // 현재 목표 칼로리도 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('daily_calorie_goal', _goalCalories);
      }

      developer.log('✅ 백그라운드 서비스 초기화 완료');
    } catch (e) {
      developer.log('❌ 백그라운드 서비스 초기화 실패: $e');
    }
  }

  /// 사용자 프로필을 SharedPreferences에 저장
  /// 사용자 프로필을 SharedPreferences에 저장 (JSON 전체 백업)
  Future<void> _saveUserProfileToPrefs(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(profile.toJson());
      await prefs.setString('user_profile_backup', jsonString);

      // 기존 개별 필드 저장 (호환성 유지)
      await prefs.setDouble('user_weight', profile.initialWeight);
      await prefs.setDouble('user_height', profile.height);
      await prefs.setInt('user_age', profile.age);
      await prefs.setString('user_gender', profile.gender);
      await prefs.setString('user_activity_level', profile.activityLevel);

      developer.log('💾 SharedPreferences에 프로필 백업 완료 (JSON + 개별 필드)');
    } catch (e) {
      developer.log('❌ 프로필 저장 오류: $e');
    }
  }

  /// SharedPreferences에서 프로필 백업 로드 (복구용)
  Future<UserProfile?> _loadUserProfileFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('user_profile_backup');
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return UserProfile.fromJson(jsonMap);
      }
    } catch (e) {
      developer.log('❌ SharedPreferences 프로필 로드 실패: $e');
    }
    return null;
  }

  // ========== Phase 4: 헬스 데이터 통합 ==========

  // ========== Phase 3: 백그라운드 서비스 데이터 동기화 ==========

  /// 칼로리 데이터를 SharedPreferences에 저장 (백그라운드 서비스용)
  Future<void> _saveCalorieDataToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. 섭취 및 운동 데이터 저장
      await prefs.setDouble(_keyCurrentCalories, _intakeCalories); // 섭취량
      await prefs.setDouble(
        'exercise_burned_calories',
        _exerciseBurnedCalories,
      );
      await prefs.setInt('exercise_total_minutes', _exerciseTotalMinutes);

      // 2. 목표 저장
      await prefs.setDouble(_keyGoalCalories, _goalCalories);

      // 3. 마지막 업데이트 시간
      await prefs.setInt(_keyLastUpdate, DateTime.now().millisecondsSinceEpoch);

      // 4. 수면 설정 저장 (백그라운드에서 계산하기 위해)
      if (_userProfile != null) {
        final sleepConfig = _userProfile!.sleepConfig;
        await prefs.setString('sleep_config_mode', sleepConfig.mode);
        await prefs.setString(
          'sleep_config_sleep_time',
          sleepConfig.manualSleepTime,
        );
        await prefs.setString(
          'sleep_config_wake_time',
          sleepConfig.manualWakeTime,
        );

        // 5. 식사 패턴 저장 (Phase 13 스마트 알림용)
        if (_userProfile!.hasMealPattern()) {
          final mealPattern = _userProfile!.getMealPattern();
          if (mealPattern != null) {
            await prefs.setString('meal_pattern', jsonEncode(mealPattern));
          }
        }
      }

      // developer.log('💾 백그라운드 데이터 저장 완료');
    } catch (e) {
      developer.log('❌ 백그라운드 데이터 저장 실패: $e');
    }
  }

  /// 헬스 데이터 동기화
  Future<Map<String, dynamic>> syncHealthData() async {
    try {
      developer.log('🔄 헬스 데이터 동기화 시작...');
      final healthService = HealthDataService();

      // 1. 가용성 체크
      final isAvailable = await healthService.isHealthConnectAvailable();
      if (!isAvailable) {
        developer.log('⚠️ 헬스 커넥트를 사용할 수 없는 환경입니다.');
        _errorMessage =
            '헬스 커넥트를 사용할 수 없는 환경입니다. Health Connect 앱이 설치되어 있는지 확인해주세요.';
        _isWearableConnected = false;
        notifyListeners();
        return {'success': false, 'message': 'Health Connect를 사용할 수 없습니다.'};
      }

      // 2. 권한 확인
      final hasPermission = await healthService.hasPermissions();
      _hasHealthPermission = hasPermission;
      if (!hasPermission) {
        developer.log('ℹ️ 헬스 권한이 없어 동기화를 건너뜁니다.');
        _errorMessage = '헬스 데이터 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
        _isWearableConnected = false;
        notifyListeners();
        return {'success': false, 'message': '권한이 필요합니다.'};
      }

      // 권한 상태 업데이트
      _hasHealthPermission = true;
      _isWearableConnected = true;
      _connectedPlatformName = 'Health Connect';

      // 3. 데이터베이스 동기화 (운동 세션들)
      final syncedCount = await healthService.syncToDatabase().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          developer.log('⏰ 동기화 타임아웃 (30초)');
          throw TimeoutException('동기화 시간이 초과되었습니다.');
        },
      );

      // 4. 동기화 시간 업데이트
      _lastHealthSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'last_health_sync_time',
        _lastHealthSyncTime!.millisecondsSinceEpoch,
      );

      // 5. 오늘의 칼로리 데이터 새로고침
      await _loadTodayCalories();

      // 6. 실시간 움직임 칼로리 소비량 즉시 업데이트
      await _updateRealtimeActivityCalories();

      developer.log(
        '✅ 헬스 데이터 동기화 완료: $syncedCount개 세션, 실시간=$_activityCalories',
      );

      if (_errorMessage?.contains('헬스 데이터') == true ||
          _errorMessage?.contains('권한') == true) {
        _errorMessage = null;
      }

      notifyListeners();
      return {
        'success': true,
        'message': syncedCount > 0
            ? '$syncedCount개의 운동 기록을 동기화했습니다.'
            : '새로운 운동 기록이 없습니다.',
        'syncedCount': syncedCount,
        'activityCalories': _activityCalories,
      };
    } on TimeoutException catch (e) {
      developer.log('⏰ 헬스 데이터 동기화 타임아웃: $e');
      _errorMessage = '동기화 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
      notifyListeners();
      return {'success': false, 'message': '동기화 시간이 초과되었습니다.'};
    } catch (e, stackTrace) {
      developer.log('❌ 헬스 데이터 동기화 실패: $e');
      developer.log('❌ 스택 트레이스: $stackTrace');
      return {'success': false, 'message': '동기화 중 오류가 발생했습니다: $e'};
    }
  }

  /// 웨어러블 연결 상태 확인 및 업데이트
  Future<void> checkWearableStatus() async {
    try {
      developer.log('🔍 웨어러블 상태 확인 중...');

      final healthService = HealthDataService();

      // 1. 권한 상태 확인
      _hasHealthPermission = await healthService.hasPermissions();
      developer.log('   권한 상태: $_hasHealthPermission');

      // 2. Health Connect 사용 가능 여부 확인 (Android)
      try {
        final isAvailable = await healthService.isHealthConnectAvailable();
        if (isAvailable) {
          _connectedPlatformName = 'Health Connect';
          _isWearableConnected = true;
        } else {
          // iOS인 경우
          _connectedPlatformName = 'HealthKit';
          _isWearableConnected = _hasHealthPermission;
        }
      } catch (e) {
        // 플랫폼 확인 실패 시 권한 상태로 연결 여부 판단
        _isWearableConnected = _hasHealthPermission;
        _connectedPlatformName = _hasHealthPermission ? 'HealthKit' : null;
      }

      // 3. 마지막 동기화 시간 로드
      final prefs = await SharedPreferences.getInstance();
      final lastSyncMs = prefs.getInt('last_health_sync_time');
      if (lastSyncMs != null) {
        _lastHealthSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncMs);
      }

      // 4. 현재 진행 중인 운동 확인 (오늘 가장 최근 운동)
      await _checkCurrentActivity();

      developer.log(
        '✅ 웨어러블 상태: 연결=$_isWearableConnected, 플랫폼=$_connectedPlatformName',
      );
      notifyListeners();
    } catch (e) {
      developer.log('❌ 웨어러블 상태 확인 실패: $e');
    }
  }

  /// 현재 진행 중인 운동 확인
  Future<void> _checkCurrentActivity() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final records = await DatabaseService().getExerciseRecordsForDate(today);

      if (records.isEmpty) {
        _currentActivityName = null;
        _currentActivityMinutes = null;
        _currentActivityCalories = null;
        _currentActivityDistance = null;
        return;
      }

      // 가장 최근 운동 (마지막 30분 이내인 경우만 "진행 중"으로 표시)
      final lastRecord = records.last;
      final recordTime = DateTime.tryParse(lastRecord['time'] ?? '');

      if (recordTime != null) {
        final minutesSince = DateTime.now().difference(recordTime).inMinutes;

        // 30분 이내 운동이면 "진행 중"으로 간주
        if (minutesSince < 30) {
          _currentActivityName = lastRecord['exercise_name'] as String?;
          _currentActivityMinutes = lastRecord['duration_minutes'] as int?;
          _currentActivityCalories = (lastRecord['calories_burned'] as num?)
              ?.toDouble();
          _currentActivityDistance = (lastRecord['distance_meters'] as num?)
              ?.toDouble();

          // 거리를 km로 변환
          if (_currentActivityDistance != null) {
            _currentActivityDistance = _currentActivityDistance! / 1000.0;
          }

          developer.log(
            '🏃 진행 중 운동: $_currentActivityName, $_currentActivityMinutes분',
          );
        } else {
          _currentActivityName = null;
        }
      }
    } catch (e) {
      developer.log('⚠️ 현재 운동 확인 실패: $e');
    }
  }

  /// 웨어러블 권한 요청
  Future<bool> requestHealthPermissions() async {
    try {
      final healthService = HealthDataService();
      final granted = await healthService.requestPermissions();

      if (granted) {
        await checkWearableStatus();
      }

      return granted;
    } catch (e) {
      developer.log('❌ 권한 요청 실패: $e');
      return false;
    }
  }

  /// Health Connect에서 체중 동기화 및 아바타 업데이트
  ///
  /// 최신 체중을 가져와 UserProfile에 저장하고 아바타 체형(BMI)을 업데이트합니다.
  Future<bool> syncWeightFromHealth() async {
    try {
      developer.log('⚖️ 체중 동기화 시작...');

      final healthService = HealthDataService();
      final latestWeight = await healthService.getLatestWeight();

      if (latestWeight == null) {
        developer.log('ℹ️ 동기화할 체중 데이터 없음');
        return false;
      }

      if (_userProfile == null) {
        developer.log('⚠️ 프로필이 없어 체중 동기화 불가');
        return false;
      }

      // 현재 체중과 비교
      final currentWeight = _userProfile!.initialWeight;
      if ((currentWeight - latestWeight).abs() < 0.1) {
        developer.log('ℹ️ 체중 변화 없음 (${latestWeight.toStringAsFixed(1)} kg)');
        return true;
      }

      // UserProfile 업데이트
      final updatedProfile = _userProfile!.copyWith(
        initialWeight: latestWeight,
      );
      await saveUserProfile(updatedProfile);

      developer.log(
        '✅ 체중 동기화 완료: ${currentWeight.toStringAsFixed(1)} → ${latestWeight.toStringAsFixed(1)} kg',
      );
      developer.log('🎭 아바타 체형(BMI) 자동 업데이트됨');

      // 아바타 상태 업데이트 (BMI 변경 반영)
      _updateAvatarByCalorieStatus();

      notifyListeners();
      return true;
    } catch (e) {
      developer.log('❌ 체중 동기화 실패: $e');
      return false;
    }
  }

  /// 체중 기록 가져오기
  Future<List<Map<String, dynamic>>> getWeightHistoryFromHealth({
    int days = 30,
  }) async {
    try {
      final healthService = HealthDataService();
      return await healthService.getWeightHistory(days: days);
    } catch (e) {
      developer.log('❌ 체중 기록 조회 실패: $e');
      return [];
    }
  }
}
