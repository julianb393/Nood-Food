import 'package:flutter/material.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/views/auth/login_register_selector.dart';
import 'package:provider/provider.dart';
import 'package:nood_food/views/page_navigator.dart';

class Authenticator extends StatelessWidget {
  const Authenticator({super.key});

  @override
  Widget build(BuildContext context) {
    final NFUser? user = Provider.of<NFUser?>(context);
    return user != null ? const PageNavigator() : const LoginRegisterSelector();
  }
}
