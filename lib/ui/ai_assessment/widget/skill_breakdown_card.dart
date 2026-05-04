import 'package:flutter/material.dart';

class SkillBreakdownCard extends StatelessWidget {
  final List<SkillBreakdownItem> items;

  const SkillBreakdownCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skill Breakdown',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _SkillRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class SkillBreakdownItem {
  final String name;
  final int percent;
  final Color color;

  const SkillBreakdownItem({
    required this.name,
    required this.percent,
    required this.color,
  });
}

class _SkillRow extends StatelessWidget {
  final SkillBreakdownItem item;

  const _SkillRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name,
              style: const TextStyle(color: Color(0xFF374151), fontSize: 14),
            ),
            Text(
              '${item.percent}%',
              style: TextStyle(
                color: item.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: item.percent / 100,
            minHeight: 6,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
          ),
        ),
      ],
    );
  }
}
