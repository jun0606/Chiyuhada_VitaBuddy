import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/health_data_service.dart';
import '../services/food_search_service.dart';
import '../l10n/app_localizations.dart';
import 'clothing_settings_screen.dart';
import 'profile_edit_screen.dart';
import 'notification_settings_screen.dart';
import 'calorie_goal_settings_screen.dart';
import 'sleep_settings_screen.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFCFD8DC), // 연한 회색
                Color(0xFFECEFF1), // 더 연한 회색
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingsItem(
              context,
              l10n.calorieGoalSettings,
              Icons.flag_rounded,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalorieGoalSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              l10n.languageSettings,
              Icons.language_rounded,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const LanguageSelectionScreen(isFirstRun: false),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              l10n.sleepSettings,
              Icons.bedtime_rounded,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SleepSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              l10n.avatarClothingSettings,
              Icons.checkroom_rounded,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClothingSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              l10n.profileEdit,
              Icons.person_rounded,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              l10n.notificationSettings,
              Icons.notifications_rounded,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              l10n.permissionDiagnosis,
              Icons.bug_report_rounded,
              () async {
                final healthService = HealthDataService();
                final appProvider = Provider.of<AppProvider>(
                  context,
                  listen: false,
                );

                // 권한 상태 확인 (실시간으로 다시 확인)
                final activityStatus =
                    await Permission.activityRecognition.status;
                final sensorStatus = await Permission.sensors.status; // 선택사항
                final healthDataPermission = await healthService
                    .hasPermissions();

                // 활동 인식과 헬스 데이터 권한만 필수로 체크 (센서는 선택사항)
                final needsPermission =
                    !activityStatus.isGranted || !healthDataPermission;

                // 상세 진단 실행
                final diagnosis = await healthService.diagnosePermissions();

                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.permissionDiagnosisResults),
                      content: SingleChildScrollView(child: Text(diagnosis)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.close),
                        ),
                        if (needsPermission) // 권한이 부족할 때만 표시
                          ElevatedButton(
                            onPressed: () async {
                              // 다이얼로그 닫기
                              Navigator.pop(context);

                              // 시스템 앱 설정 화면으로 이동
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    '앱 설정 화면으로 이동합니다...\n필요한 권한들을 허용해주세요.',
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );

                              // 약간의 지연 후 앱 설정 화면 열기
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              await openAppSettings();
                            },
                            child: const Text('권한 설정'),
                          ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              l10n.clearPermissionCache,
              Icons.refresh_rounded,
              () async {
                final healthService = HealthDataService();
                await healthService.clearPermissionCache();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.permissionCacheCleared)),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              l10n.healthDataPermission,
              Icons.health_and_safety_rounded,
              () async {
                final appProvider = Provider.of<AppProvider>(
                  context,
                  listen: false,
                );
                final healthService = HealthDataService();

                // 권한 상태 확인
                final hasPermission = await healthService.hasPermissions();

                if (hasPermission) {
                  // 권한이 있으면 바로 동기화 실행
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.syncingHealthData)),
                  );
                  final result = await appProvider.syncHealthData();
                  final message = result['message'] as String? ?? '동기화 완료';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                  return;
                }

                // 권한이 없으면 권한 요청
                final permissionGranted = await healthService
                    .requestPermissions();

                if (permissionGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.healthPermissionGranted)),
                  );

                  // 권한 얻었으면 동기화 시도
                  await appProvider.syncHealthData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.healthPermissionDenied),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              'USDA API 키 설정',
              Icons.api_rounded,
              () => _showUsdaApiKeyDialog(context),
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              AppLocalizations.of(context)!.timezoneSettings,
              Icons.schedule,
              () => _showTimezoneDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsdaApiKeyDialog(BuildContext context) async {
    final foodSearchService = FoodSearchService();
    final currentApiKey = await foodSearchService.getUsdaApiKey();

    final controller = TextEditingController(text: currentApiKey ?? '');

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('USDA FoodData Central API 키'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'USDA FoodData Central API를 사용하기 위한 API 키를 입력하세요.\n'
                'API 키는 https://fdc.nal.usda.gov/api-key-signup/ 에서 무료로 발급받을 수 있습니다.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'API 키',
                  hintText: 'API 키를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // API 키 보안
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                final apiKey = controller.text.trim();
                if (apiKey.isNotEmpty) {
                  await foodSearchService.setUsdaApiKey(apiKey);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API 키가 저장되었습니다')),
                    );
                  }
                } else {
                  // 빈 값이면 기존 키 삭제
                  await foodSearchService.setUsdaApiKey('');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API 키가 삭제되었습니다')),
                    );
                  }
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      );
    }
  }

  void _showTimezoneDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final availableTimezones = appProvider.availableTimezones;

    // 선택된 타임존이 사용 가능한 목록에 있는지 확인
    String selectedTimezone = appProvider.timezoneName;
    if (!availableTimezones.contains(selectedTimezone)) {
      // 목록에 없으면 기본값(Asia/Seoul)으로 설정
      selectedTimezone = availableTimezones.contains('Asia/Seoul')
          ? 'Asia/Seoul'
          : (availableTimezones.isNotEmpty ? availableTimezones.first : 'UTC');
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.selectTimezone),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.timezoneNotificationAdjustment,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTimezone,
                  decoration: InputDecoration(
                    labelText: l10n.timezoneSettings,
                    border: const OutlineInputBorder(),
                  ),
                  items: availableTimezones.map((timezone) {
                    return DropdownMenuItem<String>(
                      value: timezone,
                      child: Text(_formatTimezoneName(timezone)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedTimezone = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await appProvider.setTimezone(selectedTimezone);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.timezoneSet(selectedTimezone))),
                  );
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimezoneName(String timezone) {
    // 시간대 이름을 더 읽기 쉽게 포맷팅
    final parts = timezone.split('/');
    if (parts.length >= 2) {
      final region = parts[0];
      final city = parts[1].replaceAll('_', ' ');
      return '$city ($region)';
    }
    return timezone;
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFECEFF1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF455A64)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF455A64),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFB0BEC5),
        ),
        onTap: onTap,
      ),
    );
  }
}
