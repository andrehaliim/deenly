import 'package:deenly/models/asmaul_husna_model.dart';
import 'package:deenly/pages/asmaul_husna/asmaul_husna_card_widget.dart';
import 'package:deenly/pages/asmaul_husna/asmaul_husna_error_widget.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/proxys/asmaul_husna_proxy.dart';
import 'package:flutter/material.dart';

/// Lists the 99 names in two columns. Built to be pushed from the home
/// menu, which supplies the app bar.
class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  State<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage>
    with SingleTickerProviderStateMixin {
  static const int _columns = 2;

  final AsmaulHusnaProxy _proxy = AsmaulHusnaProxy();
  List<AsmaulHusnaModel>? _names;
  bool _isLoading = true;

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadNames() async {
    setState(() => _isLoading = true);
    List<AsmaulHusnaModel>? names;
    try {
      names = await _proxy.getAll();
    } catch (e, st) {
      debugPrint('Loading asmaul husna failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _names = names;
      _isLoading = false;
    });
    _entranceController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final names = _names;
    if (names == null || names.isEmpty) {
      return AsmaulHusnaError(onRetry: _loadNames);
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    final rowCount = (names.length / _columns).ceil();

    /// Rows instead of a GridView so each pair of cards shares the height
    /// of the longer meaning, without a fixed aspect ratio that could
    /// overflow on small screens or large text.
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: rowCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, row) {
        final rowNames = names.skip(row * _columns).take(_columns).toList();
        return StaggeredEntrance(
          animation: _entranceController,
          index: row,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _columns; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: i < rowNames.length
                        ? AsmaulHusnaCard(
                            name: rowNames[i],
                            meaning: rowNames[i].meaning(languageCode),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
