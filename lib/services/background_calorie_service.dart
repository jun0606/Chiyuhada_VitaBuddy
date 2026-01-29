import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/calorie_calculator.dart';
import '../models/calorie_status.dart';
import 'notification_service.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import '../models/user_profile.dart';
import 'enhanced_metabolism_calculator.dart';
import 'health_data_service.dart';

/// 백그라운드 칼로리 모니터링 서비스
///
/// 앱이 꺼져 있을 때도 15~30분 주기로 칼로리 상태를 확인하고
/// veryLow/low 상태 진입 시 알림을 발송합니다.
class BackgroundCalorieService {
  static const String taskName = 'calorie_bg_check';
  static const String uniqueName = 'calorie_monitor';

  // 헬스 데이터 동기화 태스크
  static const String healthSyncTaskName = 'health_data_sync';
  static const String healthSyncUniqueName = 'health_sync_monitor';

  /// Workmanager 초기화 및 등록
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      // isInDebugMode는 deprecated됨 (0.9.0+)
    );

    await registerPeriodicTask();
    await registerHealthSyncTask(); // 헬스 동기화 태스크 등록
  }

  /// 주기적 백그라운드 작업 등록 (칼로리 체크)
  static Future<void> registerPeriodicTask({
    Duration frequency = const Duration(minutes: 30),
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        uniqueName,
        taskName,
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );

      developer.log('✅ 칼로리 모니터링 작업 등록 성공: ${frequency.inMinutes}분 주기');
    } catch (e) {
      developer.log('❌ 칼로리 모니터링 작업 등록 실패: $e');
    }
  }

  /// 헬스 데이터 동기화 작업 등록 (1시간 주기)
  static Future<void> registerHealthSyncTask({
    Duration frequency = const Duration(hours: 1),
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        healthSyncUniqueName,
        healthSyncTaskName,
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: true, // 배터리 부족 시 실행 안함
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );

      developer.log('✅ 헬스 동기화 작업 등록 성공: ${frequency.inMinutes}분 주기');
    } catch (e) {
      developer.log('❌ 헬스 동기화 작업 등록 실패: $e');
    }
  }

  /// 백그라운드 작업 취소
  static Future<void> cancelPeriodicTask() async {
    await Workmanager().cancelByUniqueName(uniqueName);
    await Workmanager().cancelByUniqueName(healthSyncUniqueName);
    developer.log('⏹️ 백그라운드 작업 취소됨');
  }

  /// 모든 백그라운드 작업 취소
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    developer.log('⏹️ 모든 백그라운드 작업 취소됨');
  }
}

/// 백그라운드 콜백 디스패처
///
/// Workmanager가 호출하는 최상위 함수
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      developer.log('🔄 백그라운드 작업 시작: $task');

      if (task == BackgroundCalorieService.taskName) {
        await _checkCalorieStatus();
      } else if (task == BackgroundCalorieService.healthSyncTaskName) {
        await _syncHealthData();
      }

      return Future.value(true);
    } catch (e) {
      developer.log('❌ 백그라운드 작업 실패: $e');
      return Future.value(false);
    }
  });
}

/// 헬스 데이터 동기화 (백그라운드)
///
/// Health Connect/HealthKit에서 운동 데이터를 가져와 로컬 DB에 저장합니다.
/// 주의: Android Health Connect는 백그라운드 읽기 권한이 제한적일 수 있습니다.
Future<void> _syncHealthData() async {
  try {
    developer.log('🔄 백그라운드 헬스 동기화 시작...');

    final prefs = await SharedPreferences.getInstance();
    final healthService = HealthDataService();

    // 권한 확인
    final hasPermission = await healthService.hasPermissions();
    if (!hasPermission) {
      developer.log('⚠️ 헬스 데이터 권한 없음, 동기화 건너뜀');
      return;
    }

    // 동기화 실행
    final syncedCount = await healthService.syncToDatabase();

    // 마지막 동기화 시간 저장
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('last_health_sync_time', now);
    await prefs.setInt('last_health_sync_count', syncedCount);

    developer.log('✅ 백그라운드 헬스 동기화 완료: $syncedCount개 동기화됨');
  } catch (e) {
    developer.log('❌ 백그라운드 헬스 동기화 실패: $e');
  }
}

/// 칼로리 상태 확인 및 알림 발송
Future<void> _checkCalorieStatus() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // 1. 저장된 데이터 읽기
    final intakeCalories = prefs.getDouble('calorie_current_value'); // 섭취량
    final dailyGoal = prefs.getDouble('daily_calorie_goal') ?? 2000.0;
    final lastUpdate = prefs.getInt('calorie_last_update_ms');

    // 운동 데이터
    final exerciseBurned = prefs.getDouble('exercise_burned_calories') ?? 0.0;
    final exerciseMinutes = prefs.getInt('exercise_total_minutes') ?? 0;

    if (intakeCalories == null || lastUpdate == null) {
      developer.log('⚠️ 칼로리 데이터 없음, 건너뜀');
      return;
    }

    // 2. 프로필 데이터 읽기 및 재구성
    final weight = prefs.getDouble('user_weight') ?? 60.0;
    final height = prefs.getDouble('user_height') ?? 170.0;
    final age = prefs.getInt('user_age') ?? 25;
    final gender = prefs.getString('user_gender') ?? 'female';
    final activityLevel = prefs.getString('user_activity_level') ?? 'moderate';

    // 수면 설정 읽기
    final sleepMode = prefs.getString('sleep_config_mode') ?? 'hybrid';
    final sleepTime = prefs.getString('sleep_config_sleep_time') ?? '23:00';
    final wakeTime = prefs.getString('sleep_config_wake_time') ?? '07:00';

    // 임시 UserProfile 생성 (계산용)
    final profile = UserProfile(
      name: 'User', // 불필요
      age: age,
      height: height,
      initialWeight: weight,
      gender: gender,
      activityLevel: activityLevel,
      sleepConfig: SleepConfig(
        mode: sleepMode,
        manualSleepTime: sleepTime,
        manualWakeTime: wakeTime,
      ),
    );

    // 3. 실시간 소모량 계산 (Phase 16)
    final now = DateTime.now();

    // 누적 TDEE (BMR + 활동)
    double accumulatedTDEE =
        EnhancedMetabolismCalculator.calculateAccumulatedTDEE(profile, now);

    // 운동 시간 중복 제거 (AppProvider와 동일 로직)
    if (exerciseMinutes > 0) {
      final double dailyTDEE =
          EnhancedMetabolismCalculator.calculateEnhancedTDEE(profile);
      final double avgBurnPerMinute = dailyTDEE / 1440.0;
      accumulatedTDEE -= (avgBurnPerMinute * exerciseMinutes);
    }

    // 음수 방지
    accumulatedTDEE = accumulatedTDEE < 0 ? 0 : accumulatedTDEE;

    // 4. 순 칼로리 계산
    // Net = 섭취 - (누적TDEE + 운동소모)
    final totalBurned = accumulatedTDEE + exerciseBurned;
    final netCalories = intakeCalories - totalBurned;

    // 예상 칼로리 (알림 기준은 섭취량? 아니면 순 칼로리?)
    // 기존 로직은 'estimatedCalories'를 사용하여 알림을 보냈음.
    // 사용자는 "순 칼로리"를 기준으로 상태를 관리하고 싶어함.
    final currentStatusValue = netCalories;

    // === 스마트 알림 시스템 (Phase 13) ===

    // 1. 사용자 설정 로드
    final alertSensitivity = prefs.getString('alert_sensitivity') ?? 'normal';

    // 2. 식사 패턴 로드 및 파싱
    final mealPatternJson = prefs.getString('meal_pattern');
    Map<String, dynamic>? mealPattern;
    int mealsPerDay = 3; // 기본값

    if (mealPatternJson != null && mealPatternJson.isNotEmpty) {
      try {
        mealPattern = jsonDecode(mealPatternJson) as Map<String, dynamic>;

        // 활성화된 식사 개수 계산
        final meals = mealPattern['meals'] as List?;
        if (meals != null) {
          mealsPerDay = meals.where((meal) => meal['enabled'] == true).length;
        }
      } catch (e) {
        developer.log('❌ 식사 패턴 파싱 실패: $e');
        mealPattern = null;
      }
    }

    // 3. 동적 임계값 계산
    final dynamicLowThreshold = CalorieCalculator.getDynamicLowThreshold(
      mealsPerDay: mealsPerDay,
      sensitivity: alertSensitivity,
    );

    // 4. 다음 식사까지 시간 계산
    final minutesUntilNextMeal = CalorieCalculator.getMinutesUntilNextMeal(
      mealPattern,
      now,
    );

    // 5. 칼로리 퍼센트 계산 (목표 대비 순 칼로리)
    // 순 칼로리가 목표의 몇 %인지?
    // 보통 목표는 '섭취 목표'임.
    // 하지만 TDEE만큼 소모되므로, 순 칼로리는 0에 가까워야 유지?
    // 아니, '섭취 목표'는 TDEE와 같음.
    // 시간이 지날수록 TDEE가 소모되므로, '남은 목표'가 줄어듦.
    // 여기서 'percentage'는 '현재 보유 에너지 / 하루 필요 에너지' 개념이어야 함.

    // 기존 로직: estimatedCalories / dailyGoal
    // estimatedCalories는 '남은 에너지' 개념.
    final percentage = (currentStatusValue / dailyGoal) * 100;

    developer.log(
      '📊 백그라운드 체크: 순 칼로리 ${currentStatusValue.toInt()} / 목표 ${dailyGoal.toInt()} (${percentage.toInt()}%)',
    );

    // 6. 스마트 알림 판단
    bool shouldAlert = false;
    CalorieStatus? alertStatus;

    // veryLow (20% 이하) - 에너지가 거의 바닥남
    if (percentage <= 20) {
      shouldAlert = true;
      alertStatus = CalorieStatus.veryLow;
    }
    // low (동적 임계값)
    else if (percentage <= dynamicLowThreshold) {
      if (CalorieCalculator.shouldSendAlert(
        minutesUntilNextMeal: minutesUntilNextMeal,
        sensitivity: alertSensitivity,
      )) {
        shouldAlert = true;
        alertStatus = CalorieStatus.low;
      }
    }

    // 7. 알림 발송 (Hysteresis 적용)
    if (shouldAlert && alertStatus != null) {
      final lastNotificationTime =
          prefs.getInt('last_low_calorie_notification') ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceLastNotification =
          ((nowMs - lastNotificationTime) / 3600000).floor();

      if (hoursSinceLastNotification >= 1) {
        await _sendLowCalorieNotification(
          alertStatus,
          currentStatusValue,
          dailyGoal,
        );
        await prefs.setInt('last_low_calorie_notification', nowMs);
      }
    }
  } catch (e) {
    developer.log('❌ 칼로리 상태 확인 실패: $e');
  }
}

/// 칼로리 부족 알림 발송
Future<void> _sendLowCalorieNotification(
  CalorieStatus status,
  double current,
  double goal,
) async {
  try {
    final isVeryLow = status == CalorieStatus.veryLow;
    final percentage = ((current / goal) * 100).toInt();

    final title = NotificationLocalizations.getLowCalorieTitle(isVeryLow);
    final body = NotificationLocalizations.getLowCalorieBody(
      current.toInt(),
      percentage,
      isVeryLow,
    );

    // 로컬 알림 발송
    await NotificationService().showNotification(
      id: 9999, // 백그라운드 알림 전용 ID
      title: title,
      body: body,
    );

    developer.log('📬 알림 발송: $title');
  } catch (e) {
    developer.log('❌ 알림 발송 실패: $e');
  }
}
