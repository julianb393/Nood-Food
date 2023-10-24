import 'package:flutter/material.dart';
import 'package:nood_food/util/units.dart';

const textInputDecoration = InputDecoration(
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.0)),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 2.0)),
  floatingLabelStyle: TextStyle(color: Colors.grey),
);

class FoodNutritionFormField extends StatelessWidget {
  String name;
  FoodNutritionFormField({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: textInputDecoration.copyWith(
                labelText: name,
              ),
              validator: (val) => val!.isEmpty ? 'Enter an email' : null,
              onChanged: (val) {}),
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField(
            decoration: textInputDecoration,
            onChanged: (val) {},
            items: availableUnits.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(
                  unit.symbol,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
