import 'package:deenly/components/app_theme.dart';
import 'package:deenly/pages/zakat/zakat_disclaimer_widget.dart';
import 'package:flutter/material.dart';

/// Shared layout of the zakat calculators: inputs on top, the result
/// below them and the disclaimer at the end.
class ZakatCalculatorScaffold extends StatelessWidget {
  final String title;
  final List<Widget> inputs;
  final Widget result;

  const ZakatCalculatorScaffold({
    super.key,
    required this.title,
    required this.inputs,
    required this.result,
  });

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
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            for (final input in inputs) ...[input, const SizedBox(height: 12)],
            const SizedBox(height: 8),
            result,
            const SizedBox(height: 16),
            const ZakatDisclaimer(),
          ],
        ),
      ),
    );
  }
}
