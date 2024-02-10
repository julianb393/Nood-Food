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

  Food _parseFoodFromDoc(QueryDocumentSnapshot doc) {
    return Food(
      name: doc.get('name'),
      quantity: doc.get('quantity'),
      protein: doc.get('protein'),
      carbs: doc.get('carbs'),
      fat: doc.get('fat'),
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
      'protein': food.protein,
      'carbs': food.carbs,
      'fat': food.fat,
      'quantity': food.quantity,
      'meal': food.meal.name
    });
  }
}
