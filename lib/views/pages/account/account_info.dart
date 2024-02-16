import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/form_decoration.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/util/string_extension.dart';

class AccountInfo extends StatefulWidget {
  final Function? rebuildParentFunc;
  final NFUser? user;
  const AccountInfo({super.key, this.rebuildParentFunc, this.user});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final DateFormat _df = DateFormat('yyyy-MM-dd');
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
  double? _calorieLimit;

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
    if (!_fillInitialData) return;
    _displayName = widget.user?.displayName ?? '';
    _dob = DateTime.tryParse(widget.user!.dob ?? '');
    _dobController.text = _dob != null ? _df.format(_dob!) : '';
    _sex = widget.user?.sex;
    _weight = widget.user?.weight;
    _height = widget.user?.height;
    _calorieLimit = widget.user?.calorieLimit;
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
                    initialValue: widget.user?.displayName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
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
                          value: _sex,
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
                          initialValue:
                              _weight == null ? '' : _weight.toString(),
                          validator: _numValidator,
                          onChanged: (val) => setState(() {
                            _weight = val.isEmpty ? null : double.parse(val);
                          }),
                          keyboardType: TextInputType.number,
                          decoration: formDecoration.copyWith(
                            labelText: 'Weight (lbs)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          initialValue:
                              _height == null ? '' : _height.toString(),
                          validator: _numValidator,
                          onChanged: (val) => setState(() {
                            _height = val.isEmpty ? null : double.parse(val);
                          }),
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
                          initialValue: _calorieLimit == null
                              ? ''
                              : _calorieLimit.toString(),
                          validator: _numValidator,
                          onChanged: (val) {
                            setState(() {
                              _calorieLimit =
                                  val.isEmpty ? null : double.parse(val);
                            });
                          },
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

                    // widget was built after registration... we can skip check.\
                    bool noChanges = false;
                    if (widget.user != null) {
                      noChanges = true;
                      noChanges &= widget.user!.displayName == _displayName;
                      noChanges &= widget.user?.dob ==
                          (_dob != null ? _df.format(_dob!) : '');
                      noChanges &= widget.user?.sex == _sex;
                      noChanges &= widget.user?.weight == _weight;
                      noChanges &= widget.user?.height == _height;
                      noChanges &= widget.user?.calorieLimit == _calorieLimit;
                    }

                    // Don't waste a write request if no changes happened.
                    if (!noChanges) {
                      await _authService.updateAccountInfo(_displayName, _dob,
                          _sex, _weight, _height, _calorieLimit);
                    }
                    setState(() => _isLoading = false);

                    // In the case of a new user, we directly built this widget
                    // on the main widget tree. So this function should rebuild
                    // the parent and tell it that this user is no longer new.
                    if (widget.rebuildParentFunc != null) {
                      widget.rebuildParentFunc!();
                      return;
                    }
                    // Otherwise, it was navigated to and we can just pop it.
                    else if (mounted) {
                      Navigator.pop(context);
                    }
                  },
            child: _isLoading
                ? const Loader()
                : Text(_fillInitialData ? 'Save Changes' : 'Continue'),
          )),
    );
  }
}
