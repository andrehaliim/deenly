import 'dart:convert';

import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/quran_detail_page.dart';
import 'package:deenly/proxys/quran_proxy.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final QuranProxy quranProxy = QuranProxy();
  List<SurahModel> surahList = [];
  bool isLoading = false;
  SurahModel? currentSurah;
  int? lastSurahAyah;

  @override
  void initState() {
    super.initState();
    loadSurahList();
    loadCurrentSurah();
  }

  void loadCurrentSurah() async {
    final prefs = await SharedPreferences.getInstance();

    final surahString = prefs.getString('currentSurah');
    final lastAyahIndex = prefs.getInt('lastAyahIndex');

    if (surahString != null) {
      final surahMap = jsonDecode(surahString);
      setState(() {
        currentSurah = SurahModel.fromJsonLocal(surahMap);
        lastSurahAyah = lastAyahIndex;
      });
    }
  }

  void loadSurahList() async {
    setState(() {
      isLoading = true;
    });
    surahList = await quranProxy.getSurahList();
    setState(() {
      isLoading = false;
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
          currentSurah != null
              ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage('assets/images/quran_background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      bool refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QuranDetailPage(surah: currentSurah!),
                        ),
                      );
                      if (refresh) {
                        loadCurrentSurah();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Continue Reading',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                currentSurah!.name,
                                style: GoogleFonts.notoSerif(
                                  fontSize: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Ayah No: $lastSurahAyah',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 12),
          Text(
            'Al Quran',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : listSurah(surahList),
          ),
        ],
      ),
    );
  }

  Widget listSurah(List<SurahModel> surahList) {
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
              loadCurrentSurah();
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
                      data.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                    Row(
                      children: [
                        FaIcon(
                          data.revelation == 'Madina'
                              ? FontAwesomeIcons.mosque
                              : FontAwesomeIcons.kaaba,
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
                          '${data.totalAyahs} Ayahs',
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
                  data.arabicname,
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
