import 'package:flutter/foundation.dart';
import 'package:pontebarbon/services/database_helper.dart';
import 'package:pontebarbon/models/user_model.dart';
import 'package:pontebarbon/models/expense_model.dart';

class UserProvider extends ChangeNotifier {
  String _firstName = "User";
  String? _fullName;
  String? _email;
  double _monthlyBudget = 0.0;
  double _totalExpenses = 0.0;
  List<ExpenseModel> _expenses = [];

  String get firstName => _firstName;
  String? get fullName => _fullName;
  String? get email => _email;
  double get monthlyBudget => _monthlyBudget;
  double get totalExpenses => _totalExpenses;
  double get remainingBudget => _monthlyBudget - _totalExpenses;
  List<ExpenseModel> get expenses => _expenses;

  void setUserData({String? fullName, String? email}) {
    _fullName = fullName;
    _email = email;

    if (fullName != null && fullName.isNotEmpty) {
      _firstName = fullName.split(' ').first;
    } else {
      _firstName = "User";
    }

    notifyListeners();
  }

  void clearUserData() {
    _firstName = "User";
    _fullName = null;
    _email = null;
    _monthlyBudget = 0.0;
    _totalExpenses = 0.0;
    _expenses = [];
    notifyListeners();
  }

  Future<void> loadUser(String email) async {
    final db = DatabaseHelper();
    final userData = await db.getUserByEmail(email);

    if (userData != null) {
      final user = UserModel.fromMap(userData);
      _fullName = user.fullName;
      _firstName = user.fullName?.split(' ').first ?? 'User';
      _email = user.email ?? '';
      _monthlyBudget = user.monthlyBudget;

      // Load expenses for this user
      await loadExpenses();

      notifyListeners();
    }
  }

  Future<void> loadExpenses() async {
    if (_email == null || _email!.isEmpty) return;

    try {
      final db = DatabaseHelper();
      _expenses = await db.getExpensesByUser(_email!);
      _totalExpenses = await db.getTotalExpensesByUser(_email!);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading expenses: $e');
      }
    }
  }

  Future<bool> updateMonthlyBudget(double budget) async {
    if (_email == null || _email!.isEmpty) return false;

    try {
      final db = DatabaseHelper();
      final dbClient = await db.database;

      await dbClient.update(
        'users',
        {'monthlyBudget': budget},
        where: 'email = ?',
        whereArgs: [_email],
      );

      _monthlyBudget = budget;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating monthly budget: \$e');
      }
      return false;
    }
  }

  Future<bool> addExpense(String description, double amount) async {
    if (_email == null || _email!.isEmpty) return false;

    try {
      final expense = ExpenseModel(
        userEmail: _email,
        description: description,
        amount: amount,
        date: DateTime.now(),
      );

      final db = DatabaseHelper();
      final id = await db.insertExpense(expense);

      if (id > 0) {
        expense.id = id;
        _expenses.insert(0, expense); // Add to the beginning of the list
        _totalExpenses += amount;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding expense: $e');
      }
      return false;
    }
  }

  Future<bool> deleteExpense(int id, double amount) async {
    try {
      final db = DatabaseHelper();
      final result = await db.deleteExpense(id);

      if (result > 0) {
        _expenses.removeWhere((expense) => expense.id == id);
        _totalExpenses -= amount;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting expense: $e');
      }
      return false;
    }
  }
}
