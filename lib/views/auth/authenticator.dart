import 'package:flutter/widgets.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/views/auth/login_register_selector.dart';
import 'package:nood_food/views/home.dart';
import 'package:provider/provider.dart';

class Authenticator extends StatelessWidget {
  const Authenticator({super.key});

  @override
  Widget build(BuildContext context) {
    final NFUser? user = Provider.of<NFUser?>(context);
    print('this is the user: ' + user.toString());
    return user != null ? const Home() : const LoginRegisterSelector();
  }
}
