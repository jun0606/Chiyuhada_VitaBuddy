import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/health_data_service.dart';
import '../l10n/app_localizations.dart';
import 'enhanced_profile_setup_screen.dart';
import 'home_screen.dart';
import 'language_selection_screen.dart';

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

    // 언어 설정이 안 되어 있으면 언어 선택 화면으로 이동
    if (!appProvider.isLanguageSet) {
      if (mounted) {
        // flutter analyze 오류 방지: SplashScreen과 같은 폴더에 없으면 import 필요.
        // 하지만 여기선 같은 screens 패키지 내라면 import만 추가하면 됨.
        // 상단에 import '../screens/language_selection_screen.dart'; 추가 필요.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen(isFirstRun: true)),
        );
      }
      return;
    }

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
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 방지
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.health_and_safety, color: Colors.green),
              const SizedBox(width: 8),
              Text(l10n.healthDataPermission),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.healthPermissionContent,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(l10n.healthPermissionAllowInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.healthPermissionInfo1),
              Text(l10n.healthPermissionInfo2),
              Text(l10n.healthPermissionInfo3),
              const SizedBox(height: 16),
              Text(
                l10n.healthPermissionDenyInfo,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 나중에 요청
              },
              child: Text(l10n.later),
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

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.healthPermissionGranted)),
                    );
                  }
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.healthPermissionDenied),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text(l10n.allowPermission),
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
                  AppLocalizations.of(context)!.homeTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // 태그라인
                Text(
                  AppLocalizations.of(context)!.homeSubtitle,
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
