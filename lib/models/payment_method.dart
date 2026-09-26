enum PaymentMethod {
  card('card', 'Карта'),
  cash('cash', 'Наличные'),
  qr('qr', 'QR-код'),
  other('other', 'Иной');

  const PaymentMethod(this.id, this.label);

  final String id;
  final String label;

  static PaymentMethod fromId(String? id) => PaymentMethod.values.firstWhere(
        (m) => m.id == id,
        orElse: () => PaymentMethod.other,
      );
}
