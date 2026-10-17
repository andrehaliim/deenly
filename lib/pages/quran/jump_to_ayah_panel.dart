import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dropdown panel under the AppBar, styled like [SurahOptionsPanel], where
/// the user types an ayah number to jump to.
class JumpToAyahPanel extends StatefulWidget {
  final int totalAyahs;
  final ValueChanged<int> onAyahSubmitted;

  const JumpToAyahPanel({
    super.key,
    required this.totalAyahs,
    required this.onAyahSubmitted,
  });

  @override
  State<JumpToAyahPanel> createState() => _JumpToAyahPanelState();
}

class _JumpToAyahPanelState extends State<JumpToAyahPanel> {
  final TextEditingController _textController = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final ayah = int.tryParse(_textController.text);
    if (ayah == null || ayah < 1 || ayah > widget.totalAyahs) {
      setState(() => _showError = true);
      return;
    }
    widget.onAyahSubmitted(ayah);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final total = widget.totalAyahs;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.go,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(total.toString().length),
              ],
              decoration: InputDecoration(
                hintText: l10n?.jumpToAyahHint(total) ?? '',
                errorText: _showError ? l10n?.jumpToAyahInvalid(total) : null,
                prefixIcon: const Icon(Icons.format_list_numbered_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              onChanged: (_) {
                if (_showError) setState(() => _showError = false);
              },
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _submit,
              child: Text(l10n?.jumpToAyahGo ?? ''),
            ),
          ),
        ],
      ),
    );
  }
}
