import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/models/nutritional_facts.dart';
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
      name: doc.get('name'),
      consumedAmount: doc.get('consumed_amount'),
      consumedUom: doc.get('consumed_uom'),
      nutrition: _parseNutritionFromDocMap(doc.get('nutritional_facts')),
      meal: MealTypeExtension.parseString(doc.get('meal')),
    );
  }

  Stream<List<Food>> getFoodsFromDate(DateTime date) {
    return _userCollection
        .doc(uid)
        .collection(_df.format(date))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _parseFoodFromDoc(doc)).toList());
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
    // TODO
    return;
  }

  Future<void> deleteFood(DateTime date, Food food) async {
    // TODO
    return;
  }
}
