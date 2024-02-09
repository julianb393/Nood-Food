import 'dart:convert';

import 'package:http/http.dart' as http;

const openFoodFactsEndpoint = 'https://world.openfoodfacts.net/api/v2/product';

Future<Map<String, String>> lookupBarcodeInOpenFoodFacts(String barcode) async {
  final response = await http.get(Uri.parse('$openFoodFactsEndpoint/$barcode'),
      headers: {'fields': 'brands,product_name,nutriments'});

  if (response.statusCode == 200) {
    Map<String, dynamic> respJson = jsonDecode(response.body)['product'];
    return {
      'name': respJson['brands'] + ' - ' + respJson['product_name'],
      'protein':
          (respJson['nutriments']['proteins'] as double).toStringAsFixed(2),
      'carbs': (respJson['nutriments']['carbohydrates'] as double)
          .toStringAsFixed(2),
      'fat': (respJson['nutriments']['fat'] as double).toStringAsFixed(2),
      // usually 100g
      'amount': (respJson['nutrition_data_per'] as String).split('g')[0]
    };
  } else {
    throw Exception('Failed to load food data');
  }
}
