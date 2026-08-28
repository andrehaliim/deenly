import 'dart:async';

import 'package:deenly/models/surah_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  int? currentSurah;
  int? currentAyah;
  bool isPlaying = false;
  String selectedReciter = 'Alafasy_128kbps';
  bool autoContinue = false;

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;
  int _detailSurah = 0;
  int get detailSurah => _detailSurah;
  int _detailIndex = 0;
  int get detailIndex => _detailIndex;

  AudioProvider() {
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;

      if (state.processingState == ProcessingState.completed) {
        currentAyah = null;
        currentSurah = null;
      }
      notifyListeners();
    });
  }

  Future<void> testigz(SurahDetailModel surah, int index) async {
    if (isPlaying) {
      await _player.stop();
    }
    _isDetailLoading = true;
    _detailSurah = surah.chapterNo;
    _detailIndex = index;
    notifyListeners();
    final url = _getAyahUrl(
      surah: surah.chapterNo,
      ayah: surah.verseNo,
      reciter: selectedReciter,
    );

    try {
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Audio error: $e');
    } finally {
      _isDetailLoading = false;
      _detailIndex = 0;
      _detailSurah = 0;
      notifyListeners();
    }
  }

  static String _getAyahUrl({
    required int surah,
    required int ayah,
    String reciter = 'Alafasy_128kbps',
  }) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$reciter/$s$a.mp3';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
