import 'dart:convert';

import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/quran_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  SurahModel? currentSurah;
  int? lastSurahAyah;
  String code = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurahProvider>().getSurahList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
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
      ),
    );
  }

  Widget listSurah(SurahProvider provider) {
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
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('currentSurah', jsonEncode(data.toJson()));
            prefs.setInt('lastAyahIndex', 0);
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
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    data.id.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name(code),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                    Row(
                      children: [
                        FaIcon(
                          data.surahFrom == 1
                              ? FontAwesomeIcons.kaaba
                              : FontAwesomeIcons.mosque,
                          size: Theme.of(context).textTheme.bodySmall?.fontSize,
                          color: Theme.of(
                            context,
                          ).colorScheme.onTertiary.withValues(alpha: 0.5),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiary.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          '${data.surahTotal} ${AppLocalizations.of(context)!.ayah}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiary.withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  data.nameArab,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).colorScheme.onTertiary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
