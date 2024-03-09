import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nood_food/common/form_utils.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/util/active_level.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/string_extension.dart';

class AccountInfo extends StatefulWidget {
  final NFUser? user;
  const AccountInfo({super.key, this.user});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final DateFormat _df = DateFormat('yyyy-MM-dd');
  final TextEditingController _dobController = TextEditingController();
  int? _age;
  bool _isLoading = false;

  ImagePicker imgPicker = ImagePicker();

  // Fields to be used for user profile.
  late String _displayName;
  DateTime? _dob;
  String? _sex;
  double? _weight;
  double? _height;
  double? _calorieLimit;
  double? _calorieLimitRecommend;
  final List<bool> _isSelectedLevels =
      ActiveLevel.values.map((e) => false).toList();
  ActiveLevel? _activeLevel;

  File? _selectedImage;

  void _updateCalorieLimitRecommend() {
    setState(() {
      _calorieLimitRecommend = computeRecommendedCalories(
          _sex, _weight, _height, _age, _activeLevel);
    });
  }

  String? _numValidator(String? value) {
    // field is optional, but if a value was actually inputted, check it.
    if (value != null && value.isNotEmpty && !value.isNumeric()) {
      return 'please Input a number';
    }
    return null;
  }

  Widget _showProfilePic() {
    if (_selectedImage == null) {
      // Nothing selected
      String? photoURL = widget.user?.photoURL;
      return photoURL == null
          ? const CircleAvatar(
              radius: 55,
              child: Icon(Icons.person, size: 45),
            )
          : CachedNetworkImage(
              imageUrl: photoURL,
              placeholder: (context, val) => const Loader(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              imageBuilder: (context, imageProvider) {
                return CircleAvatar(
                  radius: 55,
                  backgroundImage: imageProvider,
                );
              },
            );
    }
    return CircleAvatar(
      radius: 55,
      backgroundColor: Colors.transparent,
      backgroundImage: Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
      ).image,
    );
  }

  double getBottomInsets() {
    if (MediaQuery.of(context).viewInsets.bottom >
        MediaQuery.of(context).viewPadding.bottom) {
      return MediaQuery.of(context).viewInsets.bottom -
          MediaQuery.of(context).viewPadding.bottom;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    // This means the page was opened via Settings.
    _displayName = widget.user?.displayName ?? '';
    _dob = DateTime.tryParse(widget.user?.dob ?? '');
    _dobController.text = _dob != null ? _df.format(_dob!) : '';
    _age =
        _dob != null ? (DateTime.now().difference(_dob!).inDays ~/ 365) : null;
    _sex = widget.user?.sex;
    _weight = widget.user?.weight;
    _height = widget.user?.height;
    _calorieLimit = widget.user?.calorieLimit;
    _activeLevel = widget.user?.activeLevel;
    int? selectedIndex =
        _activeLevel != null ? ActiveLevel.values.indexOf(_activeLevel!) : -1;
    if (selectedIndex != -1) _isSelectedLevels[selectedIndex] = true;
  }

  @override
  Widget build(BuildContext context) {
    _updateCalorieLimitRecommend();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Account Information'),
        automaticallyImplyLeading: widget.user != null,
      ),
      body: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: _isLoading
                      ? null
                      : () async {
                          XFile? picture = await imgPicker.pickImage(
                              source: ImageSource.gallery);
                          if (picture == null) return;
                          setState(() {
                            _selectedImage = File(picture.path);
                          });
                        },
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _showProfilePic(),
                        const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(Icons.file_upload_outlined))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: true,
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
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());

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
                              items: ['Male', 'Female']
                                  .map((sex) => DropdownMenuItem(
                                      value: sex, child: Text(sex)))
                                  .toList(),
                              onChanged: (val) => setState(() => _sex = val),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: TextFormField(
                              autofocus: true,
                              initialValue:
                                  _weight == null ? '' : _weight.toString(),
                              validator: _numValidator,
                              onChanged: (val) => setState(() {
                                _weight =
                                    val.isEmpty ? null : double.parse(val);
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
                              autofocus: true,
                              initialValue:
                                  _height == null ? '' : _height.toString(),
                              validator: _numValidator,
                              onChanged: (val) => setState(() {
                                _height =
                                    val.isEmpty ? null : double.parse(val);
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('How active are you?'),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (builder) {
                                    return AlertDialog(
                                      title: const Text('Active Level'),
                                      icon: const Icon(Icons.question_mark),
                                      content: const Text(
                                          'None: Little or no exercise.\nLight: Exercises 1-3 days per week.\nModerate: Exercises 3-5 days per week.\nA lot: Exercises 6-7 days per week.\nVery: Hard exercises 6-7 days per week.'),
                                      actions: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
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
                      ),
                      ToggleButtons(
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < _isSelectedLevels.length; i++) {
                              _isSelectedLevels[i] = i == index;
                              if (_isSelectedLevels[i]) {
                                _activeLevel = ActiveLevel.values[i];
                              }
                            }
                          });
                        },
                        isSelected: _isSelectedLevels,
                        children: ActiveLevel.values
                            .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(e.title)))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        autofocus: true,
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
                      Text(_calorieLimitRecommend == null
                          ? 'Complete the fields to compute the recommended amount.'
                          : 'Recommended Daily Calorie Limit: ${_calorieLimitRecommend?.toStringAsFixed(2)}')
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: getBottomInsets(),
        ),
        child: SizedBox(
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
                        noChanges &= _selectedImage == null;
                        noChanges &= widget.user?.dob ==
                            (_dob != null ? _df.format(_dob!) : null);
                        noChanges &= widget.user?.sex == _sex;

                        noChanges &= widget.user?.weight == _weight;
                        noChanges &= widget.user?.height == _height;
                        noChanges &= widget.user?.activeLevel == _activeLevel;
                        noChanges &= widget.user?.calorieLimit == _calorieLimit;
                      }

                      // Don't waste a write request if no changes happened.
                      if (!noChanges) {
                        await _authService.updateAccountInfo(
                          _displayName,
                          _dob,
                          _sex,
                          _weight,
                          _height,
                          _calorieLimit,
                          _activeLevel,
                          _selectedImage,
                        );
                      }
                      setState(() => _isLoading = false);

                      // Otherwise, it was navigated to and we can just pop it.
                      if (mounted) Navigator.pop(context);
                    },
              child: _isLoading ? const Loader() : const Text('Save'),
            )),
      ),
    );
  }
}
