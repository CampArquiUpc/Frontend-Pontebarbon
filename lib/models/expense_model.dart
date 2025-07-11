class ExpenseModel {
  int? id;
  String? userEmail;
  String description;
  double amount;
  DateTime date;

  ExpenseModel({
    this.id,
    this.userEmail,
    required this.description,
    required this.amount,
    required this.date,
  });

  // Convert to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  // Create Expense from a map
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      userEmail: map['userEmail'],
      description: map['description'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }
}
