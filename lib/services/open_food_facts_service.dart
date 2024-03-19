import 'dart:convert';

import 'package:http/http.dart' as http;

const barcodeEndpoint = 'https://world.openfoodfacts.net/api/v2/product';
const searchEndpoint = 'https://world.openfoodfacts.org/cgi/search.pl';

Future<Map<String, String>> lookupBarcodeInOpenFoodFacts(String barcode) async {
  final response = await http.get(Uri.parse('$barcodeEndpoint/$barcode'),
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
  // TODO: query by country
  final response = await http.get(
    Uri.parse(
        '$searchEndpoint?json=1&fields=brands,product_name,nutriments,image_url&search_terms=$searchWord'),
  );

  if (response.statusCode == 200) {
    List<dynamic> products = jsonDecode(response.body)['products'];
    return products
        .map((product) => _parseSearchResults(product as Map<String, dynamic>))
        .where((map) => map.isNotEmpty)
        .take(15)
        .toList();
  } else {
    throw Exception('Failed to load food data');
  }
}

Map<String, String> _parseSearchResults(Map<String, dynamic> product) {
  String? name = product['product_name'];
  if (name != null && product['brands'] != null) {
    name += ' - ${product['brands']}';
  }
  dynamic protein = product['nutriments']['proteins'];
  String? proteinUnit = product['nutriments']['proteins_unit'];
  dynamic carbs = product['nutriments']['carbohydrates'];
  String? carbsUnit = product['nutriments']['carbohydrates_unit'];
  dynamic fat = product['nutriments']['fat'];
  String? fatUnit = product['nutriments']['fat_unit'];
  // String? amount = product['nutrition_data_per'];
  if (name == null ||
      protein == null ||
      proteinUnit == null ||
      carbs == null ||
      carbsUnit == null ||
      fat == null ||
      fatUnit == null) {
    return {};
  }
  print('returning food $name');
  return {
    'name': name,
    'protein':
        (protein.runtimeType == String) ? protein : protein.toStringAsFixed(2),
    'protein_unit': proteinUnit,
    'carbs': (carbs.runtimeType == String) ? carbs : carbs.toStringAsFixed(2),
    'carbs_unit': carbsUnit,
    'fat': (fat.runtimeType == String) ? fat : fat.toStringAsFixed(2),
    'fat_unit': fatUnit,
    // usually 100g
    'amount': '100', // TODO: figure out how to get serving size
    'amount_unit': 'g',
    'image_url': product['image_url'] ?? ''
  };
}
