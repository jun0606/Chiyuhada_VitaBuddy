import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart'; // 권한 관리 추가

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
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

    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(_settings.toMap());
    await prefs.setString('notification_settings', settingsJson);

    // 알람 적용
    await _applyNotifications();
  }

  Future<void> _applyNotifications() async {
    final service = NotificationService();

    // 식사 알람
    if (_settings.breakfastEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.breakfast,
        title: '아침 식사 시간이에요! 🌅',
        body: '건강한 아침으로 하루를 시작하세요',
        time: _settings.breakfastTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.breakfast);
    }

    if (_settings.lunchEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.lunch,
        title: '점심 식사 시간입니다! 🍱',
        body: '균형 잡힌 식사를 챙기세요',
        time: _settings.lunchTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.lunch);
    }

    if (_settings.dinnerEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.dinner,
        title: '저녁 식사 시간이에요! 🌙',
        body: '가벼운 저녁 식사를 추천해요',
        time: _settings.dinnerTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.dinner);
    }

    // 간식 알람
    if (_settings.morningSnackEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.morningSnack,
        title: '오전 간식 시간! 🍎',
        body: '과일이나 견과류 어떠세요?',
        time: _settings.morningSnackTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.morningSnack);
    }

    if (_settings.afternoonSnackEnabled) {
      await service.scheduleDailyNotification(
        id: NotificationIds.afternoonSnack,
        title: '오후 간식 시간! 🍪',
        body: '과식하지 않도록 주의하세요',
        time: _settings.afternoonSnackTime,
      );
    } else {
      await service.cancelNotification(NotificationIds.afternoonSnack);
    }

    // 운동 알람
    if (_settings.exerciseEnabled) {
      await service.scheduleWeeklyNotification(
        baseId: NotificationIds.exercise,
        title: '운동 시간입니다! 🏃',
        body: '오늘의 칼로리를 태워볼까요?',
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

    // 비타민/보충제 알람
    for (int i = 0; i < _settings.supplements.length; i++) {
      final supplement = _settings.supplements[i];
      if (supplement.enabled) {
        await service.scheduleSupplementNotification(
          id: NotificationIds.supplementBase + i,
          supplementName: supplement.name,
          time: supplement.time,
        );
      } else {
        await service.cancelNotification(NotificationIds.supplementBase + i);
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

  Future<void> _selectTime(BuildContext context, TimeOfDay current,
      Function(TimeOfDay) onTimeSelected) async {
    final time = await showTimePicker(
      context: context,
      initialTime: current,
    );

    if (time != null) {
      onTimeSelected(time);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 자동 저장
        await _saveSettings();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('알림 설정'),
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
              child: const Text(
                '저장',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시스템 알림 권한 상태
              _buildPermissionStatusCard(),
              const SizedBox(height: 24),

              // 식사 알림 섹션
              _buildSectionHeader('📱 식사 알림'),
              _buildAlarmCard(
                title: '아침 식사',
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
                title: '점심 식사',
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
                title: '저녁 식사',
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
              _buildSectionHeader('🍎 간식 알림'),
              _buildAlarmCard(
                title: '오전 간식',
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
                title: '오후 간식',
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
              _buildSectionHeader('🏃 운동 알림'),
              _buildExerciseAlarmCard(),
              const SizedBox(height: 24),

              // 체중 측정 알림 섹션
              _buildSectionHeader('⚖️ 체중 측정 알림'),
              _buildAlarmCard(
                title: '체중 측정',
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

              // TODO: 비타민/보충제 알림
              // TODO: 수분 섭취 관리
            ],
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
        trailing: Switch(
          value: enabled,
          onChanged: onToggle,
        ),
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
                  '운동 시간',
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('요일 선택:'),
              const SizedBox(height: 8),
              _buildDaySelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['월', '화', '수', '목', '금', '토', '일'];

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


  Widget _buildPermissionStatusCard() {
    return FutureBuilder<PermissionStatus>(
      future: Permission.notification.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? PermissionStatus.denied;
        final isGranted = status.isGranted;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isGranted ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGranted ? const Color(0xFFA5D6A7) : const Color(0xFFFFCDD2),
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
                      isGranted ? '알림 권한이 허용됨' : '알림 권한이 필요합니다',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isGranted ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    if (!isGranted)
                      const Text(
                        '중요한 건강 알림을 받으려면 권한을 켜주세요.',
                        style: TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (!isGranted)
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('설정'),
                ),
            ],
          ),
        );
      },
    );
  }
}
