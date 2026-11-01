import 'package:deenly/components/app_theme.dart';
import 'package:deenly/pages/setting/setting_list_view.dart';
import 'package:flutter/material.dart';

/// Page opened from a [SettingTile] for a group of settings too long to
/// show on the main settings page.
class SettingSubpage extends StatelessWidget {
  const SettingSubpage({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: theme.extension<AppTextStyles>()?.brandTitle),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SettingListView(
          children: [
            for (final (index, child) in children.indexed) ...[
              if (index > 0) const SizedBox(height: 20),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

/// Chevron shown as the trailing control of a tile that opens a
/// [SettingSubpage].
class SettingChevron extends StatelessWidget {
  const SettingChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
