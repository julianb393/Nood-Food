import 'package:nood_food/util/active_level.dart';

/// A Nood Food User Model.
class NFUser {
  String? uid;
  String? email;
  String? displayName;
  String? photoURL;
  String? dob;
  String? sex;
  double? weight;
  double? height;
  double? calorieLimit;
  ActiveLevel? activeLevel;
  bool isInit;
  NFUser(
      {this.uid,
      this.email,
      this.displayName,
      this.photoURL,
      this.dob,
      this.sex,
      this.weight,
      this.height,
      this.calorieLimit,
      this.activeLevel,
      required this.isInit});

  void updateUser(String? dob, String? sex, double? weight, double? height,
      double? calorieLimit, ActiveLevel? activeLevel, bool isInit) {
    this.dob = dob;
    this.sex = sex;
    this.weight = weight;
    this.height = height;
    this.calorieLimit = calorieLimit ?? 0;
    this.activeLevel = activeLevel;
    this.isInit = isInit;
  }

  @override
  int get hashCode => Object.hash(uid, email, displayName, photoURL, dob, sex,
      weight, height, calorieLimit, activeLevel);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NFUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          photoURL == other.photoURL &&
          dob == other.dob &&
          sex == other.sex &&
          weight == other.weight &&
          height == other.height &&
          calorieLimit == other.calorieLimit &&
          activeLevel == other.activeLevel);
}
