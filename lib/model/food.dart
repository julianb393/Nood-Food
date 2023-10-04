class Food {
  String brand;
  String name;
  Nutrition nutrition;

  Food({required this.brand, required this.name, required this.nutrition});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
        brand: json['product']['brands'],
        name: json['product']['product_name'],
        nutrition: Nutrition.fromJson(json['product']['nutriments']));
  }
}

class Nutrition {
  NutritionItem carbs;
  NutritionItem energy;
  NutritionItem fat;
  NutritionItem proteins;
  NutritionItem salt;
  NutritionItem saturatedFat;
  NutritionItem sodium;
  NutritionItem sugars;

  Nutrition(
      {required this.carbs,
      required this.energy,
      required this.fat,
      required this.proteins,
      required this.salt,
      required this.saturatedFat,
      required this.sodium,
      required this.sugars});

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
        carbs: NutritionItem(
            value: json['carbohydrates'], unit: json['carbohydrates_unit']),
        energy: NutritionItem(value: json['energy'], unit: json['energy_unit']),
        fat: NutritionItem(value: json['fat'], unit: json['fat_unit']),
        proteins:
            NutritionItem(value: json['proteins'], unit: json['proteins_unit']),
        salt: NutritionItem(value: json['salt'], unit: json['salt_unit']),
        saturatedFat: NutritionItem(
            value: json['saturated-fat'], unit: json['saturated-fat_unit']),
        sodium: NutritionItem(value: json['sodium'], unit: json['sodium_unit']),
        sugars:
            NutritionItem(value: json['sugars'], unit: json['sugars_unit']));
  }
}

class NutritionItem {
  double value;
  String unit;
  NutritionItem({required this.value, required this.unit});
}
