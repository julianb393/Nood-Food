/// A Nood Food User Model.
class NFUser {
  final String uid;
  String? displayName;
  String? dob;
  String? sex;
  double? weight;
  double? height;
  double? calorieLimit;
  NFUser({required this.uid, this.displayName});

  void updateUser(String? dob, String? sex, double? weight, double? height,
      double? calorieLimit) {
    this.dob = dob;
    this.sex = sex;
    this.weight = weight;
    this.height = height;
    this.calorieLimit = calorieLimit;
  }
}
