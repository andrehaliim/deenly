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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Consumer<SurahProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return listSurah(provider);
            },
          ),
        ),
      ],
    );
  }

  Widget listSurah(SurahProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filterByJuz ? listPerJuz(provider) : listPerSurah(provider),
        ),
      ],
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
            /*final prefs = await SharedPreferences.getInstance();
                  prefs.setString('currentSurah', jsonEncode(data.toJson()));
                  prefs.setInt('lastAyahIndex', 0);*/
            bool refresh = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranDetailPage(surah: data),
              ),
            );
            if (refresh) {
              //loadCurrentSurah();
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
            Container(
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
          ],
        );
      },
    );
  }
}
