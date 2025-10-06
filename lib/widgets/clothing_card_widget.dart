import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clothing_item.dart';
import '../providers/wardrobe_provider.dart';

class ClothingCardWidget extends ConsumerWidget {
  final ClothingItem item;
  final VoidCallback onDoubleTap;
  final VoidCallback onDelete;
  final VoidCallback onSave;

  const ClothingCardWidget({
    super.key,
    required this.item,
    required this.onDoubleTap,
    required this.onDelete,
    required this.onSave,
  });

  void _showActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ClothingActionsSheet(
        item: item,
        onEdit: () {
          Navigator.pop(context);
          _showEditDialog(context, ref);
        },
        onSave: () {
          Navigator.pop(context);
          onSave();
        },
        onTryOn: () {
          Navigator.pop(context);
          onDoubleTap();
        },
        onDelete: () {
          Navigator.pop(context);
          onDelete();
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: item.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать название'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Введите название товара',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLines: 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final newDescription = controller.text.trim();
              ref.read(wardrobeProvider.notifier).updateClothingDescription(
                    item.id,
                    newDescription.isEmpty ? null : newDescription,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Название обновлено'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showActions(context, ref),
      onDoubleTap: onDoubleTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.memory(
                base64Decode(item.base64Image),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                cacheWidth: 400,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.9, 0.9),
            duration: 300.ms,
          ),
    );
  }
}

// Выделенный виджет для Action Sheet
class _ClothingActionsSheet extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onTryOn;
  final VoidCallback onDelete;

  const _ClothingActionsSheet({
    required this.item,
    required this.onEdit,
    required this.onSave,
    required this.onTryOn,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          if (item.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                item.description!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Icons.edit,
            title: 'Редактировать название',
            color: Colors.orange,
            onTap: onEdit,
          ),
          _ActionTile(
            icon: Icons.save_alt,
            title: 'Сохранить в галерею',
            color: Colors.green,
            onTap: onSave,
          ),
          _ActionTile(
            icon: Icons.check_circle_outline,
            title: 'Примерить',
            color: Colors.blue,
            onTap: onTryOn,
          ),
          _ActionTile(
            icon: Icons.delete_outline,
            title: 'Удалить из гардероба',
            color: Colors.red,
            onTap: onDelete,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Виджет для одного пункта действия
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}
