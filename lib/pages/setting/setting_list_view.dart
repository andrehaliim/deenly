import 'package:flutter/material.dart';

/// Scrolling body of the settings pages, with a slim scrollbar that shows
/// while the list is scrolled.
class SettingListView extends StatefulWidget {
  const SettingListView({super.key, required this.children});

  final List<Widget> children;

  @override
  State<SettingListView> createState() => _SettingListViewState();
}

class _SettingListViewState extends State<SettingListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RawScrollbar(
      controller: _scrollController,
      thickness: 4,
      radius: const Radius.circular(2),
      padding: const EdgeInsets.symmetric(vertical: 8),
      crossAxisMargin: 3,
      thumbColor: colorScheme.primary.withValues(alpha: 0.5),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: widget.children,
      ),
    );
  }
}
