import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/lesson_material_entity.dart';
import 'package:student/core/courses/presentation/materials_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/url_launcher.dart';
import 'package:student/ui/courses/image_viewer_screen.dart';
import 'package:student/ui/courses/pdf_viewer_screen.dart';
import 'package:student/utils/lib.dart';
import 'package:student/utils/messenger.dart';

/// Handouts attached to a lesson. PDFs open in the in-app reader; Word files
/// hand off to whatever the device has installed.
///
/// Supplementary to the lesson itself, so it takes up no room while loading or
/// when the lesson has none.
class LessonMaterialsSection extends ConsumerWidget {
  final String lessonId;

  const LessonMaterialsSection({super.key, required this.lessonId});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    LessonMaterialEntity material,
  ) async {
    final resolved = resolveMediaUrl(material.url);
    if (resolved == null) {
      showErrorMessage(
        context,
        AppLocalizations.of(context).materialsOpenFailed,
      );
      return;
    }

    // PDFs and images read in-app; Word files have no renderer here, so they go
    // out to whatever the device has installed.
    final viewer = switch (material.type) {
      LessonMaterialType.pdf => PdfViewerScreen.path,
      LessonMaterialType.image => ImageViewerScreen.path,
      _ => null,
    };

    if (viewer != null) {
      context.push(
        '$viewer'
        '?url=${Uri.encodeQueryComponent(resolved)}'
        '&title=${Uri.encodeQueryComponent(material.name)}',
      );
      return;
    }

    final uri = Uri.tryParse(resolved);
    final opened = uri != null && await ref.read(urlLauncherProvider).call(uri);

    if (!opened && context.mounted) {
      showErrorMessage(
        context,
        AppLocalizations.of(context).materialsOpenFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonMaterialsProvider(lessonId));

    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => _LoadFailed(
        onRetry: () => ref.invalidate(lessonMaterialsProvider(lessonId)),
      ),
      data: (materials) {
        if (materials.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).materialsTitle,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  AppLocalizations.of(
                    context,
                  ).materialsFileCount(materials.length),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < materials.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                child: _MaterialCard(
                  material: materials[i],
                  onTap: () => _open(context, ref, materials[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Material card ─────────────────────────────────────────────────────────────

class _MaterialCard extends StatelessWidget {
  final LessonMaterialEntity material;
  final VoidCallback onTap;

  const _MaterialCard({required this.material, required this.onTap});

  bool get _opensInApp =>
      material.type == LessonMaterialType.pdf ||
      material.type == LessonMaterialType.image;

  /// Tint and glyph per file kind, falling back to a neutral document for a
  /// kind this build doesn't recognise.
  ({Color fill, Color ink, IconData icon}) get _style =>
      switch (material.type) {
        LessonMaterialType.pdf => (
          fill: const Color(0xFFFEF2F2),
          ink: const Color(0xFFEF4444),
          icon: Icons.picture_as_pdf_rounded,
        ),
        LessonMaterialType.doc => (
          fill: const Color(0xFFEFF6FF),
          ink: const Color(0xFF3B82F6),
          icon: Icons.article_rounded,
        ),
        LessonMaterialType.image => (
          fill: const Color(0xFFF5F3FF),
          ink: const Color(0xFF8B5CF6),
          icon: Icons.image_rounded,
        ),
        null => (
          fill: const Color(0xFFF3F4F6),
          ink: const Color(0xFF6B7280),
          icon: Icons.insert_drive_file_rounded,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style.fill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(style.icon, color: style.ink, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (material.type != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      material.type!.label,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Signals where the tap lands: PDFs and images open in-app,
            // anything else hands off to another app.
            Icon(
              _opensInApp
                  ? Icons.chevron_right_rounded
                  : Icons.open_in_new_rounded,
              color: const Color(0xFF9CA3AF),
              size: _opensInApp ? 22 : 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Failure state ─────────────────────────────────────────────────────────────

class _LoadFailed extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadFailed({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context).materialsLoadFailed,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppLocalizations.of(context).commonRetry,
              style: const TextStyle(
                color: Color(0xFF18C96A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
