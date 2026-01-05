import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';

class CalorieGoalSettingsScreen extends StatefulWidget {
  const CalorieGoalSettingsScreen({super.key});

  @override
  State<CalorieGoalSettingsScreen> createState() =>
      _CalorieGoalSettingsScreenState();
}

class _CalorieGoalSettingsScreenState extends State<CalorieGoalSettingsScreen> {
  String _selectedMode = 'maintain'; // maintain, loss, bulk
  double _currentSliderValue = 0.0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // 초기화는 didChangeDependencies에서 Provider 접근 가능할 때 수행
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      _selectedMode = provider.calorieMode; // AppProvider에 getter 추가 필요
      _currentSliderValue = provider.dailyCalorieGoal;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calorieGoalSettingsTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final profile = provider.userProfile;
            if (profile == null)
              return const Center(child: CircularProgressIndicator());

            final tdee = profile.getEnhancedTDEE();
            final bmr = profile.getEnhancedBMR();

            // 안전 범위 계산
            final minSafeGoal = bmr; // BMR 이하로는 설정 불가 (안전장치)
            final maxGoal = tdee + 1000; // 증량 모드 고려

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(tdee, bmr),
                  const SizedBox(height: 24),

                  Text(
                    l10n.selectGoalMode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildModeSelection(tdee),

                  const SizedBox(height: 32),

                  Text(
                    l10n.dailyCalorieGoal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentSliderValue.toInt()} kcal',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 슬라이더
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _getModeColor(),
                      thumbColor: _getModeColor(),
                      overlayColor: _getModeColor().withOpacity(0.2),
                      trackHeight: 8.0,
                    ),
                    child: Slider(
                      value: _currentSliderValue,
                      min: minSafeGoal, // BMR이 하한선
                      max: maxGoal,
                      divisions: ((maxGoal - minSafeGoal) / 50)
                          .toInt(), // 50kcal 단위
                      label: '${_currentSliderValue.toInt()} kcal',
                      onChanged: (value) {
                        setState(() {
                          _currentSliderValue = value;
                          _updateModeBasedOnValue(value, tdee);
                        });
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${l10n.minBmr}\n${minSafeGoal.toInt()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${l10n.maintainTdee}\n${tdee.toInt()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${l10n.max}\n${maxGoal.toInt()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 예상 결과 카드
                  _buildPredictionCard(tdee),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.updateCalorieGoal(
                          _currentSliderValue,
                          _selectedMode,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(l10n.goalSaved)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E3B32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.saveGoal,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(double tdee, double bmr) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.bmrLabel,
                style: const TextStyle(color: Colors.black54),
              ),
              Text(
                '${bmr.toInt()} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.tdeeLabel,
                style: const TextStyle(color: Colors.black54),
              ),
              Text(
                '${tdee.toInt()} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            l10n.bmrWarning,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelection(double tdee) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _buildModeChip(l10n.lossMode, 'loss', Colors.orange, tdee),
        const SizedBox(width: 12),
        _buildModeChip(l10n.maintainMode, 'maintain', Colors.green, tdee),
        const SizedBox(width: 12),
        _buildModeChip(l10n.bulkMode, 'bulk', Colors.blue, tdee),
      ],
    );
  }

  Widget _buildModeChip(String label, String mode, Color color, double tdee) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMode = mode;
            // 모드 선택 시 기본값으로 슬라이더 이동
            if (mode == 'maintain') {
              _currentSliderValue = tdee;
            } else if (mode == 'loss') {
              _currentSliderValue = tdee - 500; // 기본 -500
            } else {
              _currentSliderValue = tdee + 300; // 기본 +300
            }
            // 범위 체크
            final provider = Provider.of<AppProvider>(context, listen: false);
            final bmr = provider.userProfile!.getEnhancedBMR();
            if (_currentSliderValue < bmr) _currentSliderValue = bmr;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionCard(double tdee) {
    final l10n = AppLocalizations.of(context)!;
    final diff = _currentSliderValue - tdee;
    final weeklyChange = (diff * 7) / 7700; // 1kg 지방 = 7700kcal

    Color cardColor;
    String title;
    String desc;

    if (diff.abs() < 50) {
      cardColor = Colors.green;
      title = l10n.weightMaintain;
      desc = l10n.maintainDesc;
    } else if (diff < 0) {
      cardColor = Colors.orange;
      title = l10n.weightLossPrediction(weeklyChange.abs().toStringAsFixed(2));
      desc = l10n.lossDesc;
    } else {
      cardColor = Colors.blue;
      title = l10n.weightGainPrediction(weeklyChange.abs().toStringAsFixed(2));
      desc = l10n.bulkDesc;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Color _getModeColor() {
    switch (_selectedMode) {
      case 'loss':
        return Colors.orange;
      case 'bulk':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  void _updateModeBasedOnValue(double value, double tdee) {
    // 슬라이더 값에 따라 모드 자동 변경 (UX 편의성)
    if ((value - tdee).abs() < 50) {
      _selectedMode = 'maintain';
    } else if (value < tdee) {
      _selectedMode = 'loss';
    } else {
      _selectedMode = 'bulk';
    }
  }
}
