import 'package:flutter/material.dart';

enum MealType { breakfast, lunch, dinner, snacks }

extension MealTypeExtension on MealType {
  IconData? getIcon() {
    switch (this) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snacks:
        return Icons.dining_rounded;
      default:
        return null;
    }
  }

  static MealType parseString(String str) {
    return MealType.values.byName(str);
  }
}
