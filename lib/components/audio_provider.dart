import 'dart:async';

import 'package:deenly/models/reciter_model.dart';
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

  ReciterModel _reciter = ReciterModel.defaultReciter;
  bool _playTaawudz = false;
  bool _playBasmala = true;

  /// Reciter whose sample is playing in the settings sheet, if any.
  String? _previewReciterId;
  String? get previewReciterId => _previewReciterId;

  /// Applies the reader settings to the next playback.
  void updateSettings({
    required ReciterModel reciter,
    required bool playTaawudz,
    required bool playBasmala,
  }) {
    _reciter = reciter;
    _playTaawudz = playTaawudz;
    _playBasmala = playBasmala;
  }

  /// Falls back to the default reciter when the chosen folder has no
  /// ta'awudz clip.
  String get _taawudzUrl {
    final folder = _reciter.hasTaawudz
        ? _reciter.id
        : ReciterModel.defaultReciter.id;
    return 'https://everyayah.com/data/$folder/audhubillah.mp3';
  }

  /// Al-Fatihah 1:1 is the basmala, and every reciter folder has it.
  String get _basmalaUrl => _getAyahUrl(surah: 1, ayah: 1);

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
    _previewReciterId = null;
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
    _previewReciterId = null;
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

  Future<void> playMultiple(SurahModel surah, int startFrom) async {
    if (_playedSurah == surah.id) {
      await stopAll();
      return;
    }

    final myToken = ++_requestToken;

    // Intro clips only play before ayah 1. Al-Fatihah already opens with the
    // basmala as ayah 1 and At-Tawbah has none, so neither gets the
    // separate basmala clip.
    final intros = <String>[
      if (startFrom == 1 && _playTaawudz) _taawudzUrl,
      if (startFrom == 1 && _playBasmala && surah.id != 1 && surah.id != 9)
        _basmalaUrl,
    ];

    _isLoading = true;
    _playedSurah = surah.id;
    _previewReciterId = null;
    // Intros play on slot 0 (the surah header), so ayah 1 doesn't flash as
    // active before the playlist reports its first index.
    _playedAyah = intros.isNotEmpty ? 0 : startFrom;
    notifyListeners();

    await _player.stop();

    final start = startFrom;
    final end = surah.surahTotal;
    final playlist = <AudioSource>[
      for (final url in intros) AudioSource.uri(Uri.parse(url)),
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
        _playedAyah = i < intros.length ? 0 : start + (i - intros.length);
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

  /// Plays a short sample of [reciter], or stops it when it is already
  /// playing. Any surah playback stops first.
  Future<void> previewReciter(ReciterModel reciter) async {
    if (_previewReciterId == reciter.id) {
      await stopAll();
      return;
    }

    final myToken = ++_requestToken;

    _playedSurah = 0;
    _playedAyah = 0;
    _previewReciterId = reciter.id;
    notifyListeners();

    try {
      await _player.stop();
      await _player.setUrl(
        _getAyahUrl(surah: 1, ayah: 1, reciter: reciter.id),
      );
      await _player.play();
    } catch (e) {
      debugPrint('Audio error: $e');
    } finally {
      if (myToken == _requestToken) {
        await stopAll();
      }
    }
  }

  String _getAyahUrl({required int surah, required int ayah, String? reciter}) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/${reciter ?? _reciter.id}/$s$a.mp3';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
