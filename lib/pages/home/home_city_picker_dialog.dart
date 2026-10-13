import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HomeCityPickerDialog extends StatefulWidget {
  const HomeCityPickerDialog({super.key});

  @override
  State<HomeCityPickerDialog> createState() => _HomeCityPickerDialogState();
}

class _HomeCityPickerDialogState extends State<HomeCityPickerDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final cityName = _controller.text.trim();
    if (cityName.isEmpty) return;
    Navigator.pop(context, cityName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.chooseCity ?? ''),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: l10n?.cityNameHint),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? ''),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n?.useCity ?? '')),
      ],
    );
  }
}
