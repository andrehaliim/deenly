import 'dart:async';

import 'package:deenly/models/surah_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _requestToken = 0;

  int _playedSurah = 0;
  int get playedSurah => _playedSurah;
  int _playedAyah = 0;
  int get playedAyah => _playedAyah;

  AudioProvider() {
    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await stopAll();
      }
    });
  }

  Future<void> stopAll() async {
    await _player.stop();
    _playedSurah = 0;
    _playedAyah = 0;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> testigz(SurahDetailModel surah, int index) async {
    if (_playedSurah == surah.chapterNo && _playedAyah == index) {
      await stopAll();
      return;
    }

    final myToken = ++_requestToken;

    _isLoading = true;
    _playedSurah = surah.chapterNo;
    _playedAyah = index;
    notifyListeners();
    final url = _getAyahUrl(surah: surah.chapterNo, ayah: surah.verseNo);

    try {
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Audio error: $e');
    } finally {
      if (myToken == _requestToken) {
        await stopAll();
      }
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
