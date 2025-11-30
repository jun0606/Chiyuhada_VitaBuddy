import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode 사용
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/calorie_indicator.dart';
import '../widgets/advanced_avatar_widget.dart';
import '../avatar/body_measurements.dart';
import '../avatar/avatar_animations.dart';
import '../services/database_service.dart'; // 데이터베이스 서비스
import 'food_input_screen.dart';
import 'weight_record_screen.dart';
import 'clothing_settings_screen.dart';
import 'exercise_record_screen.dart'; // 운동 기록 화면
import 'settings_screen.dart'; // 설정 화면
import 'history_screen.dart'; // 기록 화면
import 'polygon_test_screen.dart'; // 개발자 테스트 화면
import '../widgets/enhanced_calorie_gauge.dart'; // 고도화된 게이지 위젯 import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // UI가 완전히 렌더링된 후 자동 표정 로테이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        appProvider.startAutoExpressionRotation();
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // BottomNavigationBar 아래까지 body 확장
      appBar: AppBar(
  title: const Text(
    '치유하다 VitaBuddy',
    style: TextStyle(
      color: Colors.white,        // 흰색으로 변경 → 네온 바탕에서 가장 또렷함
      fontWeight: FontWeight.w800, // 조금 더 굵게
      fontSize: 20,
      shadows: [
        Shadow(                           // 살짝만 그림자 주면 고급스러움 폭발
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
          Color(0xFF00FF7F),  // Spring Green (네온 민트)
          Color(0xFF00E676),  // 조금 더 부드럽고 깊은 민트
          Color(0xFF00B76A),  // 끝부분에 살짝 딥 그린으로 마무리 → 입체감 폭발
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
      tooltip: '기록 보기',
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
        tooltip: '개발자 테스트 화면',
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
              Color(0xFFE8F5E9),  // 연한 민트 초록 (Morning Forest)
              Color(0xFFFFFFFF),  // 순백색
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
              Colors.white.withOpacity(0.9),
              const Color(0xFFE8F5E9), // 연한 민트
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E3B32).withOpacity(0.1),
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
            selectedItemColor: const Color(0xFF5E97F6), // 선택된 아이템: Soft Royal Blue
            unselectedItemColor: const Color(0xFF90A4AE), // 선택 안 된 아이템: Blue Grey
            type: BottomNavigationBarType.fixed, // 아이템이 3개 이상일 때 고정
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.soup_kitchen_rounded), label: '식사 기록'),
              BottomNavigationBarItem(icon: Icon(Icons.directions_run_rounded), label: '운동 기록'),
              BottomNavigationBarItem(icon: Icon(Icons.monitor_weight_rounded), label: '체중 기록'),
            ],
            onTap: (index) async {
              switch (index) {
                case 0:
                  // 식사 기록 화면
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FoodInputScreen()),
                  );

                  // 음식이 추가되었다면 세레모니 실행
                  if (result == true && context.mounted) {
                    Provider.of<AppProvider>(context, listen: false).triggerCeremony();
                  }
                  break;
                case 1:
                  // 운동 기록 화면
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExerciseRecordScreen()),
                  );
                  break;
                case 2:
                  // 체중 기록 화면
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WeightRecordScreen()),
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
    final userName = appProvider.userProfile?.name ?? '사용자';
    final currentHour = DateTime.now().hour;

    String greeting;
    if (currentHour < 12) {
      greeting = '상쾌한 아침이에요!';
    } else if (currentHour < 18) {
      greeting = '나른한 오후, 힘내세요!';
    } else {
      greeting = '오늘 하루도 수고했어요!';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // 반투명 흰색 배경
        borderRadius: BorderRadius.circular(24), // 더 둥글게
        border: Border.all(color: const Color(0xFFA5D6A7).withOpacity(0.5)), // 연한 초록 테두리
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1), // 연한 초록 그림자
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.5),
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
                    '$userName님, $greeting',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37474F), // Dark Blue Grey (가독성 강화)
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '오늘도 편안한 마음으로 건강을 챙겨봐요.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF546E7A), // Blue Grey
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildAvatarSection(AppProvider appProvider) {
    return Container(
      height: 420, // 게이지 공간 확보를 위해 높이 증가
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7), // 반투명 흰색
        borderRadius: BorderRadius.circular(30), // 둥근 모서리 (구름 느낌)
        border: Border.all(color: const Color(0xFFA5D6A7).withOpacity(0.5)), // 연한 초록 테두리
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1), // 연한 초록 그림자
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
                    provider.userProfile?.activityLevel ?? 'moderate'
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
              current: appProvider.currentCalories,
              goal: appProvider.dailyCalorieGoal,
              burned: appProvider.currentBurnedCalories, // 운동 소모
              tdeeBurned: appProvider.tdeeBurnedCalories, // TDEE 소모
              height: 36,
              showLabel: true,
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
          
          // ⚡ 플래시 효과 오버레이 (임시 비활성화)
          /*
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              if (provider.flashEvent == null) return const SizedBox();
              
              final flashColor = provider.flashEvent == 'food'
                  ? Colors.green.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3);
              
              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Container(
                    color: flashColor.withOpacity(value * 0.3),
                  );
                },
              );
            },
          ),
          */
        ],
      ),
    );
  }



  Widget _buildClothingButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9).withOpacity(0.9), // 연한 민트 배경
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E3B32).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.checkroom_rounded, color: Color(0xFF37474F)), // Dark Blue Grey 아이콘
        tooltip: '옷 색상 변경',
        iconSize: 24,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ClothingSettingsScreen(),
            ),
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
          )
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

 Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '건강 챙기기', // 문구 변경
          style: TextStyle(
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
                '식사 기록',
                Icons.soup_kitchen_rounded, // 음식 아이콘
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FoodInputScreen()),
                  );
                },
                const Color(0xFFA5D6A7), // 연한 초록 배경
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                '운동 기록',
                Icons.directions_run_rounded, // 운동 아이콘
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExerciseRecordScreen()),
                  );
                },
                const Color(0xFFFFCC80), // 연한 오렌지 배경
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                '체중 기록',
                Icons.monitor_weight_rounded, // 둥근 아이콘
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WeightRecordScreen()),
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
            color: backgroundColor.withOpacity(0.4),
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
            Icon(icon, size: 28, color: const Color(0xFF37474F)), // Dark Blue Grey 아이콘
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA5D6A7).withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 건강 노트',
              style: TextStyle(
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
                  'BMI',
                  appProvider.bmi.toStringAsFixed(1),
                  _getBMIStatus(appProvider.bmi),
                ),
                _buildSummaryItem(
                  '체중',
                  '${appProvider.userProfile?.initialWeight.toStringAsFixed(1)} kg',
                  '현재',
                ),
                _buildSummaryItem(
                  '하루 권장 칼로리',
                  '${appProvider.dailyCalorieGoal.toInt()} kcal',
                  '목표',
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
                final burnedCalories = appProvider.totalBurnedCalories; // TDEE 포함 전체 소모
                final netCalories = appProvider.netCalories; // 순 칼로리 (현재 칼로리)
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      '섭취',
                      '${intakeCalories.toInt()} kcal',
                      '오늘',
                    ),
                    _buildSummaryItem(
                      '소모',
                      '${burnedCalories.toInt()} kcal',
                      '전체', // 운동 + TDEE
                    ),
                    _buildSummaryItem(
                      '현재 칼로리', // 용어 변경
                      '${netCalories.toInt()} kcal',
                      netCalories > 0 ? '잉여' : '적자',
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
          )
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
    if (bmi < 18.5) return '저체중';
    if (bmi < 25) return '정상';
    if (bmi < 30) return '과체중';
    return '비만';
  }

  Widget _buildMotivationMessage(AppProvider appProvider) {
    String message;
    String icon;
    Color backgroundColor;

    if (appProvider.isOverCalorieLimit) {
      message = '괜찮아요, 내일 조금 더 움직이면 돼요. 🌿';
      icon = '🍃';
      backgroundColor = const Color(0xFFFFF3E0); // 연한 오렌지 (따뜻함)
    } else if (appProvider.isNearLimit) {
      message = '오늘 하루, 정말 열심히 보냈군요! ☀️';
      icon = '✨';
      backgroundColor = const Color(0xFFFFF9C4); // 연한 노랑 (햇살)
    } else {
      message = '당신의 속도대로 가고 있어요. 아주 잘하고 있습니다. 👏';
      icon = '🌱';
      backgroundColor = const Color(0xFFE8F5E9); // 연한 초록 (평온)
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
  
  const _AvatarWithAura({
    required this.auraColor,
    required this.child,
  });
  
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
