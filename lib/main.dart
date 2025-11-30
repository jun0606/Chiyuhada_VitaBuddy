import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/polygon_test_screen.dart'; // 검증용 임포트
import 'services/notification_service.dart'; // 알림 서비스

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 서비스 초기화
  await NotificationService().initialize();

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
    return MaterialApp(
      title: '치유하다 VitaBuddy',
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
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어
      ],
      locale: const Locale('ko', 'KR'), // 기본 한국어

      home: const SplashScreen(),
      // home: const PolygonTestScreen(), // 개발자 테스트용 (디버그: HomeScreen의 개발자 아이콘 사용)
    );
  }
}
