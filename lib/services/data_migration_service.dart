import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/body_composition.dart';
import '../models/body_types.dart';

/// 데이터 마이그레이션 서비스
class DataMigrationService {
  /// Hive Box 초기화 및 마이그레이션 실행
  static Future<void> initializeAndMigrate() async {
    await Hive.initFlutter();
    
    // UserProfile 어댑터 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    
    // Box 열기
    final box = await Hive.openBox<UserProfile>('userProfile');
    
    // 마이그레이션 실행
    await migrateUserProfiles(box);
  }
  
  /// 기존 UserProfile 마이그레이션
  static Future<void> migrateUserProfiles(Box<UserProfile> box) async {
    if (box.isEmpty) return;
    
    for (var key in box.keys) {
      final profile = box.get(key);
      if (profile == null) continue;
      
      // 새 필드가 null이면 기본값 설정
      bool needsUpdate = false;
      
      // 체질 타입: BMI 기반 자동 추천
      if (profile.somatotype == null) {
        profile.somatotype = _recommendSomatotype(profile).name;
        needsUpdate = true;
      }
      
      // 체형: 성별 기반 기본값
      if (profile.bodyShape == null) {
        profile.bodyShape = _recommendBodyShape(profile).name;
        needsUpdate = true;
      }
      
      // 체형 구성 정보: 체형 기반 기본 패턴
      if (profile.bodyCompositionData == null && profile.bodyShape != null) {
        final bodyShape = BodyShape.fromString(profile.bodyShape!);
        final composition = BodyComposition.fromBodyShape(bodyShape.name);
        profile.setBodyComposition(composition);
        needsUpdate = true;
      }
      
      // 성격 특성: 중립적 기본값
      if (profile.personalityTraits == null) {
        profile.personalityTraits = {
          'conscientiousness': 50,
          'extraversion': 50,
          'neuroticism': 50,
          'openness': 50,
          'agreeableness': 50,
        };
        needsUpdate = true;
      }
      
      // 변경사항 저장
      if (needsUpdate) {
        await profile.save();
        print('✅ Migrated profile: ${profile.name ?? "User"}');
      }
    }
  }
  
  /// BMI 기반 체질 추천
  static Somatotype _recommendSomatotype(UserProfile profile) {
    final bmi = profile.getBMI();
    
    if (bmi < 18.5) {
      return Somatotype.ectomorph; // 저체중 → 외배엽형
    } else if (bmi < 25) {
      return Somatotype.mesomorph; // 정상 → 중배엽형
    } else {
      return Somatotype.endomorph; // 과체중/비만 → 내배엽형
    }
  }
  
  /// 성별 기반 체형 추천
  static BodyShape _recommendBodyShape(UserProfile profile) {
    if (profile.gender.toLowerCase() == 'female') {
      return BodyShape.pear; // 여성: 통계적으로 배형이 가장 흔함
    } else if (profile.gender.toLowerCase() == 'male') {
      return BodyShape.rectangle; // 남성: 직사각형이 가장 흔함
    } else {
      return BodyShape.rectangle; // 기타: 중립적 기본값
    }
  }
  
  /// 마이그레이션 상태 확인
  static Future<bool> checkMigrationStatus(Box<UserProfile> box) async {
    if (box.isEmpty) return true;
    
    for (var key in box.keys) {
      final profile = box.get(key);
      if (profile == null) continue;
      
      // 필수 필드 확인
      if (profile.somatotype == null ||
          profile.bodyShape == null ||
          profile.personalityTraits == null) {
        return false; // 마이그레이션 필요
      }
    }
    
    return true; // 마이그레이션 완료
  }
}
