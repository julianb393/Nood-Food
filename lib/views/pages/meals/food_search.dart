import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nood_food/common/form_utils.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/models/search_food.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:nood_food/services/open_food_facts_service.dart';

class FoodSearch extends StatefulWidget {
  const FoodSearch({super.key});

  @override
  State<FoodSearch> createState() => _FoodSearchState();
}

class _FoodSearchState extends State<FoodSearch> {
  bool _isLoading = false;
  Timer? stoppedTypingTimer;
  List<SearchFood> _loadedSearchedFoods = [];
  Timer? _debounce;

// change debouce duration accordingly
  Duration _debouceDuration = const Duration(milliseconds: 500);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_loadedSearchedFoods.length);
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
                  onChanged: (val) {
                    setState((() => _isLoading = true));
                    if (_debounce?.isActive ?? false) {
                      _debounce?.cancel();
                    }
                    _debounce = Timer(_debouceDuration, () async {
                      List<SearchFood> searchResults =
                          await searchFoods(val).then((results) {
                        return results
                            .map(
                              (res) => SearchFood(
                                  name: res['name']!,
                                  amount: res['amount']!,
                                  amountUnit: res['amount_unit']!,
                                  protein: res['protein']!,
                                  proteinUnit: res['protein_unit']!,
                                  fat: res['fat']!,
                                  fatUnit: res['fat_unit']!,
                                  carbs: res['carbs']!,
                                  carbsUnit: res['carbs_unit']!,
                                  imgUrl: res['img_url']),
                            )
                            .toList();
                      });
                      setState(() {
                        _loadedSearchedFoods = searchResults;
                        _isLoading = false;
                      });
                    });
                  },
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
          _isLoading
              ? const Loader()
              : Expanded(
                  child: ListView.builder(
                      itemCount: _loadedSearchedFoods.length,
                      itemBuilder: (BuildContext builder, int i) {
                        SearchFood food = _loadedSearchedFoods[i];
                        return ListTile(
                          // leading: Icon(food.meal.getIcon()),
                          title: Text(food.name),
                          subtitle: Text(
                            '${food.protein}${food.proteinUnit}|${food.fat}${food.fatUnit}|${food.carbs}${food.carbsUnit}',
                          ),
                          onTap: () {
                            // send the selected food to food editor.
                            Navigator.pop(context, food);
                          },
                        );
                      }))
        ],
      ),
    );
  }
}
