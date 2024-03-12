import 'dart:convert';

import 'package:http/http.dart' as http;

const openFoodFactsURI = 'https://world.openfoodfacts.net/api/v2';
const productEndpoint = 'product';
const searchEndpoint = 'search';

Future<Map<String, String>> lookupBarcodeInOpenFoodFacts(String barcode) async {
  final response = await http.get(
      Uri.parse('$openFoodFactsURI/$productEndpoint/$barcode'),
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

Future<List<Map<String, String>>> searchFoods(String searchWord) async {
  final response =
      await http.get(Uri.parse('$openFoodFactsURI/$searchEndpoint'), headers: {
    'categories_tags': searchWord,
    'fields': 'brands,product_name,nutriments,image_url'
  });

  if (response.statusCode == 200) {
    List<Map<String, dynamic>> products = jsonDecode(response.body)['products'];
    return products.map((product) => _parseSearchResults(product)).toList();
  } else {
    throw Exception('Failed to load food data');
  }
}

Map<String, String> _parseSearchResults(Map<String, dynamic> product) {
  return {
    'name': product['brands'] + ' - ' + product['product_name'],
    'protein': (product['nutriments']['proteins'] as double).toStringAsFixed(2),
    'carbs':
        (product['nutriments']['carbohydrates'] as double).toStringAsFixed(2),
    'fat': (product['nutriments']['fat'] as double).toStringAsFixed(2),
    // usually 100g
    'amount': (product['nutrition_data_per'] as String).split('g')[0],
    'image_url': product['image_url']
  };
}
