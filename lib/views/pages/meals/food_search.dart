import 'package:flutter/material.dart';
import 'package:nood_food/common/form_utils.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/meal_type.dart';

class FoodSearch extends StatefulWidget {
  const FoodSearch({super.key});

  @override
  State<FoodSearch> createState() => _FoodSearchState();
}

class _FoodSearchState extends State<FoodSearch> {
  late Future<List<Food>> _foods;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _foods = DBService(uid: AuthService().userUid).getLastTwoDaysOfFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                child: TextFormField(
                  decoration: formDecoration.copyWith(
                      prefixIcon: const Icon(Icons.search),
                      label: const Text('Search')),
                  onChanged: (val) => setState(() => _search = val),
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
          Expanded(
              child: FutureBuilder(
                  future: _foods,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Loader();

                    List<Food> loadedFoods = snapshot.data!
                        .where((element) =>
                            element.name.contains(_search.toUpperCase()))
                        .toList();

                    return ListView.builder(
                        itemCount: loadedFoods.length,
                        itemBuilder: (BuildContext builder, int i) {
                          Food food = loadedFoods[i];
                          return ListTile(
                            leading: Icon(food.meal.getIcon()),
                            title: Text(food.name),
                            trailing: Text(
                              '${food.consumedAmount} ${food.consumedUom}',
                            ),
                            subtitle: Text(
                              'Consumed calories: ${computeTotalCaloriesFromFood(food)} kcal',
                            ),
                            onTap: () {
                              // send the selected food to food editor.
                              Navigator.pop(context, food);
                            },
                          );
                        });
                  })),
        ],
      ),
    );
  }
}
