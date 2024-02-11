class NutritionalFacts {
  double amount;
  double protein;
  double carbs;
  double fat;
  NutritionalFacts({
    required this.amount,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, double> toJson() {
    return {'amount': amount, 'protein': protein, 'carbs': carbs, 'fat': fat};
  }
}
