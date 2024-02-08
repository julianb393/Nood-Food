import 'package:flutter/material.dart';
import 'package:nood_food/services/auth_service.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: () => AuthService().logout(),
        child: Text('Log out'),
      ),
    );
  }
}
