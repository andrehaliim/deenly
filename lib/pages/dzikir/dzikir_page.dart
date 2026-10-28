import 'package:deenly/models/dzikir_category_model.dart';
import 'package:deenly/pages/dzikir/dzikir_category_card_widget.dart';
import 'package:deenly/pages/dzikir/dzikir_detail_page.dart';
import 'package:deenly/pages/dzikir/dzikir_error_widget.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/proxys/dzikir_proxy.dart';
import 'package:flutter/material.dart';

/// Lists the dzikir categories as horizontal cards. Built to be pushed
/// from the home menu, which supplies the app bar.
class DzikirPage extends StatefulWidget {
  const DzikirPage({super.key});

  @override
  State<DzikirPage> createState() => _DzikirPageState();
}

class _DzikirPageState extends State<DzikirPage>
    with SingleTickerProviderStateMixin {
  final DzikirProxy _proxy = DzikirProxy();
  List<DzikirCategoryModel>? _categories;
  bool _isLoading = true;

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    List<DzikirCategoryModel>? categories;
    try {
      categories = await _proxy.getCategories();
    } catch (e, st) {
      debugPrint('Loading dzikir categories failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
    _entranceController.forward(from: 0);
  }

  void _openCategory(DzikirCategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DzikirDetailPage(category: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = _categories;
    if (categories == null || categories.isEmpty) {
      return DzikirError(onRetry: _loadCategories);
    }

    final languageCode = Localizations.localeOf(context).languageCode;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return StaggeredEntrance(
          animation: _entranceController,
          index: index,
          child: DzikirCategoryCard(
            category: category,
            name: category.name(languageCode),
            onTap: () => _openCategory(category),
          ),
        );
      },
    );
  }
}
