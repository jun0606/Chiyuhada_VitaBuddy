import 'package:flutter/material.dart';
import 'clothing_settings_screen.dart';
import 'profile_edit_screen.dart';
import 'notification_settings_screen.dart';
import 'calorie_goal_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsItem(
            context,
            '목표 칼로리 설정',
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
            '아바타 옷 설정',
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
            '프로필 수정',
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
            '알림 설정',
            Icons.notifications_rounded,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
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
            color: Colors.black.withOpacity(0.05),
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
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0BEC5)),
        onTap: onTap,
      ),
    );
  }
}
