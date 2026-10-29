import 'package:deenly/models/zakat_guide_model.dart';
import 'package:deenly/pages/zakat/zakat_guide_group_widget.dart';
import 'package:deenly/pages/zakat/zakat_guide_verse_widget.dart';
import 'package:flutter/material.dart';

/// One guide section as a card: title, then whichever of the body,
/// verses and item groups the section has, in that order.
class ZakatGuideSection extends StatelessWidget {
  final ZakatGuideSectionModel section;
  final String languageCode;

  const ZakatGuideSection({
    super.key,
    required this.section,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final body = section.body;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            section.title.of(languageCode),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 10),
            Text(
              body.of(languageCode),
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          for (final verse in section.verses) ...[
            const SizedBox(height: 14),
            ZakatGuideVerse(verse: verse, languageCode: languageCode),
          ],
          for (final group in section.groups) ...[
            const SizedBox(height: 14),
            ZakatGuideGroup(group: group, languageCode: languageCode),
          ],
        ],
      ),
    );
  }
}
