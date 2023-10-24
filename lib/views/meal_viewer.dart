import 'package:flutter/material.dart';
import 'package:nood_food/model/food.dart';
import 'package:nood_food/services/barcode_scanner.dart';
import 'package:nood_food/views/food_editor/food_editor_dialog.dart';

class MealViewer extends StatefulWidget {
  final String meal;
  const MealViewer({Key? key, required this.meal}) : super(key: key);

  @override
  _MealViewerState createState() => _MealViewerState();
}

class _MealViewerState extends State<MealViewer> {
  List<Food> foods = [
    Food(
      name: 'popcorn',
      brand: 'Orville',
      quantity: NutritionItem(value: '100', unit: 'g'),
      nutrition: Nutrition(
        carbs: NutritionItem(value: '100', unit: 'g'),
        energy: NutritionItem(value: '100', unit: 'kcal'),
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DataTable(
            showCheckboxColumn: false,
            showBottomBorder: true,
            columnSpacing: 8,
            columns: const [
              DataColumn(label: Text('Food')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Calories')),
              DataColumn(label: Text(''))
            ],
            rows: foods
                .map(
                  (food) => DataRow(
                    onSelectChanged: (bool? selected) {
                      if (!selected!) {
                        return;
                      }

                      showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return FoodEditorDialog(food: food);
                          });
                    },
                    cells: [
                      DataCell(Text('${food.brand} - ${food.name}')),
                      DataCell(Text(food.quantity.toString())),
                      DataCell(Text(food.nutrition.energy.toString())),
                      const DataCell(
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                  onPressed: () async {
                    scanBarcode()
                        .then((value) => setState(() => foods.add(value!)));
                  },
                  icon: Icon(Icons.barcode_reader),
                  label: Text('Scan Barcode')),
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.edit),
                  label: Text('Add Manually')),
            ],
          ),
        ],
      ),
    );
  }
}
