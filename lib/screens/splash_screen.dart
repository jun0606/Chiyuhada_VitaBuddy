import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/health_data_service.dart';
import 'enhanced_profile_setup_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // 3초 후 다음 화면으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    if (appProvider.isProfileComplete) {
      // 프로필이 완성된 경우 헬스 데이터 권한 확인
      final healthService = HealthDataService();
      final hasPermission = await healthService.hasPermissions();

      if (!hasPermission && mounted) {
        // 권한이 없으면 다이얼로그 표시
        await _showHealthPermissionDialog();
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // 🌟 고급 프로필 설정 화면 사용
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EnhancedProfileSetupScreen()),
        );
      }
    }
  }

  Future<void> _showHealthPermissionDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 방지
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.green),
              SizedBox(width: 8),
              Text('헬스 데이터 권한'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '앱에서 웨어러블 기기와의 칼로리 동기화를 위해 건강 데이터 접근 권한이 필요합니다.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text('권한 허용 시:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• 걸음 수 및 칼로리 소모량 자동 동기화'),
              Text('• 운동 기록 자동 가져오기'),
              Text('• 더 정확한 칼로리 관리'),
              SizedBox(height: 16),
              Text(
                '권한을 거부해도 앱의 기본 기능은 사용할 수 있습니다.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 나중에 요청
              },
              child: const Text('나중에'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기

                // 권한 요청
                final healthService = HealthDataService();
                final permissionGranted = await healthService
                    .requestPermissions();

                if (permissionGranted && mounted) {
                  // 권한 얻었으면 동기화 시도
                  final appProvider = Provider.of<AppProvider>(
                    context,
                    listen: false,
                  );
                  await appProvider.syncHealthData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('헬스 데이터 권한이 허용되었습니다')),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('헬스 데이터 권한이 거부되었습니다. 설정에서 허용해주세요'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('권한 허용'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 로고
                Image.asset(
                  'assets/logo/logowind.jpeg',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                // 앱 이름
                Text(
                  '치유하다 VitaBuddy',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // 태그라인
                Text(
                  '건강한 삶의 동반자',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black.withAlpha(204), // 0.8 opacity
                  ),
                ),
                const SizedBox(height: 48),
                // 로딩 인디케이터
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
