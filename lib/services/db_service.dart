import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/util/meal_type.dart';

class DBService {
  final String? uid;
  DBService({this.uid});

  final DateFormat _df = DateFormat('yyyy-MM-dd');

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // Food _parseFoodFromSnapshot(QuerySnapshot snapshot, MealType meal) {
  //   return;
  // }

  // Future<List<Food>> getFoodsFromDate(DateTime date, MealType meal) async {
  //   return _userCollection
  //       .doc(uid)
  //       .collection(_df.format(date))
  //       .snapshots()
  //       .map((snapshot) => _parseFoodFromSnapshot(snapshot, meal)).toList();
  // }

  Future<void> writeFood(DateTime date, Food food) async {
    await _userCollection
        .doc(uid)
        .collection(_df.format(date))
        .doc(food.name.toUpperCase())
        .set({
      'protein': food.protein,
      'carbs': food.carbs,
      'fat': food.fat,
      'mealToQuantity': {food.meal.name.toString(): food.quantity}
    });
  }
}
