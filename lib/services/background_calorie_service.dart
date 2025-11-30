import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/calorie_calculator.dart';
import '../models/calorie_status.dart';
import 'notification_service.dart';
import 'dart:developer' as developer;

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
Future<void> _syncHealthData() async {
  try {
    // 주의: 백그라운드 격리된 아이솔레이트에서 실행되므로
    // 필요한 서비스들을 새로 초기화해야 할 수 있음
    
    // 여기서는 HealthDataService를 동적으로 import하여 사용하거나
    // 필요한 로직을 직접 구현해야 함.
    // HealthDataService가 의존하는 패키지들이 백그라운드에서 잘 동작하는지 확인 필요.
    
    // 현재는 로그만 남기고 실제 동기화는 앱 실행 시 수행하도록 유도
    // (Android Health Connect는 백그라운드 읽기 권한이 제한적일 수 있음)
    developer.log('🔄 백그라운드 헬스 동기화 시도...');
    
    // TODO: 백그라운드 동기화 로직 구현
    // HealthDataService().syncToDatabase();
    
  } catch (e) {
    developer.log('❌ 백그라운드 헬스 동기화 실패: $e');
  }
}

/// 칼로리 상태 확인 및 알림 발송
Future<void> _checkCalorieStatus() async {

  try {
    final prefs = await SharedPreferences.getInstance();
    
    // 저장된 칼로리 및 목표 읽기
    final savedCalories = prefs.getDouble('calorie_current_value');
    final dailyGoal = prefs.getDouble('daily_calorie_goal') ?? 2000.0;
    final lastUpdate = prefs.getInt('calorie_last_update_ms');
    
    if (savedCalories == null || lastUpdate == null) {
      developer.log('⚠️ 칼로리 데이터 없음, 건너뜀');
      return;
    }
    
    // 경과 시간 계산
    final now = DateTime.now().millisecondsSinceEpoch;
    final minutesPassed = ((now - lastUpdate) / 60000).floor();
    
    if (minutesPassed <= 0) return;
    
    // BMR/TDEE 계산을 위한 프로필 데이터 읽기
    final weight = prefs.getDouble('user_weight');
    final height = prefs.getDouble('user_height');
    final age = prefs.getInt('user_age');
    final gender = prefs.getString('user_gender');
    final activityLevel = prefs.getString('user_activity_level');
    
    // BMR/TDEE 계산
    final bmr = CalorieCalculator.calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
    );
    
    final tdee = CalorieCalculator.calculateTDEE(bmr, activityLevel);
    
    // 감소량 계산
    final decrease = CalorieCalculator.calculateCalorieDecrease(
      tdee: tdee,
      minutes: minutesPassed,
      dailyGoal: dailyGoal,
    );
    
    // 현재 예상 칼로리
    final estimatedCalories = CalorieCalculator.applyDecrease(
      savedCalories,
      decrease,
    );
    
    // 상태 확인
    final status = getCalorieStatus(estimatedCalories, dailyGoal);
    
    developer.log('📊 예상 칼로리: ${estimatedCalories.toInt()} / ${dailyGoal.toInt()}');
    developer.log('📊 상태: $status');
    
    // veryLow 또는 low 상태일 때만 알림 발송
    if (status == CalorieStatus.veryLow || status == CalorieStatus.low) {
      final lastNotificationTime = prefs.getInt('last_low_calorie_notification') ?? 0;
      final hoursSinceLastNotification = ((now - lastNotificationTime) / 3600000).floor();
      
      // 최소 1시간 간격으로 알림 (Hysteresis)
      if (hoursSinceLastNotification >= 1) {
        await _sendLowCalorieNotification(status, estimatedCalories, dailyGoal);
        await prefs.setInt('last_low_calorie_notification', now);
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
    String title;
    String body;
    
    if (status == CalorieStatus.veryLow) {
      title = '⚠️ 에너지가 매우 부족해요!';
      body = '현재 ${current.toInt()} kcal (${((current / goal) * 100).toInt()}%). 식사가 필요해요!';
    } else {
      title = '💡 에너지가 부족해요';
      body = '현재 ${current.toInt()} kcal (${((current / goal) * 100).toInt()}%). 간식을 드시는 건 어떨까요?';
    }
    
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
