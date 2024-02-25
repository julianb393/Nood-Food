import 'package:flutter/material.dart';
import 'package:nood_food/common/card_button.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/views/pages/account/account_info.dart';
import 'package:nood_food/views/pages/account/change_password.dart';

class Account extends StatelessWidget {
  final NFUser user;
  const Account({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CardButton(
                  title: 'Account Information',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountInfo(user: user)),
                  ),
                  icon: Icons.person,
                ),
                CardButton(
                  title: 'Change Password',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePassword()),
                  ),
                  icon: Icons.password,
                ),
                CardButton(
                  title: 'Logout',
                  onTap: () => AuthService().logout(),
                  icon: Icons.logout,
                ),
              ],
            ),
          ),
          CardButton(
            color: Colors.red,
            icon: Icons.delete_forever,
            title: 'Delete Account',
            onTap: () {},
          ),
          const Divider(),
          const Text('Version: Development')
        ],
      ),
    );
  }
}
