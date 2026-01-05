import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_profile.dart'; // UserProfileAdapter 등록용
import 'screens/splash_screen.dart';
import 'screens/enhanced_profile_setup_screen.dart';
// 검증용 임포트
import 'services/notification_service.dart'; // 알림 서비스

void main() async {
  // 반드시 실행되는 강력한 로그들
  print('🚀 === VITA BUDDY APP START ===');
  print('🚀 VITA BUDDY MAIN START - PRINT');
  debugPrint('🚀 VITA BUDDY MAIN START - DEBUG PRINT');

  WidgetsFlutterBinding.ensureInitialized();

  print('📱 Flutter 바인딩 초기화 완료 - PRINT');
  debugPrint('📱 Flutter 바인딩 초기화 완료 - DEBUG PRINT');

  // 알림 서비스 초기화
  await NotificationService().initialize();

  // Hive 초기화 (앱 시작 시 최우선 실행)
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserProfileAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(SleepConfigAdapter());
  }
  print('💾 Hive 초기화 및 어댑터 등록 완료');

  // 앱 프로바이더 초기화
  final appProvider = AppProvider();
  await appProvider.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => appProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return MaterialApp(
      title: 'Chiyuhada VitaBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7), // 시원한 하늘색
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',

        // 배경색을 더 자연스럽게
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),

        // 앱바 테마
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

        // 버튼 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // 입력 필드 테마
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),

        // 카드 테마
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),

      // 다국어 지원
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'), // 한국어
        Locale('en'), // 영어
        Locale('ja'), // 일본어
        Locale('id'), // 인도네시아어
        Locale('ms'), // 말레이시아어
      ],
      locale: appProvider.locale, // 동적 언어 설정 적용

      home: const SplashScreen(),
      routes: {
        '/profile-setup': (context) => const EnhancedProfileSetupScreen(),
      },
      // home: const PolygonTestScreen(), // 개발자 테스트용 (디버그: HomeScreen의 개발자 아이콘 사용)
    );
  }
}
