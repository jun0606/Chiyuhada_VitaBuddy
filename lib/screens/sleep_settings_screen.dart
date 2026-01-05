import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import '../l10n/app_localizations.dart';

class SleepSettingsScreen extends StatefulWidget {
  const SleepSettingsScreen({super.key});

  @override
  State<SleepSettingsScreen> createState() => _SleepSettingsScreenState();
}

class _SleepSettingsScreenState extends State<SleepSettingsScreen> {
  late String _mode;
  late TimeOfDay _sleepTime;
  late TimeOfDay _wakeTime;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppProvider>(
      context,
      listen: false,
    ).userProfile;
    if (profile != null) {
      _mode = profile.sleepConfig.mode;
      _sleepTime = _parseTime(profile.sleepConfig.manualSleepTime);
      _wakeTime = _parseTime(profile.sleepConfig.manualWakeTime);
    } else {
      _mode = 'hybrid';
      _sleepTime = const TimeOfDay(hour: 23, minute: 0);
      _wakeTime = const TimeOfDay(hour: 7, minute: 0);
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, bool isSleepTime) async {
    final initialTime = isSleepTime ? _sleepTime : _wakeTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isSleepTime) {
          _sleepTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<AppProvider>(context, listen: false);
    final profile = provider.userProfile;

    if (profile != null) {
      final newConfig = profile.sleepConfig.copyWith(
        mode: _mode,
        manualSleepTime: _formatTime(_sleepTime),
        manualWakeTime: _formatTime(_wakeTime),
      );

      final newProfile = profile.copyWith(sleepConfig: newConfig);
      await provider.saveUserProfile(newProfile);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.sleepSettingsSaved)));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sleepSettingsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFCFD8DC), Color(0xFFECEFF1)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(l10n.sleepModeSection),
          const SizedBox(height: 8),
          _buildModeSelector(),

          const SizedBox(height: 24),

          _buildSectionTitle(l10n.sleepTimeSettings),
          const SizedBox(height: 8),
          _buildTimeSettingCard(),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF546E7A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.saveSettings,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF37474F),
      ),
    );
  }

  Widget _buildModeSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: Text(l10n.hybridMode),
            subtitle: Text(l10n.hybridModeDesc),
            value: 'hybrid',
            groupValue: _mode,
            activeColor: const Color(0xFF546E7A),
            onChanged: (value) => setState(() => _mode = value!),
          ),
          RadioListTile<String>(
            title: Text(l10n.manualMode),
            subtitle: Text(l10n.manualModeDesc),
            value: 'manual',
            groupValue: _mode,
            activeColor: const Color(0xFF546E7A),
            onChanged: (value) => setState(() => _mode = value!),
          ),
          RadioListTile<String>(
            title: Text(l10n.deviceOnlyMode),
            subtitle: Text(l10n.deviceOnlyModeDesc),
            value: 'device',
            groupValue: _mode,
            activeColor: const Color(0xFF546E7A),
            onChanged: (value) => setState(() => _mode = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettingCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTimeRow(l10n.bedtime, _sleepTime, true),
          const Divider(height: 24),
          _buildTimeRow(l10n.waketime, _wakeTime, false),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, TimeOfDay time, bool isSleepTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Color(0xFF455A64)),
        ),
        InkWell(
          onTap: () => _selectTime(context, isSleepTime),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFECEFF1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF37474F),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
