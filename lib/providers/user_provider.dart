import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String _firstName = "User";
  String? _fullName;
  String? _email;

  String get firstName => _firstName;
  String? get fullName => _fullName;
  String? get email => _email;

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
    notifyListeners();
  }
}
