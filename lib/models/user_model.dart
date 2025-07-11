class UserModel {
  String? fullName;
  String? email;
  DateTime? dateOfBirth;
  String? gender;
  String? password;

  // Financial preferences
  bool? isSaving;
  String? incomeRange;
  List<String>? financialGoals;
  double monthlyBudget;

  UserModel({
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.password,
    this.isSaving,
    this.incomeRange,
    this.financialGoals,
    this.monthlyBudget = 0.0,
  });

  // Convert to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'isSaving': isSaving == true ? 1 : 0,
      'incomeRange': incomeRange,
      'financialGoals': financialGoals?.join(','),
      'monthlyBudget': monthlyBudget,
    };
  }

  // Create User from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'],
      password: map['password'],
      fullName: map['fullName'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
      gender: map['gender'],
      isSaving: map['isSaving'] == 1,
      incomeRange: map['incomeRange'],
      financialGoals: map['financialGoals']?.split(','),
      monthlyBudget: map['monthlyBudget'] != null
          ? (map['monthlyBudget'] as num).toDouble()
          : 0.0,
    );
  }
}
