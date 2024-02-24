import 'package:flutter/material.dart';
import 'package:nood_food/common/card_button.dart';
import 'package:nood_food/common/form_decoration.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<String> timezones = ['Eastern Standard Time (EST)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                children: [
                  DropdownButtonFormField(
                      decoration:
                          formDecoration.copyWith(labelText: 'Timezone'),
                      items: timezones.map((e) {
                        return DropdownMenuItem(child: Text(e));
                      }).toList(),
                      onChanged: (val) {})
                ],
              ),
            ),
            CardButton(
              color: Colors.red,
              icon: Icons.delete_forever,
              title: 'Delete Account',
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
