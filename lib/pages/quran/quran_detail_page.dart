import 'package:deenly/models/surah_detail_model.dart';
import 'package:deenly/models/surah_list_model.dart';
import 'package:deenly/proxys/quran_proxy.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranDetailPage extends StatefulWidget {
  final SurahListModel surah;
  const QuranDetailPage({super.key, required this.surah});

  @override
  State<QuranDetailPage> createState() => _QuranDetailPageState();
}

class _QuranDetailPageState extends State<QuranDetailPage> {
  final quranProxy = QuranProxy();
  List<SurahDetailModel> surahDetailList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSurahDetail();
  }

  void loadSurahDetail() async {
    setState(() {
      isLoading = true;
    });
    surahDetailList = await quranProxy.getSurahDetail(widget.surah.chapter);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Quran',
          style: GoogleFonts.notoSerif(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.25),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.surah.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.surah.englishname,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
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
                          '${widget.surah.verses} Ayahs',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'بِسْمِ ٱللّٰهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : listSurahDetail(surahDetailList),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listSurahDetail(List<SurahDetailModel> surahDetailList) {
    return ListView.builder(
      itemCount: surahDetailList.length,
      itemBuilder: (context, index) {
        final data = surahDetailList[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 75,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.25),
                  ),
                  child: Text(
                    '${data.chapter}:${data.verse}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            const SizedBox(height: 30),
            Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  data.text,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              data.translation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).colorScheme.onTertiary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              color: Theme.of(
                context,
              ).colorScheme.onTertiary.withValues(alpha: 0.25),
            ),
          ],
        );
      },
    );
  }
}
