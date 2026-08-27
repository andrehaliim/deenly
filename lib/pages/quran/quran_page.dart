import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/quran_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  SurahModel? currentSurah;
  int? lastSurahAyah;
  String code = '';
  bool filterByJuz = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurahProvider>().getSurahList();
      context.read<SurahProvider>().getJuzList();
      context.read<SurahProvider>().getContinueList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            provider.continueList.isNotEmpty
                ? listContinue(provider)
                : Container(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    'Surah List',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        filterByJuz = !filterByJuz;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withAlpha(100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filterByJuz ? 'Filter by : Juz' : 'Filter by : Surah',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      height: MediaQuery.of(context).size.height / 8,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.continueList.length,
        itemBuilder: (context, index) {
          final data = provider.continueList[index];
          return InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranDetailPage(
                    surah: data.surah,
                    juzFrom: data.ayahNumber,
                  ),
                ),
              );
              if (context.mounted) {
                context.read<SurahProvider>().getContinueList();
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 8,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withAlpha(100),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.surah.name(provider.code ?? 'id'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Ayat ${data.ayahNumber}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget listPerSurah(SurahProvider provider) {
    final size = MediaQuery.sizeOf(context);
    final maxWidth = size.width;
    final maxHeight = size.height;

    if (provider.surahList.isEmpty) {
      return const Center(child: Text('No Surah found'));
    }

    final surahList = provider.surahList;
    final code = provider.code;
    return ListView.builder(
      itemCount: surahList.length,
      itemBuilder: (context, index) {
        final data = surahList[index];

        return InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranDetailPage(surah: data, juzFrom: 0),
              ),
            );
            if (context.mounted) {
              context.read<SurahProvider>().getContinueList();
            }
          },
          child: Container(
            width: double.infinity,
            height: maxHeight / 9,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Container(
                  width: maxWidth / 6,
                  alignment: Alignment.center,
                  child: Text(
                    data.id.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.name(code),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          FaIcon(
                            data.surahFrom == 1
                                ? FontAwesomeIcons.kaaba
                                : FontAwesomeIcons.mosque,
                            size: Theme.of(
                              context,
                            ).textTheme.bodySmall?.fontSize,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.5),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            '${data.surahTotal} ${AppLocalizations.of(context)!.ayah}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(alpha: 0.5),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: maxWidth / 4,
                  alignment: Alignment.center,
                  child: Text(
                    data.nameArab,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget listPerJuz(SurahProvider provider) {
    final size = MediaQuery.sizeOf(context);
    final maxWidth = size.width;
    final maxHeight = size.height;

    if (provider.surahJuzList.isEmpty) {
      return const Center(child: Text('No Juz found'));
    }

    final juzList = provider.surahJuzList;
    final code = provider.code;
    return ListView.builder(
      itemCount: juzList.length,
      itemBuilder: (context, index) {
        final juz = juzList[index];
        final data = juz.surahDetail;
        final isNewJuz =
            index == 0 || juz.juzNumber != juzList[index - 1].juzNumber;

        return Column(
          children: [
            if (isNewJuz)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Juz ${juz.juzNumber}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ),
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuranDetailPage(
                      surah: data,
                      juzFrom: juz.surahFrom > 1 ? juz.surahFrom : 0,
                    ),
                  ),
                );
                if (context.mounted) {
                  context.read<SurahProvider>().getContinueList();
                }
              },
              child: Container(
                width: double.infinity,
                height: maxHeight / 9,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Container(
                      width: maxWidth / 6,
                      alignment: Alignment.center,
                      child: Text(
                        juz.juzNumber.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.name(code),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              FaIcon(
                                data.surahFrom == 1
                                    ? FontAwesomeIcons.kaaba
                                    : FontAwesomeIcons.mosque,
                                size: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.fontSize,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.5),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                'Ayah ${juz.surahFrom} - ${juz.surahTo}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.5),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: maxWidth / 4,
                      alignment: Alignment.center,
                      child: Text(
                        data.nameArab,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
