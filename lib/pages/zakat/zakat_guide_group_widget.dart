import 'package:deenly/models/zakat_guide_model.dart';
import 'package:flutter/material.dart';

/// A numbered list of items, with an optional heading above it and an
/// optional note below it.
class ZakatGuideGroup extends StatelessWidget {
  final ZakatGuideGroupModel group;
  final String languageCode;

  const ZakatGuideGroup({
    super.key,
    required this.group,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = group.title;
    final note = group.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(
            title.of(languageCode),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
        ],
        for (final (index, item) in group.items.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GuideItem(
              number: index + 1,
              item: item,
              languageCode: languageCode,
            ),
          ),
        if (note != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  note.of(languageCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _GuideItem extends StatelessWidget {
  final int number;
  final ZakatGuideItemModel item;
  final String languageCode;

  const _GuideItem({
    required this.number,
    required this.item,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final description = item.description;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title.of(languageCode),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description.of(languageCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
