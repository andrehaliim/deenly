import 'package:flutter/material.dart';

/// Settings row: icon badge, title, optional [titleSuffix] and a
/// [trailing] control. Tappable when [onTap] is set.
class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.titleSuffix,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final Widget? titleSuffix;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suffix = titleSuffix;
    final trailingWidget = trailing;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _IconBadge(icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (suffix != null) ...[const SizedBox(width: 10), suffix],
                  ],
                ),
              ),
              if (trailingWidget != null) ...[
                const SizedBox(width: 8),
                trailingWidget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Option of a [SettingDropdownTile].
class SettingDropdownItem<T> {
  const SettingDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// Settings row with a full-width field under its title that expands
/// downward into a scrollable list of [items], for options whose labels
/// are too long for a [SettingTile.trailing] control.
class SettingDropdownTile<T> extends StatefulWidget {
  const SettingDropdownTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final T value;
  final List<SettingDropdownItem<T>> items;

  /// Null disables the field.
  final ValueChanged<T>? onChanged;

  @override
  State<SettingDropdownTile<T>> createState() => _SettingDropdownTileState<T>();
}

class _SettingDropdownTileState<T> extends State<SettingDropdownTile<T>> {
  static const double _maxListHeight = 280;
  static const Duration _duration = Duration(milliseconds: 250);

  final ScrollController _scrollController = ScrollController();
  bool _isOpen = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SettingDropdownTile<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onChanged == null) _isOpen = false;
  }

  void _select(T value) {
    setState(() => _isOpen = false);
    if (value != widget.value) widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = widget.onChanged != null;
    final selected = widget.items
        .where((item) => item.value == widget.value)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _IconBadge(icon: widget.icon),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: enabled
                        ? () => setState(() => _isOpen = !_isOpen)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selected?.label ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: enabled
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: _isOpen ? 0.5 : 0,
                            duration: _duration,
                            curve: Curves.easeInOut,
                            child: Icon(
                              Icons.expand_more_rounded,
                              color: enabled
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: _duration,
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _isOpen
                        ? _buildList(theme, selected)
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme, SettingDropdownItem<T>? selected) {
    final colorScheme = theme.colorScheme;
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        divider,
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _maxListHeight),
          // Only painted when the items overflow the list.
          child: RawScrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            thickness: 3,
            radius: const Radius.circular(2),
            padding: const EdgeInsets.symmetric(vertical: 6),
            mainAxisMargin: 2,
            crossAxisMargin: 3,
            thumbColor: colorScheme.primary.withValues(alpha: 0.5),
            child: ListView.separated(
              controller: _scrollController,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: widget.items.length,
              separatorBuilder: (_, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: divider,
              ),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = item == selected;

                return InkWell(
                  onTap: () => _select(item.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: colorScheme.primary),
    );
  }
}

/// Compact switch used as a [SettingTile.trailing] control.
class SettingSwitch extends StatelessWidget {
  const SettingSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        padding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
