/// Bridges the AppBar's jump action to the [SurahDetailList] that owns the
/// scroll controller. The list attaches itself while it is mounted.
class SurahJumpController {
  void Function(int ayah)? _onJump;

  void attach(void Function(int ayah) onJump) => _onJump = onJump;

  /// Only detaches when [onJump] is still the active listener, so an outgoing
  /// list during a surah transition does not detach the incoming one.
  void detach(void Function(int ayah) onJump) {
    if (_onJump == onJump) _onJump = null;
  }

  void jumpTo(int ayah) => _onJump?.call(ayah);
}
