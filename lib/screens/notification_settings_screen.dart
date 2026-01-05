import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart'; // 권한 관리 추가
import '../l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../utils/water_recommendation.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationSettings _settings;
  bool _isLoading = true;
  late TextEditingController _waterGoalController; // 수분 목표 컨트롤러 추가

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _waterGoalController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('notification_settings');

    if (settingsJson != null) {
      final map = jsonDecode(settingsJson) as Map<String, dynamic>;
      _settings = NotificationSettings.fromMap(map);
    } else {
      _settings = NotificationSettings();
    }

    // 수분 목표 컨트롤러 초기화
    _waterGoalController = TextEditingController(
      text: _settings.dailyWaterGoal.toString(),
    );

    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(_settings.toMap());
    await prefs.setString('notification_settings', settingsJson);

    // 백그라운드 서비스용 별도 저장 (Phase 13)
    await prefs.setString('alert_sensitivity', _settings.alertSensitivity);

    // 알람 적용
    await _applyNotifications();
  }

  Future<void> _applyNotifications() async {
    final service = NotificationService();

    // 식사 알람
    if (_settings.breakfastEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.breakfast,
        title: NotificationLocalizations.getMealTitle('breakfast'),
        body: NotificationLocalizations.getMealBody('breakfast'),
        time: _settings.breakfastTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.breakfast);
    }

    if (_settings.lunchEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.lunch,
        title: NotificationLocalizations.getMealTitle('lunch'),
        body: NotificationLocalizations.getMealBody('lunch'),
        time: _settings.lunchTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.lunch);
    }

    if (_settings.dinnerEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.dinner,
        title: NotificationLocalizations.getMealTitle('dinner'),
        body: NotificationLocalizations.getMealBody('dinner'),
        time: _settings.dinnerTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.dinner);
    }

    // 간식 알람
    if (_settings.morningSnackEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.morningSnack,
        title: NotificationLocalizations.getSnackTitle('morning'),
        body: NotificationLocalizations.getSnackBody(),
        time: _settings.morningSnackTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.morningSnack);
    }

    if (_settings.afternoonSnackEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.afternoonSnack,
        title: NotificationLocalizations.getSnackTitle('afternoon'),
        body: NotificationLocalizations.getSnackBody(),
        time: _settings.afternoonSnackTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.afternoonSnack);
    }

    // 운동 알람
    if (_settings.exerciseEnabled) {
      await service.scheduleWeeklyNotification(
        baseId: NotificationIds.exercise,
        title: NotificationLocalizations.getExerciseTitle(),
        body: NotificationLocalizations.getExerciseBody(),
        time: _settings.exerciseTime,
        weekdays: _settings.exerciseDays,
      );
    } else {
      for (int i = 0; i < 7; i++) {
        await service.cancelNotification(NotificationIds.exercise + i);
      }
    }

    // 체중 측정 알람
    if (_settings.weightEnabled) {
      await service.scheduleWeightCheckReminder(
        hour: _settings.weightTime.hour,
        minute: _settings.weightTime.minute,
      );
    } else {
      await service.cancelNotification(NotificationIds.weight);
    }

    // 비타민/보충제 알람 (기존 알람 먼저 취소)
    for (int i = 0; i < 3; i++) {
      await service.cancelNotification(NotificationIds.supplementBase + i);
    }
    for (int i = 0; i < _settings.supplements.length; i++) {
      final supplement = _settings.supplements[i];
      if (supplement.enabled) {
        await service.scheduleSupplementNotification(
          id: NotificationIds.supplementBase + i,
          supplementName: supplement.name,
          time: supplement.time,
        );
      }
    }

    // 수분 섭취 알람
    if (_settings.waterReminderEnabled) {
      await service.scheduleWaterReminders(
        start: _settings.waterStartTime,
        end: _settings.waterEndTime,
        intervalMinutes: _settings.waterInterval,
      );
    } else {
      for (int i = 0; i < 20; i++) {
        await service.cancelNotification(NotificationIds.waterBase + i);
      }
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay current,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final time = await showTimePicker(context: context, initialTime: current);

    if (time != null) {
      onTimeSelected(time);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 자동 저장
        await _saveSettings();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.notificationSettings),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFA5D6A7), // 연한 초록
                  Color(0xFFE8F5E9), // 더 연한 초록
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _saveSettings();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                AppLocalizations.of(context)!.save,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), // 하단 패딩 증가
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 시스템 알림 권한 상태
                _buildPermissionStatusCard(),
                const SizedBox(height: 24),

                // 알림 민감도 설정 (Phase 13)
                _buildSectionHeader(
                  AppLocalizations.of(context)!.energyAlertSensitivity,
                ),
                _buildSensitivityCard(),
                const SizedBox(height: 24),

                // 식사 알림 섹션
                _buildSectionHeader(
                  AppLocalizations.of(context)!.mealNotifications,
                ),
                _buildAlarmCard(
                  title: AppLocalizations.of(context)!.breakfastMeal,
                  enabled: _settings.breakfastEnabled,
                  time: _settings.breakfastTime,
                  onToggle: (value) {
                    setState(() => _settings.breakfastEnabled = value);
                  },
                  onTimeTap: () {
                    _selectTime(context, _settings.breakfastTime, (time) {
                      _settings.breakfastTime = time;
                    });
                  },
                ),
                _buildAlarmCard(
                  title: AppLocalizations.of(context)!.lunchMeal,
                  enabled: _settings.lunchEnabled,
                  time: _settings.lunchTime,
                  onToggle: (value) {
                    setState(() => _settings.lunchEnabled = value);
                  },
                  onTimeTap: () {
                    _selectTime(context, _settings.lunchTime, (time) {
                      _settings.lunchTime = time;
                    });
                  },
                ),
                _buildAlarmCard(
                  title: AppLocalizations.of(context)!.dinnerMeal,
                  enabled: _settings.dinnerEnabled,
                  time: _settings.dinnerTime,
                  onToggle: (value) {
                    setState(() => _settings.dinnerEnabled = value);
                  },
                  onTimeTap: () {
                    _selectTime(context, _settings.dinnerTime, (time) {
                      _settings.dinnerTime = time;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 간식 알림 섹션
                _buildSectionHeader(
                  AppLocalizations.of(context)!.snackNotifications,
                ),
                _buildAlarmCard(
                  title: AppLocalizations.of(context)!.morningSnack,
                  enabled: _settings.morningSnackEnabled,
                  time: _settings.morningSnackTime,
                  onToggle: (value) {
                    setState(() => _settings.morningSnackEnabled = value);
                  },
                  onTimeTap: () {
                    _selectTime(context, _settings.morningSnackTime, (time) {
                      _settings.morningSnackTime = time;
                    });
                  },
                ),
                _buildAlarmCard(
                  title: AppLocalizations.of(context)!.afternoonSnack,
                  enabled: _settings.afternoonSnackEnabled,
                  time: _settings.afternoonSnackTime,
                  onToggle: (value) {
                    setState(() => _settings.afternoonSnackEnabled = value);
                  },
                  onTimeTap: () {
                    _selectTime(context, _settings.afternoonSnackTime, (time) {
                      _settings.afternoonSnackTime = time;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 운동 알림 섹션
                _buildSectionHeader(
                  AppLocalizations.of(context)!.exerciseNotifications,
                ),
                _buildExerciseAlarmCard(),
                const SizedBox(height: 24),

                // 체중 측정 알림 섹션
                _buildSectionHeader(
                  AppLocalizations.of(context)!.weightMeasurementNotifications,
                ),
                _buildAlarmCard(
                  title: AppLocalizations.of(context)!.weightMeasurement,
                  enabled: _settings.weightEnabled,
                  time: _settings.weightTime,
                  onToggle: (value) {
                    setState(() => _settings.weightEnabled = value);
                  },
                  onTimeTap: () {
                    _selectTime(context, _settings.weightTime, (time) {
                      _settings.weightTime = time;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 비타민/보충제 알림 섹션
                _buildSectionHeader(
                  AppLocalizations.of(context)?.supplementNotifications ??
                      '비타민/보충제 알림',
                ),
                _buildSupplementsCard(),
                const SizedBox(height: 24),

                // 수분 섭취 관리 섹션
                _buildSectionHeader(
                  AppLocalizations.of(context)?.waterIntakeManagement ??
                      '수분 섭취 관리',
                ),
                _buildWaterReminderCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF455A64),
        ),
      ),
    );
  }

  Widget _buildAlarmCard({
    required String title,
    required bool enabled,
    required TimeOfDay time,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(time.format(context)),
        trailing: Switch(value: enabled, onChanged: onToggle),
        onTap: enabled ? onTimeTap : null,
      ),
    );
  }

  Widget _buildExerciseAlarmCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)?.exerciseTime ?? '운동 시간',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: _settings.exerciseEnabled,
                  onChanged: (value) {
                    setState(() => _settings.exerciseEnabled = value);
                  },
                ),
              ],
            ),
            if (_settings.exerciseEnabled) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  _selectTime(context, _settings.exerciseTime, (time) {
                    _settings.exerciseTime = time;
                  });
                },
                child: Text(
                  _settings.exerciseTime.format(context),
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.selectDays),
              const SizedBox(height: 8),
              _buildDaySelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final l10n = AppLocalizations.of(context)!;
    final days = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];

    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final dayNumber = index + 1; // 1=월, 7=일
        final isSelected = _settings.exerciseDays.contains(dayNumber);

        return ChoiceChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _settings.exerciseDays.add(dayNumber);
                _settings.exerciseDays.sort();
              } else {
                _settings.exerciseDays.remove(dayNumber);
              }
            });
          },
        );
      }),
    );
  }

  Widget _buildSensitivityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.energyDeficitAlertFrequency,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.adjustAlertFrequencyDesc,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSensitivityOption(
                  'low',
                  AppLocalizations.of(context)!.insensitive,
                  AppLocalizations.of(context)!.minimizeNotifications,
                ),
                const SizedBox(width: 8),
                _buildSensitivityOption(
                  'normal',
                  AppLocalizations.of(context)!.normal,
                  AppLocalizations.of(context)!.defaultSettings,
                ),
                const SizedBox(width: 8),
                _buildSensitivityOption(
                  'high',
                  AppLocalizations.of(context)!.sensitive,
                  AppLocalizations.of(context)!.frequentNotifications,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensitivityOption(String value, String label, String subLabel) {
    final isSelected = _settings.alertSensitivity == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _settings.alertSensitivity = value;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F5E9) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? const Color(0xFF388E3C)
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplementsCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)?.supplementNotifications ??
                      '비타민/보충제 알림',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addSupplement,
                  tooltip:
                      AppLocalizations.of(context)?.addSupplement ?? '보충제 추가',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_settings.supplements.isEmpty)
              Text(
                AppLocalizations.of(context)!.noSupplementsRegistered,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              )
            else
              ..._settings.supplements.map(
                (supplement) => _buildSupplementItem(supplement),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplementItem(SupplementAlarm supplement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplement.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  supplement.time.format(context),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: supplement.enabled,
            onChanged: (value) {
              setState(() {
                supplement.enabled = value;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _editSupplement(supplement),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _deleteSupplement(supplement),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterReminderCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)?.waterIntakeManagement ??
                        '수분 섭취 관리',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: _settings.waterReminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _settings.waterReminderEnabled = value;
                    });
                  },
                ),
              ],
            ),
            if (_settings.waterReminderEnabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      AppLocalizations.of(context)?.waterStartTime ?? '시작 시간',
                      _settings.waterStartTime,
                      (time) {
                        setState(() {
                          _settings.waterStartTime = time;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.waterInterval ??
                              '알림 간격 (분)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _settings.waterInterval,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [60, 90, 120, 180].map((interval) {
                            return DropdownMenuItem<int>(
                              value: interval,
                              child: Text(
                                '$interval${AppLocalizations.of(context)?.minutesUnit ?? '분'}',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _settings.waterInterval = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // 권장 수분량 표시 및 입력 필드
              FutureBuilder<UserProfile?>(
                future: _loadUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasData && snapshot.data != null) {
                    final profile = snapshot.data!;
                    final recommendedWater = 
                        WaterRecommendation.calculateRecommendedWater(profile);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 권장량 표시
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, 
                                size: 20, 
                                color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.recommendedWaterIntake,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '$recommendedWater ml',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .recommendedBasedOnProfile,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // 사용자 목표 입력 필드
                        TextField(
                          controller: _waterGoalController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.yourDailyGoal,
                            suffixText: 'ml',
                            border: const OutlineInputBorder(),
                            helperText: AppLocalizations.of(context)!.canAdjustManually,
                            helperMaxLines: 2,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final newGoal = int.tryParse(value);
                            if (newGoal != null && 
                                newGoal >= 1000 && 
                                newGoal <= 5000) {
                              setState(() {
                                _settings.dailyWaterGoal = newGoal;
                              });
                            }
                          },
                        ),
                        
                        // 권장량 적용 버튼 (현재 목표와 권장량이 다를 때만 표시)
                        if (_settings.dailyWaterGoal != recommendedWater)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _settings.dailyWaterGoal = recommendedWater;
                                    _waterGoalController.text = 
                                        recommendedWater.toString();
                                  });
                                },
                                icon: const Icon(Icons.auto_fix_high, size: 18),
                                label: Text(
                                  AppLocalizations.of(context)!.useRecommendedAmount,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green[700],
                                  side: BorderSide(color: Colors.green[300]!),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  
                  // 프로필이 없는 경우 기본 표시
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _waterGoalController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.yourDailyGoal,
                          suffixText: 'ml',
                          border: const OutlineInputBorder(),
                          helperText: AppLocalizations.of(context)!.canAdjustManually,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newGoal = int.tryParse(value);
                          if (newGoal != null && 
                              newGoal >= 1000 && 
                              newGoal <= 5000) {
                            setState(() {
                              _settings.dailyWaterGoal = newGoal;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '프로필을 설정하면 맞춤 권장량을 확인할 수 있습니다',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 사용자 프로필 로드
  Future<UserProfile?> _loadUserProfile() async {
    try {
      final box = await Hive.openBox<UserProfile>('profile');
      return box.get('user_profile');
    } catch (e) {
      return null;
    }
  }

  Widget _buildTimeField(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onTimeSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context, time, onTimeSelected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(context)),
                const Icon(Icons.access_time, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addSupplement() {
    _showSupplementDialog();
  }

  void _editSupplement(SupplementAlarm supplement) {
    _showSupplementDialog(existingSupplement: supplement);
  }

  void _deleteSupplement(SupplementAlarm supplement) {
    setState(() {
      _settings.supplements.remove(supplement);
    });
  }

  void _showSupplementDialog({SupplementAlarm? existingSupplement}) {
    final nameController = TextEditingController(
      text: existingSupplement?.name ?? '',
    );
    TimeOfDay selectedTime = existingSupplement?.time ?? TimeOfDay.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existingSupplement == null
                ? (AppLocalizations.of(context)?.addSupplement ?? '보충제 추가')
                : (AppLocalizations.of(context)?.editSupplement ?? '보충제 수정'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.supplementName,
                  hintText: AppLocalizations.of(context)!.supplementHintText,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setDialogState(() {
                      selectedTime = time;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)?.supplementTime ?? '섭취 시간'}: ${selectedTime.format(context)}',
                      ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  if (existingSupplement != null) {
                    // 수정
                    setState(() {
                      existingSupplement.name = name;
                      existingSupplement.time = selectedTime;
                    });
                  } else {
                    // 추가 (최대 3개)
                    if (_settings.supplements.length < 3) {
                      setState(() {
                        _settings.supplements.add(
                          SupplementAlarm(
                            name: name,
                            time: selectedTime,
                            enabled: true,
                          ),
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.maxSupplementsReached,
                          ),
                        ),
                      );
                      return;
                    }
                  }
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(
                existingSupplement == null
                    ? AppLocalizations.of(context)!.add
                    : AppLocalizations.of(context)!.editSupplement,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStatusCard() {
    return FutureBuilder<PermissionStatus>(
      future: Permission.notification.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? PermissionStatus.denied;
        final isGranted = status.isGranted;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isGranted
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGranted
                  ? const Color(0xFFA5D6A7)
                  : const Color(0xFFFFCDD2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isGranted ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: isGranted ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGranted
                          ? AppLocalizations.of(
                              context,
                            )!.notificationPermissionGranted
                          : AppLocalizations.of(
                              context,
                            )!.notificationPermissionRequired,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isGranted ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    if (!isGranted)
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.enablePermissionForHealthAlerts,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (!isGranted)
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: Text(AppLocalizations.of(context)!.settings),
                ),
            ],
          ),
        );
      },
    );
  }
}
