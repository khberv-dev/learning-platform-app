import 'package:flutter/material.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';

/// One destination. Either [imagePath] (a black silhouette PNG, tinted at
/// paint time) or [icon] is used.
class _NavDestination {
  final String label;
  final String? imagePath;
  final IconData? icon;

  const _NavDestination({required this.label, this.imagePath, this.icon});
}

/// Floating pill navigation bar. Detached from the screen edges and elevated,
/// rather than a full-width Material [BottomNavigationBar].
class AppNavbar extends StatelessWidget {
  static const double height = 64;

  final int current;
  final bool showChat;
  final Function(int) onItemClick;

  const AppNavbar({
    super.key,
    required this.current,
    required this.onItemClick,
    this.showChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final destinations = <_NavDestination>[
      _NavDestination(
        label: l10n.navHome,
        imagePath: 'assets/images/nav_home.png',
      ),
      _NavDestination(
        label: l10n.navCourse,
        imagePath: 'assets/images/nav_course.png',
      ),
      // No nav_chat.png ships yet, so this one stays a Material icon.
      if (showChat)
        _NavDestination(label: l10n.navChat, icon: Icons.chat_bubble_rounded)
      else
        _NavDestination(
          label: l10n.navMentor,
          imagePath: 'assets/images/nav_mentor.png',
        ),
      _NavDestination(
        label: l10n.navProfile,
        imagePath: 'assets/images/nav_profile.png',
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.round),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(28),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavButton(
                    destination: destinations[i],
                    isSelected: i == current,
                    onTap: () => onItemClick(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = isSelected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // The artwork's aspect ratios differ, so contain them in a
              // square box to keep the row optically even.
              SizedBox.square(
                dimension: 24,
                child: destination.imagePath != null
                    ? Image.asset(
                        destination.imagePath!,
                        fit: BoxFit.contain,
                        color: tint,
                        colorBlendMode: BlendMode.srcIn,
                      )
                    : Icon(destination.icon, size: 22, color: tint),
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tint,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
