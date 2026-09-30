import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';

/// One destination — [iconPath] is a white SVG silhouette.
class _NavDestination {
  final String label;
  final String iconPath;

  const _NavDestination({required this.label, required this.iconPath});
}

const _barTop = Color(0xFF3C3C3C);
const _barBottom = Color(0xFF222023);
const _selected = Color(0xFF78C93C);

/// The selected pill's lighter rim, per the mockup's soft bevel.
const _selectedRim = Color(0xFFA5DC6F);

/// Gap between the bar's edge and the selected pill.
const _inset = 2.0;

const _slide = Duration(milliseconds: 250);

/// Extra room between the bar's top edge and the icons.
const _contentTopPadding = 6.0;

/// Floating dark pill navigation bar, detached from the screen edges. The
/// current destination sits on a green pill that slides between tabs.
class AppNavbar extends StatelessWidget {
  static const double height = 64;

  final int current;
  final Function(int) onItemClick;

  const AppNavbar({
    super.key,
    required this.current,
    required this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final destinations = <_NavDestination>[
      _NavDestination(
        label: l10n.navHome,
        iconPath: 'assets/icons/nav_home.svg',
      ),
      _NavDestination(
        label: l10n.navCourse,
        iconPath: 'assets/icons/nav_courses.svg',
      ),
      _NavDestination(
        label: l10n.navStudy,
        iconPath: 'assets/icons/nav_study.svg',
      ),
      _NavDestination(
        label: l10n.navProfile,
        iconPath: 'assets/icons/nav_profile.svg',
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
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_barTop, _barBottom],
            ),
            borderRadius: BorderRadius.circular(AppRadius.round),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(_inset),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slot = constraints.maxWidth / destinations.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: _slide,
                    curve: Curves.easeOutCubic,
                    left: slot * current,
                    top: 0,
                    bottom: 0,
                    width: slot,
                    child: const DecoratedBox(
                      key: ValueKey('navbar-selection'),
                      decoration: BoxDecoration(
                        color: _selected,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.round),
                        ),
                        border: Border.fromBorderSide(
                          BorderSide(color: _selectedRim, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  Row(
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
                ],
              );
            },
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
    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.only(top: _contentTopPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(destination.iconPath, width: 20, height: 20),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
