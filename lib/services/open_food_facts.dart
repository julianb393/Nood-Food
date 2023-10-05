import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nood_food/model/food.dart';

const openFoodFactsEndpoint = 'https://world.openfoodfacts.net/api/v2/product';

Future<Food> getFood(String barcode) async {
  final response = await http.get(Uri.parse('$openFoodFactsEndpoint/$barcode'),
      headers: {'fields': 'brands,product_name,nutriments'});

  if (response.statusCode == 200) {
    return Food.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load food data');
  }
}
