import 'package:flutter/material.dart';
import 'package:nood_food/common/form_decoration.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/util/string_extension.dart';
import 'package:nood_food/util/style.dart';

class FoodEditor extends StatefulWidget {
  final MealType mealType;
  const FoodEditor({super.key, required this.mealType});

  @override
  State<FoodEditor> createState() => _FoodEditorState();
}

class _FoodEditorState extends State<FoodEditor> {
  final _dbService = DBService(uid: AuthService().getCurrentUserUid());
  final _formKey = GlobalKey<FormState>();

  String _name = '';

  // Nutritional facts fields
  double _amount = 0.0;
  double _protein = 0.0;
  double _carbs = 0.0;
  double _fat = 0.0;

  // Consumption amount
  double _consumed = 0.0;

  // Consumed summary fields
  double _proteinConsumed = 0.0;
  double _carbsConsumed = 0.0;
  double _fatConsumed = 0.0;

  void _updateSummary() {
    _proteinConsumed = _protein == 0
        ? 0.0
        : double.parse((_amount / _protein * _consumed).toStringAsFixed(2));

    _carbsConsumed = _carbs == 0
        ? 0.0
        : double.parse((_amount / _carbs * _consumed).toStringAsFixed(2));

    _fatConsumed = _fat == 0
        ? 0.0
        : double.parse((_amount / _fat * _consumed).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: StyledText.titleLarge('Food Editor'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              validator: (value) {
                return value != null && value.isNotEmpty
                    ? null
                    : 'Please enter a name.';
              },
              onChanged: (val) => setState(() => _name = val),
              decoration: formDecoration.copyWith(labelText: 'Name'),
            ),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Serving Nutritional Facts'),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    validator: (value) {
                      return value != null &&
                              value.isNotEmpty &&
                              value.isNumeric()
                          ? null
                          : 'Please enter an amount.';
                    },
                    onChanged: (val) => setState(() {
                      _amount = val.isEmpty ? 0.0 : double.parse(val);
                      _updateSummary();
                    }),
                    keyboardType: TextInputType.number,
                    decoration:
                        formDecoration.copyWith(labelText: 'Amount (g)'),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextFormField(
                    validator: (value) {
                      return value != null &&
                              value.isNotEmpty &&
                              value.isNumeric()
                          ? null
                          : 'Invalid number.';
                    },
                    onChanged: (val) => setState(() {
                      _protein = val.isEmpty ? 0.0 : double.parse(val);
                      _proteinConsumed = _protein == 0
                          ? 0.0
                          : double.parse((_amount / _protein * _consumed)
                              .toStringAsFixed(2));
                    }),
                    keyboardType: TextInputType.number,
                    decoration:
                        formDecoration.copyWith(labelText: 'Protein (g)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    validator: (value) {
                      return value != null &&
                              value.isNotEmpty &&
                              value.isNumeric()
                          ? null
                          : 'Please enter a carbs amount.';
                    },
                    onChanged: (val) => setState(() {
                      _carbs = val.isEmpty ? 0.0 : double.parse(val);
                      _carbsConsumed = _protein == 0
                          ? 0.0
                          : double.parse((_amount / _carbs * _consumed)
                              .toStringAsFixed(2));
                    }),
                    keyboardType: TextInputType.number,
                    decoration: formDecoration.copyWith(labelText: 'Carbs (g)'),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextFormField(
                    validator: (value) {
                      return value != null &&
                              value.isNotEmpty &&
                              value.isNumeric()
                          ? null
                          : 'Please enter a fat amount.';
                    },
                    onChanged: (val) => setState(() {
                      _fat = val.isEmpty ? 0.0 : double.parse(val);
                      _fatConsumed = _fat == 0
                          ? 0.0
                          : double.parse(
                              (_amount / _fat * _consumed).toStringAsFixed(2));
                    }),
                    keyboardType: TextInputType.number,
                    decoration: formDecoration.copyWith(labelText: 'Fat (g)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Scan barcode to fill'),
            ),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Consumption Summary'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            // const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: TextFormField(
                    validator: (value) {
                      return value != null &&
                              value.isNotEmpty &&
                              value.isNumeric()
                          ? null
                          : 'Please enter the amount you consumed.';
                    },
                    onChanged: (val) => setState(() {
                      _consumed = val.isEmpty ? 0.0 : double.parse(val);
                      _updateSummary();
                    }),
                    keyboardType: TextInputType.number,
                    decoration: formDecoration.copyWith(labelText: 'Consumed'),
                  ),
                ),
                Flexible(
                  child: DropdownButtonFormField(
                    decoration: formDecoration,
                    value: 'g',
                    items: ['g']
                        .map((uom) =>
                            DropdownMenuItem(value: uom, child: Text(uom)))
                        .toList(),
                    onChanged: (item) {},
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                  'Protein: $_proteinConsumed\nCarbs: $_carbsConsumed\nFat: $_fatConsumed'),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              print('The form is invalid.');
              return;
            }
            Food newFood = Food(_name, _consumed, _proteinConsumed,
                _carbsConsumed, _fatConsumed, widget.mealType);
            _dbService.writeFood(DateTime.now(), newFood);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
