import 'package:flutter/material.dart';
import 'package:nood_food/common/div_text.dart';
import 'package:nood_food/common/form_utils.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/models/nutritional_facts.dart';
import 'package:nood_food/models/search_food.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:nood_food/util/barcode_scan.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/util/string_extension.dart';
import 'package:nood_food/util/unit.dart';
import 'package:nood_food/views/pages/meals/food_search.dart';

class FoodEditor extends StatefulWidget {
  final MealType mealType;
  final DateTime day;
  final Food? food;
  const FoodEditor({
    super.key,
    required this.mealType,
    required this.day,
    this.food,
  });

  @override
  State<FoodEditor> createState() => _FoodEditorState();
}

class _FoodEditorState extends State<FoodEditor> {
  final DBService _dbService = DBService(uid: AuthService().userUid);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers for the scanner
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _consumedAmountController = TextEditingController();

  late Food _newFood;
  late NutritionalFacts _nutrition;
  late bool _isNewEntry;

  @override
  void initState() {
    super.initState();

    if (widget.food == null) {
      _isNewEntry = true;
      _nutrition = NutritionalFacts(
        amount: 0.0,
        protein: 0.0,
        carbs: 0.0,
        fat: 0.0,
      );
      _newFood = Food(
          name: '',
          consumedAmount: 0.0,
          consumedUom: Unit.grams,
          nutrition: _nutrition,
          meal: widget.mealType);
    } else {
      _isNewEntry = false;
      _newFood = widget.food!.clone();
      _nutrition = widget.food!.nutrition.clone();
      _nameController.text = _newFood.name;
      _amountController.text = _nutrition.amount.toString();
      _proteinController.text = _nutrition.protein.toString();
      _carbsController.text = _nutrition.carbs.toString();
      _fatController.text = _nutrition.fat.toString();
      _consumedAmountController.text = _newFood.consumedAmount.toString();
      _updateSummary();
    }
  }

  // Consumed summary fields in grams
  double _proteinConsumed = 0.0;
  double _carbsConsumed = 0.0;
  double _fatConsumed = 0.0;
  double _caloriesConsumed = 0.0;

  void _updateSummary() {
    _proteinConsumed = _newFood.computeConsumedProtein();
    _carbsConsumed = _newFood.computeConsumedCarbs();
    _fatConsumed = _newFood.computeConsumedFat();

    _caloriesConsumed =
        computeTotalCalories(_proteinConsumed, _carbsConsumed, _fatConsumed);
  }

  void _showFoodSeach() async {
    SearchFood? selectedFood = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return const FoodSearch();
        });
    if (selectedFood == null) return;
    // fill in the details.
    setState(() {
      _nameController.text = selectedFood.name;
      _newFood.name = selectedFood.name;
      _amountController.text =
          convertStrToGrams(selectedFood.amountUnit, selectedFood.amount);
      _nutrition.amount = double.parse(_amountController.text);
      _proteinController.text =
          convertStrToGrams(selectedFood.proteinUnit, selectedFood.protein);
      _nutrition.protein = double.parse(_proteinController.text);
      _carbsController.text =
          convertStrToGrams(selectedFood.carbsUnit, selectedFood.carbs);
      _nutrition.carbs = double.parse(_carbsController.text);
      _fatController.text =
          convertStrToGrams(selectedFood.fatUnit, selectedFood.fat);
      _nutrition.fat = double.parse(_fatController.text);
      _consumedAmountController.text = '';
      _updateSummary();
    });
  }

  Future<void> _scanBarcodeAndFill() async {
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
      _newFood.name = _nameController.text;
      _amountController.text = scannedData['amount'];
      _nutrition.amount = double.parse(_amountController.text);
      _proteinController.text = scannedData['protein'];
      _nutrition.protein = double.parse(_proteinController.text);
      _carbsController.text = scannedData['carbs'];
      _nutrition.carbs = double.parse(_carbsController.text);
      _fatController.text = scannedData['fat'];
      _nutrition.fat = double.parse(_fatController.text);
      _updateSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Food Editor'),
            _isNewEntry
                ? Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _scanBarcodeAndFill();
                        },
                        icon: const Icon(Icons.barcode_reader),
                      ),
                      IconButton(
                        onPressed: () {
                          _showFoodSeach();
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  )
                : IconButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await _dbService.deleteFood(widget.day, widget.food!);
                      setState(() => _isLoading = false);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
          ],
        ),
      ),
      body: _isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          return value != null && value.isNotEmpty
                              ? null
                              : 'Please enter a name.';
                        },
                        onChanged: (val) => setState(() => _newFood.name = val),
                        decoration: formDecoration.copyWith(labelText: 'Name'),
                      ),
                      const DivText(text: 'Nutritional Facts'),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Expanded(flex: 1, child: SizedBox()),
                          Expanded(
                            flex: 2,
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
                                _nutrition.amount =
                                    val.isEmpty ? 0.0 : double.parse(val);
                                _updateSummary();
                              }),
                              keyboardType: TextInputType.number,
                              decoration: formDecoration.copyWith(
                                  labelText: 'Serving amount (g)'),
                            ),
                          ),
                          const Expanded(flex: 1, child: SizedBox())
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
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
                                _nutrition.protein =
                                    val.isEmpty ? 0.0 : double.parse(val);
                                _updateSummary();
                              }),
                              keyboardType: TextInputType.number,
                              decoration: formDecoration.copyWith(
                                  labelText: 'Protein (g)'),
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
                                _nutrition.carbs =
                                    val.isEmpty ? 0.0 : double.parse(val);
                                _updateSummary();
                              }),
                              keyboardType: TextInputType.number,
                              decoration: formDecoration.copyWith(
                                  labelText: 'Carbs (g)'),
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
                                _nutrition.fat =
                                    val.isEmpty ? 0.0 : double.parse(val);
                                _updateSummary();
                              }),
                              keyboardType: TextInputType.number,
                              decoration:
                                  formDecoration.copyWith(labelText: 'Fat (g)'),
                            ),
                          ),
                        ],
                      ),
                      const DivText(text: 'Consumption Summary'),
                      // const SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 2,
                            child: TextFormField(
                              controller: _consumedAmountController,
                              validator: (value) {
                                return value != null &&
                                        value.isNotEmpty &&
                                        value.isNumeric()
                                    ? null
                                    : 'Invalid numbers.';
                              },
                              onChanged: (val) => setState(() {
                                _newFood.consumedAmount =
                                    val.isEmpty ? 0.0 : double.parse(val);
                                _updateSummary();
                              }),
                              keyboardType: TextInputType.number,
                              decoration: formDecoration.copyWith(
                                  labelText: 'Consumed'),
                            ),
                          ),
                          Flexible(
                            child: DropdownButtonFormField(
                              decoration: formDecoration,
                              value: Unit.grams,
                              items: Unit.values
                                  .map((unit) => DropdownMenuItem(
                                      value: unit, child: Text(unit.symbol)))
                                  .toList(),
                              onChanged: (unit) => setState(() {
                                _newFood.consumedUom = unit as Unit;
                                _updateSummary();
                              }),
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
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        child: FloatingActionButton(
          onPressed: _isLoading
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isLoading = true);
                  if (_isNewEntry) {
                    await _dbService.writeFood(widget.day, _newFood);
                  } else if (widget.food != _newFood) {
                    await _dbService.updateFood(widget.day, _newFood);
                  }
                  setState(() => _isLoading = false);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
          child: Text(_isNewEntry ? 'Save' : 'Save Changes'),
        ),
      ),
    );
  }
}
