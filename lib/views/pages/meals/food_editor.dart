import 'package:flutter/material.dart';
import 'package:nood_food/common/form_decoration.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:nood_food/util/barcode_scan.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/util/string_extension.dart';
import 'package:nood_food/util/style.dart';

class FoodEditor extends StatefulWidget {
  final MealType mealType;
  final DateTime day;
  const FoodEditor({super.key, required this.mealType, required this.day});

  @override
  State<FoodEditor> createState() => _FoodEditorState();
}

class _FoodEditorState extends State<FoodEditor> {
  final DBService _dbService = DBService(uid: AuthService().userUid);
  final _formKey = GlobalKey<FormState>();

  // Form controllers for the scanner
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

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
  double _caloriesConsumed = 0.0;

  void _updateSummary() {
    _proteinConsumed = _protein == 0
        ? 0.0
        : double.parse((_protein / _amount * _consumed).toStringAsFixed(2));

    _carbsConsumed = _carbs == 0
        ? 0.0
        : double.parse((_carbs / _amount * _consumed).toStringAsFixed(2));

    _fatConsumed = _fat == 0
        ? 0.0
        : double.parse((_fat / _amount * _consumed).toStringAsFixed(2));

    _caloriesConsumed =
        computeTotalCalories(_proteinConsumed, _carbsConsumed, _fatConsumed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(5),
      title: StyledText.titleLarge('Food Editor'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
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
                      controller: _amountController,
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
                      controller: _proteinController,
                      validator: (value) {
                        return value != null &&
                                value.isNotEmpty &&
                                value.isNumeric()
                            ? null
                            : 'Invalid number.';
                      },
                      onChanged: (val) => setState(() {
                        _protein = val.isEmpty ? 0.0 : double.parse(val);
                        _updateSummary();
                      }),
                      keyboardType: TextInputType.number,
                      decoration:
                          formDecoration.copyWith(labelText: 'Protein (g)'),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _carbsController,
                      validator: (value) {
                        return value != null &&
                                value.isNotEmpty &&
                                value.isNumeric()
                            ? null
                            : 'Invalid number.';
                      },
                      onChanged: (val) => setState(() {
                        _carbs = val.isEmpty ? 0.0 : double.parse(val);
                        _updateSummary();
                      }),
                      keyboardType: TextInputType.number,
                      decoration:
                          formDecoration.copyWith(labelText: 'Carbs (g)'),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      validator: (value) {
                        return value != null &&
                                value.isNotEmpty &&
                                value.isNumeric()
                            ? null
                            : 'Invalid number.';
                      },
                      onChanged: (val) => setState(() {
                        _fat = val.isEmpty ? 0.0 : double.parse(val);
                        _updateSummary();
                      }),
                      keyboardType: TextInputType.number,
                      decoration: formDecoration.copyWith(labelText: 'Fat (g)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic>? scannedData = await scanBarcode();
                  if (scannedData == null || scannedData.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text('Unable to recognize that barcode.'),
                        ),
                      );
                    } else {
                      print('Unable to recognize that barcode.');
                    }
                    return;
                  }
                  setState(() {
                    _nameController.text = scannedData['name'];
                    _name = _nameController.text;
                    _amountController.text = scannedData['amount'];
                    _amount = double.parse(_amountController.text);
                    _proteinController.text = scannedData['protein'];
                    _protein = double.parse(_proteinController.text);
                    _carbsController.text = scannedData['carbs'];
                    _carbs = double.parse(_carbsController.text);
                    _fatController.text = scannedData['fat'];
                    _fat = double.parse(_fatController.text);
                    _updateSummary();
                  });
                },
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
                            : 'Invalid numbers.';
                      },
                      onChanged: (val) => setState(() {
                        _consumed = val.isEmpty ? 0.0 : double.parse(val);
                        _updateSummary();
                      }),
                      keyboardType: TextInputType.number,
                      decoration:
                          formDecoration.copyWith(labelText: 'Consumed'),
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
                    'Protein: $_proteinConsumed g\nCarbs: $_carbsConsumed g\nFat: $_fatConsumed g\nCalories: $_caloriesConsumed kcal'),
              ),
            ],
          ),
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
            Food newFood = Food(
              name: _name,
              quantity: _consumed,
              protein: _proteinConsumed,
              carbs: _carbsConsumed,
              fat: _fatConsumed,
              meal: widget.mealType,
            );
            _dbService.writeFood(widget.day, newFood);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
