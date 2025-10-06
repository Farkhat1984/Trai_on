import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/sound_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Внешний вид',
            children: [
              _buildThemeCard(context, ref, themeMode),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Звук',
            children: [
              _buildSoundCard(context, ref, soundEnabled),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Гардероб',
            children: [
              _buildWardrobeStatsCard(context, ref),
              const SizedBox(height: 12),
              _buildClearWardrobeCard(context, ref),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'О приложении',
            children: [
              _buildAboutCard(context),
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

  Widget _buildThemeCard(
      BuildContext context, WidgetRef ref, ThemeMode currentMode) {
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
                  'Тема оформления',
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
              title: 'Светлая',
              icon: Icons.light_mode,
              mode: ThemeMode.light,
              isSelected: currentMode == ThemeMode.light,
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context,
              ref,
              title: 'Темная',
              icon: Icons.dark_mode,
              mode: ThemeMode.dark,
              isSelected: currentMode == ThemeMode.dark,
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context,
              ref,
              title: 'Системная',
              icon: Icons.brightness_auto,
              mode: ThemeMode.system,
              isSelected: currentMode == ThemeMode.system,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundCard(
      BuildContext context, WidgetRef ref, bool soundEnabled) {
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
                    'Звуковые эффекты',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    soundEnabled ? 'Включены' : 'Выключены',
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

  Widget _buildWardrobeStatsCard(BuildContext context, WidgetRef ref) {
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
                    'Предметов в гардеробе',
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

  Widget _buildClearWardrobeCard(BuildContext context, WidgetRef ref) {
    final wardrobeItems = ref.watch(wardrobeProvider);

    return Card(
      child: InkWell(
        onTap: wardrobeItems.isEmpty
            ? null
            : () => _showClearWardrobeDialog(context, ref),
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
                  'Очистить гардероб',
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

  Widget _buildAboutCard(BuildContext context) {
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
                  'Виртуальная примерочная',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Версия: 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте модель по описанию или загрузите фото, '
              'добавьте одежду и примерьте новый образ!',
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
              text: 'AI-генерация изображений',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.auto_fix_high,
              text: 'Виртуальная примерка одежды',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.photo_library,
              text: 'Персональный гардероб',
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

  void _showClearWardrobeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить гардероб?'),
        content: const Text(
          'Это действие удалит все предметы из вашего гардероба. '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(wardrobeProvider.notifier).clearWardrobe();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Гардероб очищен')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }
}
