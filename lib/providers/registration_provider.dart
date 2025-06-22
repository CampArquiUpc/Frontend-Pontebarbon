import 'package:flutter/material.dart';
import 'package:pontebarbon/models/user_model.dart';

class RegistrationProvider extends ChangeNotifier {
  final UserModel user = UserModel();

  // Update personal information
  void updatePersonalInfo({
    required String fullName,
    required String email,
    required DateTime dateOfBirth,
    required String gender,
    required String password,
  }) {
    user.fullName = fullName;
    user.email = email;
    user.dateOfBirth = dateOfBirth;
    user.gender = gender;
    user.password = password;
    notifyListeners();
  }

  // Update financial preferences
  void updateFinancialPreferences({
    required bool isSaving,
    required String incomeRange,
    required List<String> financialGoals,
  }) {
    user.isSaving = isSaving;
    user.incomeRange = incomeRange;
    user.financialGoals = financialGoals;
    notifyListeners();
  }

  // Reset user data
  void reset() {
    user.fullName = null;
    user.email = null;
    user.dateOfBirth = null;
    user.gender = null;
    user.password = null;
    user.isSaving = null;
    user.incomeRange = null;
    user.financialGoals = null;
    notifyListeners();
  }
}
