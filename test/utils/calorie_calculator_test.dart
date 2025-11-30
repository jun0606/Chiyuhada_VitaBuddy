import 'package:flutter_test/flutter_test.dart';
import 'package:chiyuhada_vita_buddy/utils/calorie_calculator.dart';

void main() {
  group('CalorieCalculator', () {
    group('calculateBMR', () {
      test('남성 BMR 계산 - 정상 데이터', () {
        final bmr = CalorieCalculator.calculateBMR(
          weight: 70.0,
          height: 175.0,
          age: 30,
          gender: 'male',
        );
        
        // 예상값: 88.362 + (13.397 × 70) + (4.799 × 175) - (5.677 × 30)
        // = 88.362 + 937.79 + 839.825 - 170.31 = 1695.667
        expect(bmr, closeTo(1695.67, 0.1));
      });
      
      test('여성 BMR 계산 - 정상 데이터', () {
        final bmr = CalorieCalculator.calculateBMR(
          weight: 60.0,
          height: 165.0,
          age: 25,
          gender: 'female',
        );
        
        // 예상값: 447.593 + (9.247 × 60) + (3.098 × 165) - (4.330 × 25)
        // = 447.593 + 554.82 + 511.17 - 108.25 = 1405.333
        expect(bmr, closeTo(1405.33, 0.1));
      });
      
      test('데이터 누락 시 기본값 1500 반환', () {
        final bmr1 = CalorieCalculator.calculateBMR(
          weight: null,
          height: 175.0,
          age: 30,
          gender: 'male',
        );
        expect(bmr1, 1500.0);
        
        final bmr2 = CalorieCalculator.calculateBMR(
          weight: 70.0,
          height: -10.0, // 유효하지 않은 값
          age: 30,
          gender: 'male',
        );
        expect(bmr2, 1500.0);
      });
      
      test('성별 대소문자 구분 없음', () {
        final bmr1 = CalorieCalculator.calculateBMR(
          weight: 70.0,
          height: 175.0,
          age: 30,
          gender: 'MALE',
        );
        
        final bmr2 = CalorieCalculator.calculateBMR(
          weight: 70.0,
          height: 175.0,
          age: 30,
          gender: 'male',
        );
        
        expect(bmr1, equals(bmr2));
      });
    });
    
    group('calculateTDEE', () {
      test('sedentary 활동량 (1.2x)', () {
        final tdee = CalorieCalculator.calculateTDEE(1500.0, 'sedentary');
        expect(tdee, 1800.0);
      });
      
      test('moderate 활동량 (1.55x)', () {
        final tdee = CalorieCalculator.calculateTDEE(1500.0, 'moderate');
        expect(tdee, 2325.0);
      });
      
      test('very_active 활동량 (1.9x)', () {
        final tdee = CalorieCalculator.calculateTDEE(1500.0, 'very_active');
        expect(tdee, 2850.0);
      });
      
      test('유효하지 않은 활동량은 sedentary (1.2x) 기본값 사용', () {
        final tdee = CalorieCalculator.calculateTDEE(1500.0, 'unknown');
        expect(tdee, 1800.0);
      });
      
      test('null 활동량은 sedentary (1.2x) 기본값 사용', () {
        final tdee = CalorieCalculator.calculateTDEE(1500.0, null);
        expect(tdee, 1800.0);
      });
    });
    
    group('caloriesPerMinute', () {
      test('TDEE 2000 kcal/day -> 약 1.39 kcal/min', () {
        final perMin = CalorieCalculator.caloriesPerMinute(2000.0);
        expect(perMin, closeTo(1.39, 0.01));
      });
      
      test('TDEE 3000 kcal/day -> 약 2.08 kcal/min', () {
        final perMin = CalorieCalculator.caloriesPerMinute(3000.0);
        expect(perMin, closeTo(2.08, 0.01));
      });
    });
    
    group('calculateCalorieDecrease', () {
      test('정상 경과 시간 (60분)', () {
        final decrease = CalorieCalculator.calculateCalorieDecrease(
          tdee: 2000.0,
          minutes: 60,
          dailyGoal: 2000.0,
        );
        
        // 1시간 경과 -> 약 83.33 kcal 감소
        expect(decrease, closeTo(83.33, 1.0));
      });
      
      test('최대 감소량 제한 (24시간 초과)', () {
        final decrease = CalorieCalculator.calculateCalorieDecrease(
          tdee: 2000.0,
          minutes: 1440, // 24시간
          dailyGoal: 2000.0,
        );
        
        // 최대 30% 제한 -> 600 kcal
        expect(decrease, lessThanOrEqualTo(600.0));
      });
      
      test('0분 경과 시 0 반환', () {
        final decrease = CalorieCalculator.calculateCalorieDecrease(
          tdee: 2000.0,
          minutes: 0,
          dailyGoal: 2000.0,
        );
        expect(decrease, 0.0);
      });
      
      test('음수 경과 시간은 0 반환', () {
        final decrease = CalorieCalculator.calculateCalorieDecrease(
          tdee: 2000.0,
          minutes: -10,
          dailyGoal: 2000.0,
        );
        expect(decrease, 0.0);
      });
    });
    
    group('applyDecrease', () {
      test('정상 감소 적용', () {
        final result = CalorieCalculator.applyDecrease(500.0, 100.0);
        expect(result, 400.0);
      });
      
      test('음수 방지 (감소량 > 현재값)', () {
        final result = CalorieCalculator.applyDecrease(50.0, 100.0);
        expect(result, 0.0);
      });
      
      test('정확히 0이 되는 경우', () {
        final result = CalorieCalculator.applyDecrease(100.0, 100.0);
        expect(result, 0.0);
      });
    });
    
    group('통합 시나리오', () {
      test('30세 남성, 중간 활동량, 12시간 경과', () {
        // 1. BMR 계산
        final bmr = CalorieCalculator.calculateBMR(
          weight: 70.0,
          height: 175.0,
          age: 30,
          gender: 'male',
        );
        
        // 2. TDEE 계산
        final tdee = CalorieCalculator.calculateTDEE(bmr, 'moderate');
        
        // 3. 12시간 경과 시 감소량
        final decrease = CalorieCalculator.calculateCalorieDecrease(
          tdee: tdee,
          minutes: 720, // 12시간
          dailyGoal: tdee,
        );
        
        // 4. 현재 칼로리 1500에서 감소 적용
        final result = CalorieCalculator.applyDecrease(1500.0, decrease);
        
        // 12시간이면 약 절반 소모되어야 함
        expect(result, lessThan(1500.0));
        expect(result, greaterThan(0.0));
      });
    });
  });
}
