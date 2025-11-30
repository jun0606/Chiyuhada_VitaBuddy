import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chiyuhada_vita_buddy/models/calorie_status.dart';
import 'package:chiyuhada_vita_buddy/widgets/enhanced_calorie_gauge.dart';

void main() {
  group('CalorieStatus', () {
    test('getCalorieStatus - veryLow (0-20%)', () {
      expect(getCalorieStatus(100, 1000), CalorieStatus.veryLow);
      expect(getCalorieStatus(200, 1000), CalorieStatus.veryLow);
    });

    test('getCalorieStatus - low (21-40%)', () {
      expect(getCalorieStatus(300, 1000), CalorieStatus.low);
      expect(getCalorieStatus(400, 1000), CalorieStatus.low);
    });

    test('getCalorieStatus - belowIdeal (41-60%)', () {
      expect(getCalorieStatus(500, 1000), CalorieStatus.belowIdeal);
      expect(getCalorieStatus(600, 1000), CalorieStatus.belowIdeal);
    });

    test('getCalorieStatus - ideal (61-80%)', () {
      expect(getCalorieStatus(700, 1000), CalorieStatus.ideal);
      expect(getCalorieStatus(800, 1000), CalorieStatus.ideal);
    });

    test('getCalorieStatus - slightlyHigh (81-95%)', () {
      expect(getCalorieStatus(850, 1000), CalorieStatus.slightlyHigh);
      expect(getCalorieStatus(950, 1000), CalorieStatus.slightlyHigh);
    });

    test('getCalorieStatus - high (96-110%)', () {
      expect(getCalorieStatus(1000, 1000), CalorieStatus.high);
      expect(getCalorieStatus(1100, 1000), CalorieStatus.high);
    });

    test('getCalorieStatus - exceeded (111%+)', () {
      expect(getCalorieStatus(1200, 1000), CalorieStatus.exceeded);
      expect(getCalorieStatus(1500, 1000), CalorieStatus.exceeded);
    });

    test('getCalorieStatus - edge cases', () {
      // goal이 0 이하인 경우
      expect(getCalorieStatus(100, 0), CalorieStatus.ideal);
      expect(getCalorieStatus(100, -100), CalorieStatus.ideal);
      
      // 정확히 경계값 (경계는 다음 레벨에 포함)
      expect(getCalorieStatus(200, 1000), CalorieStatus.veryLow); // 20%
      expect(getCalorieStatus(409, 1000), CalorieStatus.low); // 40.9%
      expect(getCalorieStatus(609, 1000), CalorieStatus.belowIdeal); // 60.9%
      expect(getCalorieStatus(809, 1000), CalorieStatus.ideal); // 80.9%
      expect(getCalorieStatus(949, 1000), CalorieStatus.slightlyHigh); // 94.9%
      expect(getCalorieStatus(1109, 1000), CalorieStatus.high); // 110.9%
    });
  });

  group('CalorieStatus Extension', () {
    test('color - 각 상태별 색상 검증', () {
      expect(CalorieStatus.veryLow.color, const Color(0xFFD32F2F));
      expect(CalorieStatus.low.color, const Color(0xFFFF6F00));
      expect(CalorieStatus.belowIdeal.color, const Color(0xFFFBC02D));
      expect(CalorieStatus.ideal.color, const Color(0xFF388E3C));
      expect(CalorieStatus.slightlyHigh.color, const Color(0xFF1976D2));
      expect(CalorieStatus.high.color, const Color(0xFF7B1FA2));
      expect(CalorieStatus.exceeded.color, const Color(0xFFB71C1C));
    });

    test('message - 각 상태별 메시지 검증', () {
      expect(CalorieStatus.veryLow.message, '배고파요... 식사가 필요해요!');
      expect(CalorieStatus.low.message, '에너지가 부족해요');
      expect(CalorieStatus.belowIdeal.message, '조금 더 먹어도 괜찮아요');
      expect(CalorieStatus.ideal.message, '완벽해요! 좋은 상태예요');
      expect(CalorieStatus.slightlyHigh.message, '조금 많이 먹었네요');
      expect(CalorieStatus.high.message, '칼로리가 높아요!');
      expect(CalorieStatus.exceeded.message, '목표 초과! 운동 필요해요!');
    });

    test('icon - 각 상태별 아이콘 검증', () {
      expect(CalorieStatus.veryLow.icon, Icons.battery_alert);
      expect(CalorieStatus.low.icon, Icons.battery_alert);
      expect(CalorieStatus.belowIdeal.icon, Icons.battery_3_bar);
      expect(CalorieStatus.ideal.icon, Icons.battery_full);
      expect(CalorieStatus.slightlyHigh.icon, Icons.warning_amber);
      expect(CalorieStatus.high.icon, Icons.error);
      expect(CalorieStatus.exceeded.icon, Icons.error);
    });
  });

  group('EnhancedCalorieGauge Widget', () {
    testWidgets('기본 렌더링 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedCalorieGauge(
              current: 800,
              goal: 2000,
            ),
          ),
        ),
      );

      // 위젯이 렌더링되는지 확인
      expect(find.byType(EnhancedCalorieGauge), findsOneWidget);
      
      // 칼로리 텍스트 확인
      expect(find.text('800 kcal / 2000 kcal'), findsOneWidget);
    });

    testWidgets('showLabel=false 시 라벨 숨김', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedCalorieGauge(
              current: 800,
              goal: 2000,
              showLabel: false,
            ),
          ),
        ),
      );

      // 아이콘이 표시되지 않아야 함
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('상태별 색상 및 메시지 표시', (WidgetTester tester) async {
      // Ideal 상태 (61-80%)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedCalorieGauge(
              current: 1400, // 70%
              goal: 2000,
            ),
          ),
        ),
      );

      expect(find.text('완벽해요! 좋은 상태예요'), findsOneWidget);
    });
  });

  group('AnimatedCalorieGauge Widget', () {
    testWidgets('애니메이션 기본 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCalorieGauge(
              current: 800,
              goal: 2000,
            ),
          ),
        ),
      );

      // 초기 상태
      expect(find.byType(AnimatedCalorieGauge), findsOneWidget);
      
      // 애니메이션 완료 대기
      await tester.pumpAndSettle();
      
      // 최종 값 확인
      expect(find.text('800 kcal / 2000 kcal'), findsOneWidget);
    });

    testWidgets('값 변경 시 애니메이션 동작', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCalorieGauge(
              current: 500,
              goal: 2000,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('500 kcal / 2000 kcal'), findsOneWidget);

      // 값 변경
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCalorieGauge(
              current: 1000,
              goal: 2000,
            ),
          ),
        ),
      );

      // 애니메이션 진행 중
      await tester.pump(const Duration(milliseconds: 400));
      
      // 애니메이션 완료
      await tester.pumpAndSettle();
      expect(find.text('1000 kcal / 2000 kcal'), findsOneWidget);
    });
  });
}
