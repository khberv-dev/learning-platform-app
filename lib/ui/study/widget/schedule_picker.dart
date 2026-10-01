import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/assignments/domain/usecase/assignment_usecases.dart';
import 'package:student/core/assignments/presentation/my_assignments_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/utils/messenger.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF6D737E);
const _green = Color(0xFF78C93C);

/// The hours a lesson can start at, on any day.
const scheduleTimes = [
  '09:00',
  '10:00',
  '11:00',
  '12:00',
  '13:00',
  '14:00',
  '15:00',
  '16:00',
  '17:00',
  '18:00',
  '19:00',
  '20:00',
];

/// How many weekly slots a student picks.
const requiredSlots = 3;

/// Picks the weekly times for a group request: a weekday row, that day's
/// hours — one per day — and a confirm button once [requiredSlots] days have
/// a time. Confirming sends the request for [subscriptionId].
class SchedulePicker extends ConsumerStatefulWidget {
  final String subscriptionId;

  /// Shown above everything, scrolling with it — the page title.
  final Widget header;

  const SchedulePicker({
    super.key,
    required this.subscriptionId,
    required this.header,
  });

  @override
  ConsumerState<SchedulePicker> createState() => _SchedulePickerState();
}

class _SchedulePickerState extends ConsumerState<SchedulePicker> {
  Weekday _day = Weekday.mon;
  final List<ScheduleSlot> _slots = [];
  bool _sending = false;

  /// One time per weekday: tapping the day's time again clears it, and a
  /// different time replaces it in place.
  void _toggle(String time) {
    final slot = ScheduleSlot(day: _day, time: time);
    if (_slots.contains(slot)) {
      setState(() => _slots.remove(slot));
      return;
    }
    final sameDay = _slots.indexWhere((s) => s.day == _day);
    if (sameDay != -1) {
      setState(() => _slots[sameDay] = slot);
      return;
    }
    if (_slots.length >= requiredSlots) {
      showErrorMessage(
        context,
        AppLocalizations.of(context).studyTooManySlots(requiredSlots),
      );
      return;
    }
    setState(() => _slots.add(slot));
  }

  Future<void> _confirm() async {
    setState(() => _sending = true);
    try {
      await ref
          .read(useRequestAssignmentProvider)
          .call(subscriptionId: widget.subscriptionId, schedule: _slots);
      if (!mounted) return;
      showSuccessMessage(
        context,
        AppLocalizations.of(context).studyRequestSent,
      );
      ref.invalidate(myAssignmentsControllerProvider);
    } catch (e) {
      if (mounted) showErrorMessage(context, apiErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final insets = MediaQuery.paddingOf(context);
    final letters = l10n.studyWeekdayLetters.split(',');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              insets.top + AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              widget.header,
              _IntroCard(
                title: l10n.studyPickTitle,
                body: l10n.studyPickBody(requiredSlots),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Heading(l10n.studyWeekdays),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  for (final day in Weekday.values) ...[
                    if (day != Weekday.mon) const SizedBox(width: 6),
                    Expanded(
                      child: _DayChip(
                        key: ValueKey('day-${day.name}'),
                        label: letters.length == 7
                            ? letters[day.index]
                            : day.name,
                        selected: day == _day,
                        hasSlot: _slots.any((s) => s.day == day),
                        onTap: () => setState(() => _day = day),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _Heading(l10n.studyTimeFor(weekdayName(_day, locale))),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2,
                children: [
                  for (final time in scheduleTimes)
                    _TimePill(
                      key: ValueKey('time-$time'),
                      time: time,
                      selected: _slots.contains(
                        ScheduleSlot(day: _day, time: time),
                      ),
                      onTap: () => _toggle(time),
                    ),
                ],
              ),
              if (_slots.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final slot in _slots)
                      _ChosenSlot(
                        key: ValueKey('chosen-${slot.day.name}-${slot.time}'),
                        label:
                            '${letters.length == 7 ? letters[slot.day.index] : slot.day.name}'
                            ' · ${slot.time}',
                        onRemove: () => setState(() => _slots.remove(slot)),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            insets.bottom + AppSpacing.md,
          ),
          child: AppFlatPillButton(
            key: const ValueKey('schedule-confirm'),
            label: l10n.studyConfirm(_slots.length, requiredSlots),
            background: _green,
            foreground: Colors.white,
            onTap: _slots.length == requiredSlots && !_sending
                ? _confirm
                : null,
          ),
        ),
      ],
    );
  }
}

/// The weekday's full name in [locale], capitalised — "Dushanba", "Monday".
String weekdayName(Weekday day, String locale) {
  // 1 Jan 2024 was a Monday.
  final date = DateTime(2024, 1, 1 + day.index);
  final name = DateFormat.EEEE(locale).format(date);
  return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final String title;
  final String body;

  const _IntroCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7DC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.access_time_filled_rounded,
              color: _green,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A round weekday chip: green when it's the day being edited, with a dot
/// beneath once it has a chosen time.
class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool hasSlot;
  final VoidCallback onTap;

  const _DayChip({
    super.key,
    required this.label,
    required this.selected,
    required this.hasSlot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected ? _green : Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              key: hasSlot ? const ValueKey('day-has-slot') : null,
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: hasSlot ? _green : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String time;
  final bool selected;
  final VoidCallback onTap;

  const _TimePill({
    super.key,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? _green : Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Center(
            child: Text(
              time,
              style: TextStyle(
                color: selected ? Colors.white : _ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A chosen day and time, removable with a tap.
class _ChosenSlot extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ChosenSlot({super.key, required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F7DC),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onRemove,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF4E8F23),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.close_rounded,
                size: 16,
                color: Color(0xFF4E8F23),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
