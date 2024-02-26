import 'package:nood_food/util/active_level.dart';

/// A Nood Food User Model.
class NFUser {
  final String uid;
  String? displayName;
  String? photoURL;
  String? dob;
  String? sex;
  double? weight;
  double? height;
  double? calorieLimit;
  ActiveLevel? activeLevel;
  NFUser({required this.uid, this.displayName, this.photoURL});

  void updateUser(String? dob, String? sex, double? weight, double? height,
      double? calorieLimit, ActiveLevel? activeLevel) {
    this.dob = dob;
    this.sex = sex;
    this.weight = weight;
    this.height = height;
    this.calorieLimit = calorieLimit;
    this.activeLevel = activeLevel;
  }
}
