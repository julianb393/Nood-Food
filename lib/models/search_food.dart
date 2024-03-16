class SearchFood {
  String name;
  String amount;
  String amountUnit;
  String protein;
  String proteinUnit;
  String fat;
  String fatUnit;
  String carbs;
  String carbsUnit;
  String? imgUrl;
  SearchFood(
      {required this.name,
      required this.amount,
      required this.amountUnit,
      required this.protein,
      required this.proteinUnit,
      required this.fat,
      required this.fatUnit,
      required this.carbs,
      required this.carbsUnit,
      required this.imgUrl});
}
