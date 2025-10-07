import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_constants.dart';
import '../sound_buttons.dart';

/// Model for a FAB action button
class FabAction {
  final String heroTag;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const FabAction({
    required this.heroTag,
    required this.backgroundColor,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });
}

/// Expandable FAB widget that shows a list of action buttons
class ExpandableFab extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<FabAction> actions;
  final Widget? expandedIcon;
  final Widget? collapsedIcon;

  const ExpandableFab({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.actions,
    this.expandedIcon,
    this.collapsedIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isExpanded) ...[
          ...actions.map((action) => _buildActionButton(action)),
          SizedBox(height: AppConstants.paddingMedium),
        ],
        _buildMainButton(),
      ],
    );
  }

  Widget _buildActionButton(FabAction action) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: SoundFloatingActionButton(
        heroTag: action.heroTag,
        mini: true,
        backgroundColor: action.backgroundColor,
        onPressed: action.onPressed,
        child: Icon(action.icon, color: Colors.white),
      )
          .animate()
          .fadeIn(duration: AppConstants.shortAnimationDuration)
          .scale(
            begin: const Offset(0.5, 0.5),
            duration: AppConstants.shortAnimationDuration,
          ),
    );
  }

  Widget _buildMainButton() {
    return SoundFloatingActionButton(
      onPressed: onToggle,
      child: AnimatedRotation(
        turns: isExpanded ? 0.125 : 0,
        duration: AppConstants.shortAnimationDuration,
        child: expandedIcon != null && collapsedIcon != null
            ? (isExpanded ? expandedIcon! : collapsedIcon!)
            : Icon(isExpanded ? Icons.close : Icons.add),
      ),
    );
  }
}
