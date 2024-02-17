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

  NutritionalFacts clone() {
    return NutritionalFacts(
        amount: amount, protein: protein, carbs: carbs, fat: fat);
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionalFacts &&
        amount == other.amount &&
        protein == other.protein &&
        carbs == other.carbs &&
        fat == other.fat;
  }

  @override
  int get hashCode => Object.hash(amount, protein, carbs, fat);
}
