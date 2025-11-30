import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../avatar/clothing_colors.dart';
import '../widgets/advanced_avatar_widget.dart';
import '../avatar/body_measurements.dart';

class ClothingSettingsScreen extends StatefulWidget {
  const ClothingSettingsScreen({super.key});

  @override
  State<ClothingSettingsScreen> createState() => _ClothingSettingsScreenState();
}

class _ClothingSettingsScreenState extends State<ClothingSettingsScreen> {
  ClothingColors? _tempColors; // 임시 선택 색상 (미리보기용)
  bool _hasChanges = false; // 변경사항 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('옷 색상 변경'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasChanges) {
              _showDiscardChangesDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final currentColors = _tempColors ?? 
                               appProvider.userProfile?.getClothingColors() ?? 
                               ClothingColors.defaultColors;
          final originalColors = appProvider.userProfile?.getClothingColors() ?? 
                                ClothingColors.defaultColors;

          return Column(
            children: [
              // 아바타 미리보기 영역
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          height: 300,
                          width: 200,
                          child: _buildPreviewAvatar(appProvider, currentColors),
                        ),
                      ),
                      // 미리보기 표시
                      if (_hasChanges)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.visibility, size: 16, color: Colors.orange.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  '미리보기',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // 색상 선택 영역
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '색상 테마 선택',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: ClothingColors.presets.length,
                          itemBuilder: (context, index) {
                            final preset = ClothingColors.presets[index];
                            final name = ClothingColors.presetNames[index];
                            final isSelected = _areColorsEqual(currentColors, preset);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tempColors = preset;
                                  _hasChanges = !_areColorsEqual(preset, originalColors);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildColorCircle(preset.braColor),
                                        const SizedBox(width: 8),
                                        _buildColorCircle(preset.tightsColor),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼 영역
              if (_hasChanges)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _tempColors = null;
                                _hasChanges = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await appProvider.updateClothingColors(_tempColors!);
                              setState(() {
                                _tempColors = null;
                                _hasChanges = false;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('옷 색상이 변경되었습니다'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('적용'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreviewAvatar(AppProvider appProvider, ClothingColors colors) {
    if (appProvider.userProfile == null) {
      return appProvider.buildAvatarWidget();
    }

    // 임시 색상으로 아바타 생성
    final height = appProvider.userProfile!.height;
    final weight = appProvider.userProfile!.initialWeight;
    final bmi = weight / ((height / 100) * (height / 100));

    return AdvancedAvatarWidget(
      bmi: bmi,
      height: height,
      gender: appProvider.userProfile!.gender,
      lifestyle: _mapActivityLevelToLifestylePattern(appProvider.userProfile!.activityLevel),
      clothingColors: colors, // 선택된 색상 적용
    );
  }

  LifestylePattern _mapActivityLevelToLifestylePattern(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return LifestylePattern.sedentary;
      case 'light':
      case 'moderate':
      case 'active':
        return LifestylePattern.active;
      case 'very_active':
        return LifestylePattern.athletic;
      default:
        return LifestylePattern.active;
    }
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12, width: 1),
      ),
    );
  }

  bool _areColorsEqual(ClothingColors a, ClothingColors b) {
    return a.braColor.value == b.braColor.value && 
           a.tightsColor.value == b.tightsColor.value;
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경사항 취소'),
        content: const Text('변경한 내용을 취소하고 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('머무르기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 설정 화면 닫기
            },
            child: const Text('나가기'),
          ),
        ],
      ),
    );
  }
}
