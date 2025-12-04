import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'dart:developer' as developer;

/// 수면 데이터 관리자
/// 
/// 수면 상태 판별 및 기기 데이터 동기화를 담당합니다.
/// 우선순위:
/// 1. 실시간 기기 데이터 (Health Connect/Kit)
/// 2. 수동 스케줄 (Fallback)
class SleepDataManager {
  static final SleepDataManager _instance = SleepDataManager._internal();
  factory SleepDataManager() => _instance;
  SleepDataManager._internal();

  /// 현재 수면 상태 확인
  /// 
  /// @param profile 사용자 프로필 (수면 설정 포함)
  /// @return true if asleep, false otherwise
  Future<bool> isAsleep(UserProfile profile) async {
    final config = profile.sleepConfig;
    
    // 1. 기기 데이터 확인 (Hybrid 모드일 때)
    if (config.mode == 'hybrid' || config.mode == 'device') {
      final isDeviceAsleep = await _checkDeviceSleepStatus();
      if (isDeviceAsleep != null) {
        return isDeviceAsleep;
      }
      
      // 기기 데이터 없으면 Fallback (Hybrid 모드만)
      if (config.mode == 'device') {
        return false; // 기기 모드인데 데이터 없으면 깨어있는 것으로 간주 (또는 에러 처리)
      }
    }
    
    // 2. 수동 스케줄 확인 (Manual 또는 Hybrid Fallback)
    return _checkManualSchedule(config);
  }

  /// 기기 수면 상태 확인 (Mock / 추후 구현)
  /// 
  /// @return true/false (상태 있음), null (데이터 없음/연동 안됨)
  Future<bool?> _checkDeviceSleepStatus() async {
    // TODO: Health Connect / HealthKit 연동 구현
    // 현재는 연동되지 않은 것으로 간주하여 null 반환
    return null; 
  }

  /// 수동 스케줄 기반 수면 상태 확인
  bool _checkManualSchedule(SleepConfig config) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    final sleepTimeParts = config.manualSleepTime.split(':');
    final wakeTimeParts = config.manualWakeTime.split(':');
    
    if (sleepTimeParts.length != 2 || wakeTimeParts.length != 2) {
      developer.log('⚠️ 잘못된 수면 시간 형식: ${config.manualSleepTime} ~ ${config.manualWakeTime}');
      return false;
    }
    
    final sleepHour = int.parse(sleepTimeParts[0]);
    final sleepMinute = int.parse(sleepTimeParts[1]);
    final wakeHour = int.parse(wakeTimeParts[0]);
    final wakeMinute = int.parse(wakeTimeParts[1]);
    
    final sleepMinutes = sleepHour * 60 + sleepMinute;
    final wakeMinutes = wakeHour * 60 + wakeMinute;
    
    if (sleepMinutes > wakeMinutes) {
      // 자정을 넘기는 스케줄 (예: 23:00 ~ 07:00)
      return currentMinutes >= sleepMinutes || currentMinutes < wakeMinutes;
    } else {
      // 자정을 안 넘기는 스케줄 (예: 01:00 ~ 08:00)
      return currentMinutes >= sleepMinutes && currentMinutes < wakeMinutes;
    }
  }
}
