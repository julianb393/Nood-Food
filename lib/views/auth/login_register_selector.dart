import 'package:flutter/material.dart';
import 'package:nood_food/views/auth/login.dart';
import 'package:nood_food/views/auth/register.dart';

/// Widget used for determining which widget gets displayed: login or register.
class LoginRegisterSelector extends StatefulWidget {
  const LoginRegisterSelector({super.key});

  @override
  State<LoginRegisterSelector> createState() => _LoginRegisterSelectorState();
}

class _LoginRegisterSelectorState extends State<LoginRegisterSelector> {
  bool isLoginScreen = true;

  void _toggleScreen() {
    setState(() {
      isLoginScreen = !isLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoginScreen
        ? Login(toggleScreen: _toggleScreen)
        : Register(toggleScreen: _toggleScreen);
  }
}
