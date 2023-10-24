class Food {
  String brand;
  String name;
  NutritionItem quantity;
  Nutrition nutrition;

  Food(
      {required this.brand,
      required this.name,
      required this.quantity,
      required this.nutrition});

  factory Food.fromJson(Map<String, dynamic> json) {
    List<String> quantityAndUnit =
        (json['product']['nutrition_data_per'] as String).split(r'\d*');
    return Food(
        brand: json['product']['brands'],
        name: json['product']['product_name'],
        quantity: NutritionItem(
          value: quantityAndUnit[0],
          unit: quantityAndUnit[1],
        ),
        nutrition: Nutrition.fromJson(json['product']['nutriments']));
  }
}

class Nutrition {
  NutritionItem? carbs;
  NutritionItem? energy;
  NutritionItem? fat;
  NutritionItem? proteins;
  NutritionItem? salt;
  NutritionItem? saturatedFat;
  NutritionItem? sodium;
  NutritionItem? sugars;

  Nutrition(
      {this.carbs,
      this.energy,
      this.fat,
      this.proteins,
      this.salt,
      this.saturatedFat,
      this.sodium,
      this.sugars});

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
        carbs: json.containsKey('carbohydrates')
            ? NutritionItem(
                value: json['carbohydrates']!.toString(),
                unit: json['carbohydrates_unit'])
            : null,
        energy: json.containsKey('energy')
            ? NutritionItem(
                value: json['energy']!.toString(),
                unit: json['energy_unit'],
              )
            : null,
        fat: json.containsKey('fat')
            ? NutritionItem(
                value: json['fat']!.toString(),
                unit: json['fat_unit'],
              )
            : null,
        proteins: json.containsKey('proteins')
            ? NutritionItem(
                value: json['proteins']!.toString(),
                unit: json['proteins_unit'],
              )
            : null,
        salt: json.containsKey('salt')
            ? NutritionItem(
                value: json['salt']!.toString(),
                unit: json['salt_unit'],
              )
            : null,
        saturatedFat: json.containsKey('saturated-fat')
            ? NutritionItem(
                value: json['saturated-fat']!.toString(),
                unit: json['saturated-fat_unit'])
            : null,
        sodium: json.containsKey('sodium')
            ? NutritionItem(
                value: json['sodium']!.toString(),
                unit: json['sodium_unit'],
              )
            : null,
        sugars: json.containsKey('sugars')
            ? NutritionItem(
                value: json['sugars']!.toString(),
                unit: json['sugars_unit'],
              )
            : null);
  }
}

class NutritionItem {
  String value;
  String unit;
  NutritionItem({required this.value, required this.unit});

  @override
  String toString() {
    return '$value $unit';
  }
}
