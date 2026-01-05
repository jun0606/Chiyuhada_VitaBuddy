import 'dart:async'; // Timer 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode 사용
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/advanced_avatar_widget.dart';
import '../avatar/body_measurements.dart';
import '../services/database_service.dart'; // 데이터베이스 서비스
import '../l10n/app_localizations.dart'; // 다국어 지원
import 'food_input_screen.dart';
import 'weight_record_screen.dart';
import 'clothing_settings_screen.dart';
import 'exercise_record_screen.dart'; // 운동 기록 화면
import 'settings_screen.dart'; // 설정 화면
import 'history_screen.dart'; // 기록 화면
import 'polygon_test_screen.dart'; // 개발자 테스트 화면
import '../widgets/enhanced_calorie_gauge.dart'; // 고도화된 게이지 위젯 import
import '../utils/meal_pattern_calorie_guide.dart'; // 식사 패턴 기반 칼로리 안내

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // UI가 완전히 렌더링된 후 웰컴 그리팅 및 자동 표정 로테이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        // 홈 화면 진입 시 웰컴 그리팅 표시
        appProvider.triggerWelcomeGreeting();
      }
    });

    // 1분마다 화면 갱신 (식사 안내 메시지 시간 업데이트)
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // BottomNavigationBar 아래까지 body 확장
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.homeTitle,
          style: const TextStyle(
            color: Colors.white, // 흰색으로 변경 → 네온 바탕에서 가장 또렷함
            fontWeight: FontWeight.w800, // 조금 더 굵게
            fontSize: 20,
            shadows: [
              Shadow(
                // 살짝만 그림자 주면 고급스러움 폭발
                offset: Offset(0, 1),
                blurRadius: 4,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        centerTitle: false, // 왼쪽 정렬로 더 모던하게
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00FF7F), // Spring Green (네온 민트)
                Color(0xFF00E676), // 조금 더 부드럽고 깊은 민트
                Color(0xFF00B76A), // 끝부분에 살짝 딥 그린으로 마무리 → 입체감 폭발
              ],
              stops: [0.0, 0.6, 1.0], // 중간을 길게 해서 부드럽게 흘러가게
            ),
          ),
        ),
        actions: [
          // 기록 보기 버튼
          IconButton(
            icon: const Icon(Icons.calendar_month),
            color: Colors.white,
            tooltip: AppLocalizations.of(context)!.viewRecords,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen()),
              );
            },
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.developer_mode),
              color: Colors.white,
              tooltip: AppLocalizations.of(context)!.developerTest,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PolygonTestScreen()),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9), // 연한 민트 초록 (Morning Forest)
              Color(0xFFFFFFFF), // 순백색
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            if (appProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              bottom: false, // BottomNavigationBar 영역 침범 허용
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 하단 여백 추가
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 환영 메시지
                    _buildWelcomeSection(appProvider),

                    const SizedBox(height: 24),

                    // 아바타와 칼로리 인디케이터
                    _buildAvatarSection(appProvider),

                    const SizedBox(height: 16),

                    // 식사 패턴 기반 칼로리 안내
                    _buildMealGuidanceCard(appProvider),

                    // 애니메이션 타입 선택 (제거됨)
                    // _buildAnimationControls(appProvider),
                    const SizedBox(height: 24),

                    // 빠른 액션 버튼들 (건강 챙기기)
                    _buildQuickActions(),

                    const SizedBox(height: 24),

                    // 오늘의 요약
                    _buildTodaySummary(appProvider),

                    const SizedBox(height: 24),

                    // 동기부여 메시지
                    _buildMotivationMessage(appProvider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withAlpha(230),
              const Color(0xFFE8F5E9), // 연한 민트
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E3B32).withAlpha(26),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: 0, // 현재 선택된 인덱스 (실제로는 페이지 이동하므로 큰 의미 없음)
            backgroundColor: Colors.transparent, // 투명 배경
            elevation: 0, // 그림자 제거
            selectedItemColor: const Color(
              0xFF5E97F6,
            ), // 선택된 아이템: Soft Royal Blue
            unselectedItemColor: const Color(
              0xFF90A4AE,
            ), // 선택 안 된 아이템: Blue Grey
            type: BottomNavigationBarType.fixed, // 아이템이 3개 이상일 때 고정
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.soup_kitchen_rounded),
                label: AppLocalizations.of(context)!.mealRecord,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.directions_run_rounded),
                label: AppLocalizations.of(context)!.exerciseRecord,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.monitor_weight_rounded),
                label: AppLocalizations.of(context)!.weightRecord,
              ),
            ],
            onTap: (index) async {
              switch (index) {
                case 0:
                  // 식사 기록 화면
                  print('🔍 [DEBUG] 식사 기록 화면 열기');
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FoodInputScreen()),
                  );

                  print('🔍 [DEBUG] 식사 기록 화면 닫힘, result: $result');

                  // 음식이 추가되었다면 세레모니 실행
                  if (result == true && context.mounted) {
                    print('✅ [DEBUG] 세레모니 트리거 조건 충족, triggerCeremony() 호출');
                    Provider.of<AppProvider>(
                      context,
                      listen: false,
                    ).triggerCeremony();
                    print('✅ [DEBUG] triggerCeremony() 호출 완료');
                  } else {
                    print(
                      '❌ [DEBUG] 세레모니 미실행 - result: $result, mounted: ${context.mounted}',
                    );
                  }
                  break;
                case 1:
                  // 운동 기록 화면
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ExerciseRecordScreen(),
                    ),
                  );
                  break;
                case 2:
                  // 체중 기록 화면
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WeightRecordScreen(),
                    ),
                  );
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AppProvider appProvider) {
    final l10n = AppLocalizations.of(context)!;
    final userName = appProvider.userProfile?.name ?? l10n.user;
    final currentHour = DateTime.now().hour;

    String greeting;
    if (currentHour < 12) {
      greeting = l10n.homeGreetingMorning;
    } else if (currentHour < 18) {
      greeting = l10n.homeGreetingAfternoon;
    } else {
      greeting = l10n.homeGreetingEvening;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(153), // 반투명 흰색 배경
        borderRadius: BorderRadius.circular(24), // 더 둥글게
        border: Border.all(
          color: const Color(0xFFA5D6A7).withAlpha(128),
        ), // 연한 초록 테두리
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(26), // 연한 초록 그림자
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withAlpha(128),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo/logowind.jpeg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeGreetingFormat(userName, greeting),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF37474F), // Dark Blue Grey (가독성 강화)
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeSubtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF546E7A), // Blue Grey
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 웨어러블 상태 배지
            const SizedBox(height: 12),
            _buildWearableStatusBadge(appProvider),
          ],
        ),
      ),
    );
  }

  /// 웨어러블 상태 배지 위젯
  Widget _buildWearableStatusBadge(AppProvider appProvider) {
    final l10n = AppLocalizations.of(context)!;

    // 현재 운동 중인 경우
    if (appProvider.currentActivityName != null) {
      return _buildActivityBadge(appProvider);
    }

    // 권한 없는 경우
    if (!appProvider.hasHealthPermission) {
      return GestureDetector(
        onTap: () async {
          final granted = await appProvider.requestHealthPermissions();
          if (granted && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ ${l10n.healthPermissionGranted}')),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0), // 연한 오렌지
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFB74D).withAlpha(128)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF57C00),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '⚠️ ${l10n.wearablePermissionRequired}',
                style: const TextStyle(
                  color: Color(0xFFF57C00),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.touch_app, color: Color(0xFFF57C00), size: 14),
            ],
          ),
        ),
      );
    }

    // 연결됨
    if (appProvider.isWearableConnected) {
      final platformName =
          appProvider.connectedPlatformName ?? l10n.healthPlatformName;
      final lastSync = appProvider.lastHealthSyncTime;
      String syncText = '';
      if (lastSync != null) {
        final diff = DateTime.now().difference(lastSync);
        if (diff.inMinutes < 1) {
          syncText = ' · ${l10n.syncedJustNow}';
        } else if (diff.inMinutes < 60) {
          syncText = ' · ${l10n.syncedMinutesAgo(diff.inMinutes)}';
        } else if (diff.inHours < 24) {
          syncText = ' · ${l10n.syncedHoursAgo(diff.inHours)}';
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9), // 연한 초록
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA5D6A7).withAlpha(128)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, color: Color(0xFF4CAF50), size: 16),
            const SizedBox(width: 6),
            Text(
              '🔗 $platformName$syncText',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // 미연결
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1), // 연한 회색
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB0BEC5).withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link_off, color: Color(0xFF78909C), size: 16),
          const SizedBox(width: 6),
          Text(
            '📴 ${l10n.notConnected}',
            style: const TextStyle(
              color: Color(0xFF78909C),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 운동 중 상태 배지 (운동별 맞춤 정보)
  Widget _buildActivityBadge(AppProvider appProvider) {
    final l10n = AppLocalizations.of(context)!;
    final activityName = appProvider.currentActivityName ?? '운동';
    final minutes = appProvider.currentActivityMinutes ?? 0;
    final calories = appProvider.currentActivityCalories ?? 0.0;
    final distance = appProvider.currentActivityDistance;

    // 운동별 아이콘 및 정보 설정
    IconData icon;
    String infoText;

    switch (activityName.toLowerCase()) {
      case 'walking':
        icon = Icons.directions_walk;
        infoText = distance != null
            ? '🚶 ${l10n.walking} ${distance.toStringAsFixed(1)}km · ${calories.toInt()}kcal'
            : '🚶 ${l10n.walking} $minutes${l10n.minutesShort} · ${calories.toInt()}kcal';
        break;
      case 'running':
        icon = Icons.directions_run;
        infoText =
            '🏃 ${l10n.running} $minutes${l10n.minutesShort} · ${calories.toInt()}kcal';
        break;
      case 'cycling':
        icon = Icons.directions_bike;
        infoText = distance != null
            ? '🚴 ${l10n.cycling} ${distance.toStringAsFixed(1)}km · ${calories.toInt()}kcal'
            : '🚴 ${l10n.cycling} $minutes${l10n.minutesShort} · ${calories.toInt()}kcal';
        break;
      case 'swimming':
        icon = Icons.pool;
        infoText =
            '🏊 ${l10n.swimming} $minutes${l10n.minutesShort} · ${calories.toInt()}kcal';
        break;
      default:
        icon = Icons.fitness_center;
        infoText = '💪 $activityName · ${calories.toInt()}kcal';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // 연한 파랑
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF90CAF9).withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF1976D2), size: 16),
          const SizedBox(width: 6),
          Text(
            infoText,
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(AppProvider appProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 420, // 게이지 공간 확보를 위해 높이 증가
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(179), // 반투명 흰색
        borderRadius: BorderRadius.circular(30), // 둥근 모서리 (구름 느낌)
        border: Border.all(
          color: const Color(0xFFA5D6A7).withAlpha(128),
        ), // 연한 초록 테두리
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(26), // 연한 초록 그림자
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center, // 기본적으로 중앙 정렬
        children: [
          // 1. 아바타 (주인공 - 정중앙, 약간 위로)
          Positioned(
            top: 20,
            bottom: 100, // 하단 게이지 공간 확보
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                final height = provider.getHeightFromProvider();
                final weight = provider.getWeightFromProvider();
                final bmi = weight / ((height / 100) * (height / 100));

                return AdvancedAvatarWidget(
                  bmi: bmi,
                  height: height,
                  gender: provider.getGenderFromProvider(),
                  lifestyle: _mapActivityLevelToLifestylePattern(
                    provider.userProfile?.activityLevel ?? 'moderate',
                  ),
                  clothingColors: provider.userProfile?.getClothingColors(),
                  expression: provider.currentExpression,
                  pose: provider.currentPose,
                );
              },
            ),
          ),

          // 2. Enhanced Calorie Gauge (하단 배치)
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: AnimatedCalorieGauge(
              current: appProvider.totalCalories,
              goal: appProvider.dailyCalorieGoal,
              burned: appProvider.currentBurnedCalories, // 운동 소모
              tdeeBurned: appProvider.tdeeBurnedCalories, // TDEE 소모
              height: 36,
              showLabel: true,
              mealPattern: appProvider.userProfile
                  ?.getMealPattern(), // 식사 패턴 전달
            ),
          ),

          // 3. 오른쪽 상단 설정 버튼
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF546E7A)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),

          // 4. 수면 모드 표시 (왼쪽 상단)
          if (appProvider.isSleepMode)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5).withAlpha(204), // Indigo 80%
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bedtime_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.sleepMode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClothingButton() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9).withAlpha(230), // 연한 민트 배경
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E3B32).withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.checkroom_rounded,
          color: Color(0xFF37474F),
        ), // Dark Blue Grey 아이콘
        tooltip: l10n.changeClothingColor,
        iconSize: 24,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ClothingSettingsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildCalorieInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF66BB6A)), // Soft Green
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF546E7A), // Blue Grey
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF37474F), // Dark Blue Grey
          ),
        ),
      ],
    );
  }

  /// 식사 패턴 기반 칼로리 안내 카드
  Widget _buildMealGuidanceCard(AppProvider appProvider) {
    final l10n = AppLocalizations.of(context)!;
    final guidance = MealPatternCalorieGuide.getGuidance(
      mealPattern: appProvider.userProfile?.getMealPattern(),
      dailyGoal: appProvider.dailyCalorieGoal,
      currentIntake: appProvider.totalCalories,
      l10n: l10n,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            guidance.isLow
                ? const Color(0xFFFFF3E0) // 부족: 따뜻한 오렌지
                : guidance.isHigh
                ? const Color(0xFFFFEBEE) // 초과: 부드러운 빨강
                : const Color(0xFFE8F5E9), // 적정: 연한 민트
            Colors.white.withAlpha(230),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: guidance.isLow
              ? const Color(0xFFFFB74D).withAlpha(128)
              : guidance.isHigh
              ? const Color(0xFFEF5350).withAlpha(128)
              : const Color(0xFFA5D6A7).withAlpha(128),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E3B32).withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: guidance.isLow
                      ? const Color(0xFFF57C00)
                      : guidance.isHigh
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF4CAF50),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '🍽️ ${l10n.mealGuidance}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 메시지
            Text(
              guidance.message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF546E7A),
                height: 1.5,
              ),
            ),

            // 다음 식사 정보
            if (guidance.nextMealName != null &&
                guidance.caloriesUntilNextMeal != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(179),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB0BEC5).withAlpha(100),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: Color(0xFF546E7A),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '💡 ${guidance.nextMealName}(${guidance.nextMealTime ?? "--:--"})${l10n.until} '
                        '${guidance.caloriesUntilNextMeal != null ? (guidance.caloriesUntilNextMeal! / 50).round() * 50 : 0}kcal '
                        '${(guidance.caloriesUntilNextMeal ?? 0) > 0 ? l10n.moreNeeded : l10n.reduceIntake}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF37474F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActionsTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF37474F), // Dark Blue Grey
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                l10n.mealRecordButton,
                Icons.soup_kitchen_rounded, // 음식 아이콘
                () async {
                  print('🔍 [DEBUG] 식사 기록 ActionButton 클릭');
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FoodInputScreen()),
                  );

                  print('🔍 [DEBUG] 식사 기록 ActionButton 닫힘, result: $result');

                  // 음식이 추가되었다면 세레모니 실행
                  if (result == true && context.mounted) {
                    print(
                      '✅ [DEBUG] ActionButton 세레모니 트리거, triggerCeremony() 호출',
                    );
                    Provider.of<AppProvider>(
                      context,
                      listen: false,
                    ).triggerCeremony();
                    print('✅ [DEBUG] ActionButton triggerCeremony() 호출 완료');
                  } else {
                    print(
                      '❌ [DEBUG] ActionButton 세레모니 미실행 - result: $result, mounted: ${context.mounted}',
                    );
                  }
                },
                const Color(0xFFA5D6A7), // 연한 초록 배경
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                l10n.exerciseRecordButton,
                Icons.directions_run_rounded, // 운동 아이콘
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ExerciseRecordScreen(),
                    ),
                  );
                },
                const Color(0xFFFFCC80), // 연한 오렌지 배경
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                l10n.weightRecordButton,
                Icons.monitor_weight_rounded, // 둥근 아이콘
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WeightRecordScreen(),
                    ),
                  );
                },
                const Color(0xFF90CAF9), // 연한 파랑 배경
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color backgroundColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20), // 둥근 모서리
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withAlpha(102),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: const Color(0xFF37474F),
            ), // Dark Blue Grey 아이콘
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF37474F), // Dark Blue Grey 텍스트
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(AppProvider appProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(153),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA5D6A7).withAlpha(77)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayHealthNote,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3B32),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  l10n.bmiLabel,
                  appProvider.bmi.toStringAsFixed(1),
                  _getBMIStatus(appProvider.bmi),
                ),
                _buildSummaryItem(
                  l10n.weightLabel,
                  '${appProvider.userProfile?.initialWeight.toStringAsFixed(1)} kg',
                  l10n.currentLabel,
                ),
                _buildSummaryItem(
                  l10n.dailyGoalLabel,
                  '${appProvider.dailyCalorieGoal.toInt()} kcal',
                  l10n.goalLabel,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 운동 칼로리 및 순 칼로리 (AppProvider 사용으로 통일)
            Builder(
              builder: (context) {
                final intakeCalories = appProvider.totalCalories;
                final burnedCalories =
                    appProvider.totalBurnedCalories; // TDEE 포함 전체 소모
                final netCalories = appProvider.netCalories; // 순 칼로리 (현재 칼로리)

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      l10n.intakeLabel,
                      '${intakeCalories.toInt()} kcal',
                      l10n.todayLabel,
                    ),
                    _buildSummaryItem(
                      l10n.burnedLabel,
                      '${burnedCalories.toInt()} kcal',
                      l10n.totalLabel, // 운동 + TDEE
                    ),
                    _buildSummaryItem(
                      l10n.netCaloriesLabel, // 용어 변경
                      '${netCalories.toInt()} kcal',
                      netCalories > 0 ? l10n.surplusLabel : l10n.deficitLabel,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 오늘 소모한 칼로리 가져오기
  Future<double> _getTodayBurnedCalories() async {
    try {
      final dbService = DatabaseService();
      final today = DateTime.now().toIso8601String().split('T')[0];
      return await dbService.getTotalBurnedCaloriesForDate(today);
    } catch (e) {
      return 0.0;
    }
  }

  Widget _buildSummaryItem(String label, String value, String subtitle) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF546E7A), // Blue Grey
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3B32), // Dark Forest Green
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF81C784), // Light Green
          ),
        ),
      ],
    );
  }

  String _getBMIStatus(double bmi) {
    final l10n = AppLocalizations.of(context)!;
    if (bmi < 18.5) return l10n.bmiUnderweight;
    if (bmi < 25) return l10n.bmiNormal;
    if (bmi < 30) return l10n.bmiOverweight;
    return l10n.bmiObese;
  }

  Widget _buildMotivationMessage(AppProvider appProvider) {
    final l10n = AppLocalizations.of(context)!;
    String message;
    String icon;
    Color backgroundColor;

    if (appProvider.isOverCalorieLimit) {
      message = l10n.motivationOverLimit;
      icon = '🍃';
      backgroundColor = const Color(0xFFFFF3E0); // 연한 오렌지 (따뜻함)
    } else if (appProvider.isNearLimit) {
      message = l10n.motivationNearLimit;
      icon = '✨';
      backgroundColor = const Color(0xFFFFF9C4); // 연한 노랑 (햇살)
    } else {
      message = l10n.motivationGood;
      icon = '🌱';
      backgroundColor = const Color(0xFFE8F5E9); // 연한 초록 (평온)
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E3B32), // 짙은 숲색
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 활동량 레벨을 LifestylePattern으로 변환
  LifestylePattern _mapActivityLevelToLifestylePattern(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return LifestylePattern.sedentary;
      case 'light':
      case 'moderate':
      case 'active':
        return LifestylePattern.active;
      case 'very_active':
        return LifestylePattern.athletic;
      default:
        return LifestylePattern.active;
    }
  }

  /// 🌟 칼로리 상태별 오라 색상 결정
  Color _getAuraColor(double current, double goal) {
    final l10n = AppLocalizations.of(context)!;
    if (goal == 0) return Colors.transparent;

    final percentage = current / goal;

    if (percentage >= 0.8 && percentage <= 1.0) {
      return Colors.green; // 🟢 이상적
    } else if (percentage > 1.0 && percentage <= 1.2) {
      return Colors.orange; // 🟡 경고
    } else if (percentage > 1.2) {
      return Colors.red; // 🔴 과식
    } else if (percentage < 0.5) {
      return Colors.blue; // 💙 저칼로리
    }

    return Colors.transparent; // 보통 (50-80%)
  }
}

/// 🌟 아바타 + 오라 효과 위젯
class _AvatarWithAura extends StatefulWidget {
  final Color auraColor;
  final Widget child;

  const _AvatarWithAura({required this.auraColor, required this.child});

  @override
  State<_AvatarWithAura> createState() => _AvatarWithAuraState();
}

class _AvatarWithAuraState extends State<_AvatarWithAura>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 20.0, end: 35.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.auraColor == Colors.transparent) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 오라 레이어 (배경)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.auraColor.withOpacity(0.3),
                    blurRadius: _pulseAnimation.value,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: widget.auraColor.withOpacity(0.1),
                    blurRadius: _pulseAnimation.value + 10,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // 아바타 레이어 (전경)
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
