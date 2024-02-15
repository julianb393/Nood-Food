import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/form_decoration.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/util/string_extension.dart';

class AccountInfo extends StatefulWidget {
  final Function? rebuildParentFunc;
  const AccountInfo({super.key, this.rebuildParentFunc});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final DateFormat _df = DateFormat(DateFormat.YEAR_NUM_MONTH_DAY);
  final TextEditingController _dobController = TextEditingController();
  late final bool _fillInitialData;
  int? _age;
  bool _isLoading = false;

  // Fields to be used for user profile.
  late String _displayName;
  DateTime? _dob;
  String? _sex;
  double? _weight;
  double? _height;

  String? _numValidator(String? value) {
    // field is optional, but if a value was actually inputted, check it.
    if (value != null && value.isNotEmpty && !value.isNumeric()) {
      return 'please Input a number';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // This means the page was opened via Settings.
    _fillInitialData = widget.rebuildParentFunc == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
        automaticallyImplyLeading: _fillInitialData,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TODO: allow uploading image
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 45)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _authService.currentUser?.displayName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                    },
                    onChanged: (val) => setState(() => _displayName = val),
                    decoration: formDecoration.copyWith(
                      labelText: 'Display Name *',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dobController,
                          decoration: formDecoration.copyWith(
                            labelText: 'Date of Birth',
                          ),
                          onTap: () async {
                            // Below line stops keyboard from appearing
                            FocusScope.of(context).requestFocus(FocusNode());

                            // Show Date Picker Here
                            DateTime? picked = await showDatePicker(
                                context: context,
                                initialDatePickerMode: DatePickerMode.year,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1970),
                                lastDate: DateTime.now());
                            if (picked != null) {
                              setState(
                                () {
                                  _dob = picked;
                                  _age = (DateTime.now()
                                          .difference(_dob!)
                                          .inDays ~/
                                      365);
                                  _dobController.text = _df.format(_dob!);
                                },
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(child: Text('Age: ${_age ?? ''}')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: formDecoration.copyWith(
                            labelText: 'Sex',
                          ),
                          items: ['Male', 'Female', 'Other']
                              .map((sex) => DropdownMenuItem(
                                  value: sex, child: Text(sex)))
                              .toList(),
                          onChanged: (val) => setState(() => _sex = val),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          validator: _numValidator,
                          onChanged: (val) =>
                              setState(() => _weight = double.parse(val)),
                          keyboardType: TextInputType.number,
                          decoration: formDecoration.copyWith(
                            labelText: 'Weight (lbs)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          validator: _numValidator,
                          onChanged: (val) =>
                              setState(() => _height = double.parse(val)),
                          keyboardType: TextInputType.number,
                          decoration: formDecoration.copyWith(
                            labelText: 'Height (cm)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: formDecoration.copyWith(
                              labelText: 'Daily Calorie Limit (kcal)'),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (builder) {
                                return AlertDialog(
                                  title: const Text('Daily Calorie Limit'),
                                  icon: const Icon(Icons.question_mark),
                                  content:
                                      const Text('This is under development!'),
                                  actions: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    )
                                  ],
                                );
                              });
                        },
                        icon: const Icon(Icons.question_mark),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
          width: double.infinity,
          child: FloatingActionButton(
            onPressed: _isLoading
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;

                    setState(() => _isLoading = true);
                    // TOOD: error management
                    await _authService.updateAccountInfo(
                        _displayName, _dob, _sex, _weight, _height);
                    setState(() => _isLoading = false);

                    // In the case of a new user, we directly built this widget
                    // on the main widget tree. So this function should rebuild
                    // the parent and tell it that this user is no longer new.
                    if (widget.rebuildParentFunc != null) {
                      widget.rebuildParentFunc!();
                      return;
                    }
                    // Otherwise, it was navigated to and we can just pop it.
                    else {
                      if (mounted) Navigator.pop(context);
                    }
                  },
            child: _isLoading
                ? const Loader()
                : Text(_fillInitialData ? 'Save Changes' : 'Continue'),
          )),
    );
  }
}
