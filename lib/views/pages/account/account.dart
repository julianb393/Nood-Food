import 'package:flutter/material.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/views/pages/account/account_info.dart';
import 'package:nood_food/views/pages/account/settings.dart';

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
                Card(
                  child: InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountInfo(user: user))),
                    child: const ListTile(
                      title: Text('Update Account Information'),
                      leading: Icon(Icons.person),
                    ),
                  ),
                ),
                Card(
                  child: InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Settings())),
                    child: const ListTile(
                      title: Text('Settings'),
                      leading: Icon(Icons.settings),
                    ),
                  ),
                ),
                Card(
                  child: InkWell(
                    onTap: () => AuthService().logout(),
                    child: const ListTile(
                      title: Text('Logout'),
                      leading: Icon(Icons.logout),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const Text('Version: Development')
        ],
      ),
    );
  }
}
