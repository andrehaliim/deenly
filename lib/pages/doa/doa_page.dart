import 'package:deenly/models/doa_model.dart';
import 'package:deenly/pages/doa/doa_detail_page.dart';
import 'package:deenly/pages/doa/doa_error_widget.dart';
import 'package:deenly/pages/doa/doa_group_card_widget.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/proxys/doa_proxy.dart';
import 'package:flutter/material.dart';

/// Lists the doa categories as horizontal cards. Built to be pushed from
/// the home menu, which supplies the app bar.
class DoaPage extends StatefulWidget {
  const DoaPage({super.key});

  @override
  State<DoaPage> createState() => _DoaPageState();
}

class _DoaPageState extends State<DoaPage> with SingleTickerProviderStateMixin {
  final DoaProxy _proxy = DoaProxy();
  List<DoaGroupModel>? _groups;
  bool _isLoading = true;

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);
    List<DoaGroupModel>? groups;
    try {
      groups = await _proxy.getGroups();
    } catch (e, st) {
      debugPrint('Loading doa groups failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _groups = groups;
      _isLoading = false;
    });
    _entranceController.forward(from: 0);
  }

  void _openGroup(DoaGroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DoaDetailPage(group: group)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final groups = _groups;
    if (groups == null || groups.isEmpty) {
      return DoaError(onRetry: _loadGroups);
    }

    final languageCode = Localizations.localeOf(context).languageCode;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = groups[index];
        return StaggeredEntrance(
          animation: _entranceController,
          index: index,
          child: DoaGroupCard(
            group: group,
            name: group.name(languageCode),
            onTap: () => _openGroup(group),
          ),
        );
      },
    );
  }
}
