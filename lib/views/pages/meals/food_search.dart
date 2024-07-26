import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/form_utils.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/models/search_food.dart';
import 'package:nood_food/services/open_food_facts_service.dart';
import 'package:nood_food/util/macronutrient.dart';

class FoodSearch extends StatefulWidget {
  const FoodSearch({super.key});

  @override
  State<FoodSearch> createState() => _FoodSearchState();
}

class _FoodSearchState extends State<FoodSearch> {
  bool _isLoading = false;
  Timer? stoppedTypingTimer;
  final List<SearchFood> _loadedSearchedFoods = [];
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  String _searchWord = '';
  bool searchStarted = false;

  final Duration _debouceDuration = const Duration(milliseconds: 1000);

  void _searchFoods() async {
    if (_searchWord.isEmpty) {
      setState(() {
        _loadedSearchedFoods.clear();
        searchStarted = false;
      });
      return;
    }
    List<SearchFood> searchResults =
        await searchFoods(_searchWord, _page).then((results) {
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
                imgUrl: res['image_url']),
          )
          .toList();
    });
    setState(() {
      _loadedSearchedFoods.addAll(searchResults);
      searchStarted = true;
    });
  }

  void _loadMoreData() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 200) {
      setState(() {
        _page += 1;
        _isLoading = true;
      });
      _searchFoods();
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreData);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
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
                  onChanged: (val) {
                    setState(() => _isLoading = true);
                    if (_debounce?.isActive ?? false) {
                      _debounce?.cancel();
                    }
                    _searchWord = val;
                    _page = 1;
                    _debounce = Timer(_debouceDuration, () {
                      _searchFoods();
                      setState(() => _isLoading = false);
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
                  child: searchStarted && _loadedSearchedFoods.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No results found.'),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _loadedSearchedFoods.length,
                          itemBuilder: (BuildContext builder, int i) {
                            SearchFood food = _loadedSearchedFoods[i];
                            return ListTile(
                              leading: SizedBox(
                                height: 80,
                                width: 80,
                                child: CachedNetworkImage(
                                  errorWidget: ((context, url, error) =>
                                      const Icon(Icons.fastfood_outlined)),
                                  progressIndicatorBuilder:
                                      (context, url, progress) =>
                                          const Loader(),
                                  imageUrl: food.imgUrl!,
                                ),
                              ),
                              title: Text(food.name),
                              subtitle: Text(
                                  '${computeTotalCalories(double.parse(food.protein), double.parse(food.carbs), double.parse(food.fat))}kcal for ${food.amount} ${food.amountUnit}'),
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
