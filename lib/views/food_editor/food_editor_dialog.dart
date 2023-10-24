import 'package:flutter/material.dart';
import 'package:nood_food/model/food.dart';
import 'package:nood_food/views/food_editor/food_nutrition_form_field.dart';

const textInputDecoration = InputDecoration(
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.0)),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 2.0)),
  floatingLabelStyle: TextStyle(color: Colors.grey),
);

class FoodEditorDialog extends StatefulWidget {
  final Food food;

  const FoodEditorDialog({Key? key, required this.food}) : super(key: key);

  @override
  State<FoodEditorDialog> createState() => _FoodEditorDialogState();
}

class _FoodEditorDialogState extends State<FoodEditorDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        insetPadding: const EdgeInsets.all(10),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.food.name),
            ElevatedButton(
              child: const Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // delete from db
                Navigator.pop(context);
              },
            )
          ],
        ),
        children: [
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FoodNutritionFormField(name: 'Quantity'),
                  const SizedBox(height: 2),
                  FoodNutritionFormField(name: 'Carbs'),
                  const SizedBox(height: 2),
                  FoodNutritionFormField(name: 'Fat'),
                  const SizedBox(height: 2),
                  FoodNutritionFormField(name: 'Salt'),
                  const SizedBox(height: 2),
                  FoodNutritionFormField(name: 'Sugars'),
                  const SizedBox(height: 2),
                  FoodNutritionFormField(name: 'Saturated Fat'),
                  const SizedBox(height: 2),
                  FoodNutritionFormField(name: 'Protein'),
                  const SizedBox(height: 2),
                  FoodNutritionFormField(name: 'Sodium'),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                      onPressed: () {
                        // Save changes to db
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.grey,
                        )),
                  ]),

                  // DropdownButtonFormField(items: [], onChanged: (value) {})
                ],
              ),
            ),
          )
        ]);
  }
}
