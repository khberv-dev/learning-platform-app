import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/assignments/presentation/create_assignment_controller.dart';
import 'package:student/core/tutors/presentation/tutor_detail_controller.dart';
import 'package:student/utils/messenger.dart';

const _dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _dayNames = {
  'Mon': 'Monday',
  'Tue': 'Tuesday',
  'Wed': 'Wednesday',
  'Thu': 'Thursday',
  'Fri': 'Friday',
  'Sat': 'Saturday',
  'Sun': 'Sunday',
};

Future<void> showBookTutorSheet(
  BuildContext context,
  WidgetRef ref, {
  required String tutorId,
  required String tutorName,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: _BookTutorSheet(tutorId: tutorId, tutorName: tutorName),
    ),
  );
}

class _BookTutorSheet extends ConsumerStatefulWidget {
  final String tutorId;
  final String tutorName;

  const _BookTutorSheet({required this.tutorId, required this.tutorName});

  @override
  ConsumerState<_BookTutorSheet> createState() => _BookTutorSheetState();
}

class _BookTutorSheetState extends ConsumerState<_BookTutorSheet> {
  // selectedSlots: {day: [slot, ...]}
  final Map<String, Set<String>> _selected = {};

  int get _totalSelected =>
      _selected.values.fold(0, (sum, s) => sum + s.length);

  void _toggle(String day, String slot) {
    setState(() {
      _selected.putIfAbsent(day, () => {});
      if (_selected[day]!.contains(slot)) {
        _selected[day]!.remove(slot);
        if (_selected[day]!.isEmpty) _selected.remove(day);
      } else {
        if (_totalSelected >= 3) return;
        _selected[day]!.add(slot);
      }
    });
  }

  Map<String, List<String>>? _buildSchedulePayload() {
    if (_selected.isEmpty) return null;
    return _selected.map((day, slots) => MapEntry(day, slots.toList()..sort()));
  }

  Future<void> _confirm() async {
    await ref
        .read(createAssignmentControllerProvider.notifier)
        .book(teacherId: widget.tutorId, selectedSchedule: _buildSchedulePayload());

    final state = ref.read(createAssignmentControllerProvider);
    if (!mounted) return;
    if (state.hasError) {
      showErrorMessage(
        context,
        CreateAssignmentController.errorMessage(state.error!),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(teacherScheduleProvider(widget.tutorId));
    final isLoading = ref.watch(createAssignmentControllerProvider).isLoading;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F7FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Text(
                  'Select Schedule',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose up to 3 weekly slots with ${widget.tutorName}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Schedule content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: scheduleState.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Could not load schedule',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ),
              data: (schedule) {
                final days = _dayOrder
                    .where((d) =>
                        schedule.containsKey(d) && schedule[d]!.isNotEmpty)
                    .toList();

                if (days.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Center(
                      child: Text(
                        'This tutor hasn\'t set availability yet.\nYou can still send a booking request.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6B7280), height: 1.5),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final day in days) ...[
                        Text(
                          _dayNames[day] ?? day,
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: schedule[day]!.map((slot) {
                            final isSelected =
                                _selected[day]?.contains(slot) ?? false;
                            final canSelect = isSelected || _totalSelected < 3;
                            return _SlotChip(
                              slot: slot,
                              isSelected: isSelected,
                              isEnabled: canSelect,
                              onTap: () => _toggle(day, slot),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          // Slot counter
          if (_totalSelected > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_totalSelected/3 slots selected',
                      style: const TextStyle(
                        color: Color(0xFF18C96A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Confirm button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: Material(
                color: const Color(0xFF18C96A),
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: isLoading ? null : _confirm,
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Confirm Booking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String slot;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF18C96A)
              : isEnabled
                  ? Colors.white
                  : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF18C96A)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          slot,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : isEnabled
                    ? const Color(0xFF374151)
                    : const Color(0xFF9CA3AF),
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
