enum ZakatStatus { obligatory, belowNisab, notHaul }

class ZakatResultModel {
  static const double rate = 0.025;

  final double base;
  final double nisab;
  final ZakatStatus status;

  const ZakatResultModel({
    required this.base,
    required this.nisab,
    required this.status,
  });

  /// Below nisab takes precedence over haul: wealth under the nisab is
  /// never zakatable, however long it has been held.
  factory ZakatResultModel.evaluate({
    required double base,
    required double nisab,
    bool haul = true,
  }) {
    final ZakatStatus status;
    if (base < nisab) {
      status = ZakatStatus.belowNisab;
    } else if (!haul) {
      status = ZakatStatus.notHaul;
    } else {
      status = ZakatStatus.obligatory;
    }
    return ZakatResultModel(base: base, nisab: nisab, status: status);
  }

  double get amount => status == ZakatStatus.obligatory ? base * rate : 0;
}
