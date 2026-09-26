class Expense {
  Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.comment = '',
    this.payee = '',
    this.paymentMethod = 'other',
    this.tripId,
    List<String>? receiptPaths,
  }) : receiptPaths = receiptPaths ?? <String>[];

  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String comment;
  final String payee;
  final String paymentMethod;
  final String? tripId;
  final List<String> receiptPaths;

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'comment': comment,
        'payee': payee,
        'paymentMethod': paymentMethod,
        'tripId': tripId,
        'receiptPaths': receiptPaths,
      };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'] as String,
        amount: (m['amount'] as num).toDouble(),
        categoryId: m['categoryId'] as String,
        date: DateTime.parse(m['date'] as String),
        comment: (m['comment'] as String?) ?? '',
        payee: (m['payee'] as String?) ?? '',
        paymentMethod: (m['paymentMethod'] as String?) ?? 'other',
        tripId: m['tripId'] as String?,
        receiptPaths:
            ((m['receiptPaths'] as List?) ?? const []).cast<String>(),
      );

  Expense copyWith({
    double? amount,
    String? categoryId,
    DateTime? date,
    String? comment,
    String? payee,
    String? paymentMethod,
    String? tripId,
    bool clearTrip = false,
    List<String>? receiptPaths,
  }) =>
      Expense(
        id: id,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        date: date ?? this.date,
        comment: comment ?? this.comment,
        payee: payee ?? this.payee,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        tripId: clearTrip ? null : (tripId ?? this.tripId),
        receiptPaths: receiptPaths ?? this.receiptPaths,
      );
}
