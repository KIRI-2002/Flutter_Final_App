import 'package:flutter/material.dart';
import 'package:y3s1_final/services/app_preferences.dart';

class AppearanceLanguageScreen extends StatelessWidget {
  const AppearanceLanguageScreen({super.key});

  String _tr(String english, String khmer) {
    return AppPreferences.instance.translate(english, khmer);
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppPreferences.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final dark = settings.darkMode;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,

          appBar: AppBar(
            centerTitle: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: colors.onSurface,
            elevation: 0,
            title: Text(
              _tr(
                'Appearance & Language',
                'រូបរាង និងភាសា',
              ),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const SizedBox(height: 12),

              // =====================================================
              // HEADER
              // =====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: dark
                        ? [
                            const Color(0xFF30275C),
                            const Color(0xFF211D3D),
                          ]
                        : [
                            const Color(0xFFDDD6FF),
                            const Color(0xFFF0ECFF),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        dark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        size: 43,
                        color: dark
                            ? const Color(0xFFE1D8FF)
                            : const Color(0xFF6C4DD3),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      _tr(
                        'Customize Your App',
                        'កំណត់កម្មវិធីរបស់អ្នក',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: dark
                            ? Colors.white
                            : const Color(0xFF201B3D),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _tr(
                        'Choose your preferred appearance and language.',
                        'ជ្រើសរើសរូបរាង និងភាសាដែលអ្នកចូលចិត្ត។',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: dark
                            ? Colors.white70
                            : const Color(0xFF514B70),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // =====================================================
              // APPEARANCE SECTION
              // =====================================================

              _sectionTitle(
                context,
                _tr('Appearance', 'រូបរាង'),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: colors.outlineVariant,
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  secondary: _iconContainer(
                    context,
                    dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                  ),

                  title: Text(
                    _tr('Dark Mode', 'មុខងារងងឹត'),
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      _tr(
                        'Use a dark appearance throughout the app.',
                        'ប្រើរូបរាងពណ៌ងងឹតនៅទូទាំងកម្មវិធី។',
                      ),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),

                  value: dark,

                  activeTrackColor: colors.primary,
                  activeColor: colors.onPrimary,

                  onChanged: (value) {
                    settings.setDarkMode(value);
                  },
                ),
              ),

              const SizedBox(height: 28),

              // =====================================================
              // LANGUAGE SECTION
              // =====================================================

              _sectionTitle(
                context,
                _tr('Language', 'ភាសា'),
              ),

              const SizedBox(height: 12),

              // ENGLISH
              _languageCard(
                context: context,
                title: 'English',
                subtitle: 'English language',
                value: 'en',
                selected: settings.language == 'en',
                flag: '🇬🇧',
                onTap: () {
                  settings.setLanguage('en');
                },
              ),

              const SizedBox(height: 12),

              // KHMER
              _languageCard(
                context: context,
                title: 'ភាសាខ្មែរ',
                subtitle: 'Khmer language',
                value: 'km',
                selected: settings.language == 'km',
                flag: '🇰🇭',
                onTap: () {
                  settings.setLanguage('km');
                },
              ),

              const SizedBox(height: 28),

              // =====================================================
              // AUTOMATIC SAVE NOTICE
              // =====================================================

              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outlineVariant,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: colors.primary,
                      size: 24,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tr(
                              'Automatically Saved',
                              'រក្សាទុកដោយស្វ័យប្រវត្តិ',
                            ),
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            _tr(
                              'Your preferences are saved automatically and will remain after restarting the app.',
                              'ការកំណត់របស់អ្នកនឹងត្រូវបានរក្សាទុកដោយស្វ័យប្រវត្តិ ទោះបីបិទ និងបើកកម្មវិធីឡើងវិញក៏ដោយ។',
                            ),
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // SECTION TITLE
  // =====================================================

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  // =====================================================
  // ICON CONTAINER
  // =====================================================

  Widget _iconContainer(
    BuildContext context,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: colors.onPrimaryContainer,
        size: 25,
      ),
    );
  }

  // =====================================================
  // LANGUAGE CARD
  // =====================================================

  Widget _languageCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required bool selected,
    required String flag,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outlineVariant,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                flag,
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? colors.primary
                    : colors.onSurfaceVariant,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}