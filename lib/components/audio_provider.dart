import 'dart:async';

import 'package:deenly/models/surah_detail_model.dart';
import 'package:deenly/models/surah_model.dart';
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

  final audhubillahUrl = 'https://everyayah.com/data/Alafasy_128kbps/audhubillah.mp3';
  final bismillahUrl = 'https://everyayah.com/data/Alafasy_128kbps/bismillah.mp3';

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

  Future<void> playSingle(SurahDetailModel surah, int index) async {
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

  Future<void> playMultiple(SurahModel surah) async {
    if (_playedSurah == surah.id) {
      await stopAll();
      return;
    }

    final myToken = ++_requestToken;

    _isLoading = true;
    _playedSurah = surah.id;
    _playedAyah = 0;
    notifyListeners();

    await _player.stop();

    final start = 1;
    final end = surah.surahTotal;
    final playlist = <AudioSource>[
      AudioSource.uri(Uri.parse(audhubillahUrl)),
      AudioSource.uri(Uri.parse(bismillahUrl)),
      for (int ayah = start; ayah <= end; ayah++)
        AudioSource.uri(Uri.parse(_getAyahUrl(surah: surah.id, ayah: ayah))),
    ];

    StreamSubscription<int?>? sub;
    try {
      await _player.setAudioSources(
        playlist,
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
      sub = _player.currentIndexStream.listen((i) {
        if (myToken != _requestToken || i == null) return;
        _playedSurah = surah.id;
        _playedAyah = i < 2 ? 0 : start + (i - 2);
        notifyListeners();
      });
      _isLoading = false;
      notifyListeners();
      await _player.play();
    } catch (e) {
      debugPrint('Audio error: $e');
    } finally {
      await sub?.cancel();
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
