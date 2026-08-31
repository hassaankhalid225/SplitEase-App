class SettlementTransfer {
  final String fromPersonId;
  final String toPersonId;
  final double amount;

  SettlementTransfer({
    required this.fromPersonId,
    required this.toPersonId,
    required this.amount,
  });
}

class SettlementCalculator {
  /// Calculates who pays whom, given one payer covered the whole bill.
  ///
  /// [shares] maps personId -> total owed (items + tax + service + tip),
  /// i.e. the output of [SplitCalculator.calculate].
  static List<SettlementTransfer> calculate({
    required String payerId,
    required Map<String, double> shares,
  }) {
    final transfers = <SettlementTransfer>[];

    shares.forEach((personId, amount) {
      if (personId != payerId && amount > 0.005) {
        transfers.add(SettlementTransfer(
          fromPersonId: personId,
          toPersonId: payerId,
          amount: double.parse(amount.toStringAsFixed(2)),
        ));
      }
    });

    // Largest payments first for better readability
    transfers.sort((a, b) => b.amount.compareTo(a.amount));
    return transfers;
  }
}
