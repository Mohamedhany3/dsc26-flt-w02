/// How urgent a stock alert is. The order of the values is the display order:
/// critical first, low last.
enum Severity { critical, high, medium, low }

/// One stock alert for one branch, as sent by Nour head office.
///
/// Immutable: a change creates a new object through [copyWith].
/// Do not change the constructor, the fields or the method signatures.
final class StockAlert {
  const StockAlert({
    required this.id,
    required this.medicineNameEn,
    required this.medicineNameAr,
    required this.severity,
    required this.daysOfCover,
    required this.branchCode,
    this.acknowledged = false,
  });

  final String id;
  final String medicineNameEn;
  final String medicineNameAr;
  final Severity severity;
  final double daysOfCover;
  final String branchCode;
  final bool acknowledged;

  /// Reads one alert from the head-office JSON feed.
  ///
  /// TODO(W2): validate every field as the README says. Any invalid input
  /// throws a FormatException, never a TypeError.
  factory StockAlert.fromJson(Map<String, Object?> json) {
    String readString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Invalid $key');
      }
      return value;
    }

    final severityValue = readString('severity').toLowerCase();

    final Severity severity;

    switch (severityValue) {
      case 'critical':
        severity = Severity.critical;
      case 'high':
        severity = Severity.high;
      case 'medium':
        severity = Severity.medium;
      case 'low':
        severity = Severity.low;
      default:
        throw FormatException('Invalid severity');
    }

    final daysValue = json['daysOfCover'];

    if (daysValue is! num || !daysValue.isFinite || daysValue < 0) {
      throw FormatException('Invalid daysOfCover');
    }

    final double daysOfCover = daysValue.toDouble();

    final acknowledgedValue = json.containsKey('acknowledged')
        ? json['acknowledged']
        : false;

    if (acknowledgedValue is! bool) {
      throw FormatException('Invalid acknowledged');
    }

    final bool acknowledged = acknowledgedValue;

    return StockAlert(
      id: readString('id'),
      medicineNameEn: readString('medicineNameEn'),
      medicineNameAr: readString('medicineNameAr'),
      severity: severity,
      daysOfCover: daysOfCover,
      branchCode: readString('branchCode'),
      acknowledged: acknowledged,
    );
  }

  /// TODO(W2): return a new StockAlert with the given fields replaced.
  StockAlert copyWith({
    String? id,
    String? medicineNameEn,
    String? medicineNameAr,
    Severity? severity,
    double? daysOfCover,
    String? branchCode,
    bool? acknowledged,
  }) {
    return StockAlert(
      id: id ?? this.id,
      medicineNameEn: medicineNameEn ?? this.medicineNameEn,
      medicineNameAr: medicineNameAr ?? this.medicineNameAr,
      severity: severity ?? this.severity,
      daysOfCover: daysOfCover ?? this.daysOfCover,
      branchCode: branchCode ?? this.branchCode,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  /// TODO(W2): value equality over all seven fields.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StockAlert &&
            id == other.id &&
            medicineNameEn == other.medicineNameEn &&
            medicineNameAr == other.medicineNameAr &&
            severity == other.severity &&
            daysOfCover == other.daysOfCover &&
            branchCode == other.branchCode &&
            acknowledged == other.acknowledged);
  }

  /// TODO(W2): consistent with ==.
  @override
  int get hashCode => Object.hash(
    id,
    medicineNameEn,
    medicineNameAr,
    severity,
    daysOfCover,
    branchCode,
    acknowledged,
  );
}
