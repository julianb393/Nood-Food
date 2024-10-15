import 'package:flutter/material.dart';
import 'package:nood_food/common/card_button.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/util/avatar.dart';
import 'package:nood_food/views/pages/account/account_info.dart';
import 'package:nood_food/views/pages/account/change_password.dart';
import 'package:nood_food/views/pages/account/delete_account_dialog.dart';

class Account extends StatefulWidget {
  final NFUser user;
  final Function? onUserInfoUpdate;
  const Account({super.key, required this.user, this.onUserInfoUpdate});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Widget createProfile() {
    return Column(
      children: [
        Avatar(avatarUrl: widget.user.photoURL, radius: 30),
        const SizedBox(height: 10),
        Text(widget.user.displayName ?? '')
      ],
    );
  }

  Widget createDaysTracked() {
    return Column(
      children: [
        const Text('Days Tracked'),
        Text('${widget.user.numDaysTracked}'),
      ],
    );
  }

  Widget createCurrentWeight() {
    return Column(
      children: [
        const Text('Current Weight'),
        Text('${widget.user.weight ?? 0.0} lbs')
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createProfile(),
                createDaysTracked(),
                createCurrentWeight(),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CardButton(
                  title: 'Update Account Information',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountInfo(user: widget.user)),
                  ).then(
                      (newUserInfo) => widget.onUserInfoUpdate!(newUserInfo)),
                  icon: Icons.person,
                ),
                CardButton(
                  title: 'Change Password',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePassword()),
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
            onTap: () async {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) => const DeleteAccountDialog(),
              );
            },
          ),
          const Divider(),
          const Text('Version: Development')
        ],
      ),
    );
  }
}
