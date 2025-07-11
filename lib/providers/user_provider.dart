import 'package:flutter/foundation.dart';
import 'package:pontebarbon/services/database_helper.dart';
import 'package:pontebarbon/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  String _firstName = "User";
  String? _fullName;
  String? _email;
  double _monthlyBudget = 0.0;

  String get firstName => _firstName;
  String? get fullName => _fullName;
  String? get email => _email;
  double get monthlyBudget => _monthlyBudget;

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
      notifyListeners();
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
}
