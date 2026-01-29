import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'enhanced_profile_setup_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final bool isFirstRun;

  const LanguageSelectionScreen({
    super.key,
    this.isFirstRun = false,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isFirstRun 
        ? null 
        : AppBar(
            title: Text(l10n.languageSettings),
            centerTitle: true,
          ),
      body: SafeArea(
        child: Column(
          children: [
            if (isFirstRun) ...[
              const SizedBox(height: 60),
              // 로고
              Image.asset(
                'assets/logo/logowind.jpeg',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.selectLanguage, // "Select Language" or "Language" based on locale
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.pleaseSelectLanguage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
            ],
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildLanguageOption(context, appProvider, '한국어', 'ko', '🇰🇷'),
                  const SizedBox(height: 12),
                  _buildLanguageOption(context, appProvider, 'English', 'en', '🇺🇸'),
                  const SizedBox(height: 12),
                  _buildLanguageOption(context, appProvider, '日本語', 'ja', '🇯🇵'),
                  const SizedBox(height: 12),
                  _buildLanguageOption(context, appProvider, 'Bahasa Indonesia', 'id', '🇮🇩'),
                  const SizedBox(height: 12),
                  _buildLanguageOption(context, appProvider, 'Bahasa Melayu', 'ms', '🇲🇾'),
                ],
              ),
            ),
            
            if (isFirstRun) ...[
               Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateToNext(context, appProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      l10n.getStarted,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, 
    AppProvider appProvider, 
    String label, 
    String code,
    String flag,
  ) {
    final isSelected = appProvider.locale.languageCode == code;
    
    return InkWell(
      onTap: () {
        appProvider.setLocale(Locale(code));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withAlpha(26) // 0.1 opacity
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToNext(BuildContext context, AppProvider appProvider) async {
    // 현재 선택된 언어를 확정 저장 (이미 설정되었더라도 flag 갱신을 위해 호출)
    await appProvider.setLocale(appProvider.locale);

    if (appProvider.isProfileComplete) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EnhancedProfileSetupScreen()),
        );
      }
    }
  }
}
