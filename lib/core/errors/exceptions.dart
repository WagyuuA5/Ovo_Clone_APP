class InsufficientBalanceException implements Exception {
  final String message;
  InsufficientBalanceException([this.message = 'Saldo OVO Cash tidak mencukupi.']);

  @override
  String toString() => message;
}

class MinimumAmountException implements Exception {
  final String message;
  MinimumAmountException([this.message = 'Minimal transaksi adalah Rp 10.000.']);

  @override
  String toString() => message;
}
