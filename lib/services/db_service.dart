import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/models/nutritional_facts.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/util/meal_type.dart';

class DBService {
  final String? uid;
  DBService({this.uid});

  final DateFormat _df = DateFormat('yyyy-MM-dd');

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  NutritionalFacts _parseNutritionFromDocMap(Map<String, dynamic> nt) {
    return NutritionalFacts(
      amount: nt['amount'] ?? 0.0,
      protein: nt['protein'] ?? 0.0,
      carbs: nt['carbs'] ?? 0.0,
      fat: nt['fat'] ?? 0.0,
    );
  }

  Food _parseFoodFromDoc(QueryDocumentSnapshot doc) {
    return Food(
      uid: doc.id,
      name: doc.get('name'),
      consumedAmount: doc.get('consumed_amount'),
      consumedUom: doc.get('consumed_uom'),
      nutrition: _parseNutritionFromDocMap(doc.get('nutritional_facts')),
      meal: MealTypeExtension.parseString(doc.get('meal')),
    );
  }

  /// Stream used for live updates to widgets
  Stream<List<Food>> getFoodsFromDate(DateTime date) {
    return _userCollection
        .doc(uid)
        .collection(_df.format(date))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _parseFoodFromDoc(doc)).toList());
  }

  NFUser? _parseUserFromSnapshot(DocumentSnapshot snapshot) {
    NFUser? user = AuthService().currentUser;
    if (user == null) return null;

    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    String? dob = data?['dob'];
    String? sex = data?['sex'];
    double? weight = data?['weight'];
    double? height = data?['height'];
    double? calorieLimit = data?['calorie_limit'];

    user.updateUser(dob, sex, weight, height, calorieLimit);
    return user;
  }

  Stream<NFUser?> get userAccountInfo {
    return _userCollection.doc(uid).snapshots().map(_parseUserFromSnapshot);
  }

  Future<List<Food>> getLastTwoDaysOfFoods() async {
    List<Food> foods = [];
    DateTime now = DateTime.now();
    String dayZero = _df.format(now);
    String dayOne = _df.format(now.subtract(const Duration(days: 1)));
    String dayTwo = _df.format(now.subtract(const Duration(days: 2)));

    QuerySnapshot qsZero = await _userCollection
        .doc(uid)
        .collection(dayZero)
        .get(const GetOptions(source: Source.cache));
    QuerySnapshot qsOne = await _userCollection
        .doc(uid)
        .collection(dayOne)
        .get(const GetOptions(source: Source.cache));
    QuerySnapshot qsTwo = await _userCollection
        .doc(uid)
        .collection(dayTwo)
        .get(const GetOptions(source: Source.cache));

    foods.addAll(qsZero.docs.map(_parseFoodFromDoc));
    foods.addAll(qsOne.docs.map(_parseFoodFromDoc));
    foods.addAll(qsTwo.docs.map(_parseFoodFromDoc));

    return foods;
  }

  Future<void> writeFood(DateTime date, Food food) async {
    await _userCollection.doc(uid).collection(_df.format(date)).doc().set({
      'name': food.name.toUpperCase(),
      'consumed_amount': food.consumedAmount,
      'consumed_uom': food.consumedUom,
      'nutritional_facts': food.nutrition.toJson(),
      'meal': food.meal.name
    });
  }

  Future<void> updateFood(DateTime date, Food food) async {
    await _userCollection
        .doc(uid)
        .collection(_df.format(date))
        .doc(food.uid)
        .update({
      'name': food.name.toUpperCase(),
      'consumed_amount': food.consumedAmount,
      'consumed_uom': food.consumedUom,
      'nutritional_facts': food.nutrition.toJson(),
      'meal': food.meal.name
    });
  }

  Future<void> deleteFood(DateTime date, Food food) async {
    await _userCollection
        .doc(uid)
        .collection(_df.format(date))
        .doc(food.uid)
        .delete();
  }

  Future<void> updateUserDetails(DateTime? dob, double? weight, String? sex,
      double? height, double? calorieLimit) async {
    await _userCollection.doc(uid).set({
      'dob': dob == null ? null : _df.format(dob),
      'sex': sex,
      'weight': weight,
      'height': height,
      'calorie_limit': calorieLimit,
    }, SetOptions(merge: true));
  }
}
