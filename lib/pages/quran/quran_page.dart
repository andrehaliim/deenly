import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/continue_card_widget.dart';
import 'package:deenly/pages/quran/quran_detail_page.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/pages/quran/surah_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => QuranPageState();
}

class QuranPageState extends State<QuranPage>
    with SingleTickerProviderStateMixin {
  SurahModel? currentSurah;
  int? lastSurahAyah;
  String code = '';
  bool filterByJuz = false;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  void toggleSearch() {
    final provider = context.read<SurahProvider>();
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
    if (!_isSearching) {
      provider.searchSurah('');
    }
  }

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<SurahProvider>();
      await provider.getSurahList();
      if (mounted) _entranceController.forward(from: 0);
      provider.getJuzList();
      provider.getContinueList();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      filterByJuz = !filterByJuz;
    });
    _entranceController.forward(from: 0);
  }

  Future<void> _openSurah(SurahModel surah, int juzFrom, String code) async {
    if (_isSearching) toggleSearch();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuranDetailPage(surah: surah, juzFrom: juzFrom, code: code),
      ),
    );
    if (mounted) {
      context.read<SurahProvider>().getContinueList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final l10n = AppLocalizations.of(context);
        final colorScheme = Theme.of(context).colorScheme;

        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _isSearching
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: TextField(
                        key: const ValueKey('searchField'),
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: true,
                        cursorColor: colorScheme.primary,
                        onChanged: (value) {
                          setState(() {
                            filterByJuz = false;
                          });
                          provider.searchSurah(value);
                        },
                        decoration: InputDecoration(
                          hintText: l10n?.searchSurahHint,
                          hintStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: colorScheme.onTertiary),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: provider.continueList.isNotEmpty
                  ? Column(
                      children: [
                        _SectionTitle(title: l10n?.continueRead ?? ''),
                        const SizedBox(height: 10),
                        listContinue(provider),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
            _SectionTitle(
              title: l10n?.surahList ?? '',
              trailing: _FilterToggle(
                filterByJuz: filterByJuz,
                onTap: _toggleFilter,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filterByJuz
                  ? listPerJuz(provider)
                  : listPerSurah(provider),
            ),
          ],
        );
      },
    );
  }

  Widget listContinue(SurahProvider provider) {
    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        clipBehavior: Clip.none,
        itemCount: provider.continueList.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final data = provider.continueList[index];
          return StaggeredEntrance(
            animation: _entranceController,
            index: index,
            slideFrom: const Offset(0.3, 0),
            child: ContinueCard(
              data: data,
              langCode: provider.code ?? 'id',
              onTap: () => _openSurah(data.surah, data.ayahNumber, code),
            ),
          );
        },
      ),
    );
  }

  Widget listPerSurah(SurahProvider provider) {
    final l10n = AppLocalizations.of(context);

    if (provider.surahList.isEmpty) {
      return Center(child: Text(l10n?.noSurahFound ?? ''));
    }

    final surahList = provider.surahList;
    final code = provider.code;
    return ListView.builder(
      key: const ValueKey('surahList'),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: surahList.length,
      itemBuilder: (context, index) {
        final data = surahList[index];

        return StaggeredEntrance(
          animation: _entranceController,
          index: index,
          child: SurahCard(
            number: data.id,
            title: data.name(code),
            subtitle: '${data.surahTotal} ${l10n?.ayah ?? ''}',
            arabicName: data.nameArab,
            isMakkiyah: data.surahFrom == 1,
            onTap: () => _openSurah(data, 0, code ?? 'en'),
          ),
        );
      },
    );
  }

  Widget listPerJuz(SurahProvider provider) {
    final l10n = AppLocalizations.of(context);

    if (provider.surahJuzList.isEmpty) {
      return Center(child: Text(l10n?.noJuzFound ?? ''));
    }

    final juzList = provider.surahJuzList;
    final code = provider.code;
    return ListView.builder(
      key: const ValueKey('juzList'),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: juzList.length,
      itemBuilder: (context, index) {
        final juz = juzList[index];
        final data = juz.surahDetail;
        final isNewJuz =
            index == 0 || juz.juzNumber != juzList[index - 1].juzNumber;

        return StaggeredEntrance(
          animation: _entranceController,
          index: index,
          child: Column(
            children: [
              if (isNewJuz)
                _JuzHeader(
                  label: l10n?.juzNumber(juz.juzNumber.toString()) ?? '',
                ),
              SurahCard(
                number: juz.juzNumber,
                title: data.name(code),
                subtitle:
                    l10n?.ayahRange(
                      juz.surahFrom.toString(),
                      juz.surahTo.toString(),
                    ) ??
                    '',
                arabicName: data.nameArab,
                isMakkiyah: data.surahFrom == 1,
                onTap: () => _openSurah(
                  data,
                  juz.surahFrom > 1 ? juz.surahFrom : 0,
                  code ?? 'en',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailing = this.trailing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onTertiary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final bool filterByJuz;
  final VoidCallback onTap;

  const _FilterToggle({required this.filterByJuz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final label = filterByJuz ? l10n?.filterByJuz : l10n?.filterBySurah;

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: filterByJuz ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Icon(
                  Icons.swap_vert_rounded,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    child: child,
                  ),
                ),
                child: Text(
                  label ?? '',
                  key: ValueKey(filterByJuz),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JuzHeader extends StatelessWidget {
  final String label;

  const _JuzHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final divider = Expanded(
      child: Divider(
        color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        height: 1,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          divider,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
          divider,
        ],
      ),
    );
  }
}
