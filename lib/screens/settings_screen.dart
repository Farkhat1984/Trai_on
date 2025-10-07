import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/sound_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: l10n.appearance,
            children: [
              _buildThemeCard(context, ref, themeMode, l10n),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: l10n.sound,
            children: [
              _buildSoundCard(context, ref, soundEnabled, l10n),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: l10n.payments,
            children: [
              _buildAcquiringCard(context, l10n),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: l10n.wardrobeTitle,
            children: [
              _buildWardrobeStatsCard(context, ref, l10n),
              const SizedBox(height: 12),
              _buildClearWardrobeCard(context, ref, l10n),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: l10n.about,
            children: [
              _buildAboutCard(context, l10n),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildThemeCard(BuildContext context, WidgetRef ref,
      ThemeMode currentMode, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.themeSettings,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              context,
              ref,
              title: l10n.lightTheme,
              icon: Icons.light_mode,
              mode: ThemeMode.light,
              isSelected: currentMode == ThemeMode.light,
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context,
              ref,
              title: l10n.darkTheme,
              icon: Icons.dark_mode,
              mode: ThemeMode.dark,
              isSelected: currentMode == ThemeMode.dark,
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context,
              ref,
              title: l10n.systemTheme,
              icon: Icons.brightness_auto,
              mode: ThemeMode.system,
              isSelected: currentMode == ThemeMode.system,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundCard(BuildContext context, WidgetRef ref, bool soundEnabled,
      AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              soundEnabled ? Icons.volume_up : Icons.volume_off,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.soundEffects,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    soundEnabled ? l10n.enabled : l10n.disabled,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: soundEnabled,
              onChanged: (value) {
                ref.read(soundEnabledProvider.notifier).setSoundEnabled(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcquiringCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.acquiringInDevelopment),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.credit_card,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.acquiring,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.paymentSystemSettings,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardrobeStatsCard(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final wardrobeItems = ref.watch(wardrobeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.checkroom, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.itemsInWardrobe,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${wardrobeItems.length}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearWardrobeCard(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final wardrobeItems = ref.watch(wardrobeProvider);

    return Card(
      child: InkWell(
        onTap: wardrobeItems.isEmpty
            ? null
            : () => _showClearWardrobeDialog(context, ref, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.delete_sweep,
                color: wardrobeItems.isEmpty ? Colors.grey : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.clearWardrobe,
                  style: TextStyle(
                    color: wardrobeItems.isEmpty ? Colors.grey : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: wardrobeItems.isEmpty ? Colors.grey : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.version,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: Icons.stars,
              text: l10n.aiImageGeneration,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.auto_fix_high,
              text: l10n.virtualTryOn,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.photo_library,
              text: l10n.personalWardrobe,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ),
      ],
    );
  }

  void _showClearWardrobeDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearWardrobeConfirm),
        content: Text(l10n.clearWardrobeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(wardrobeProvider.notifier).clearWardrobe();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.wardrobeCleared)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }
}
