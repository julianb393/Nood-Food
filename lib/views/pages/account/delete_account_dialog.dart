import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/form_utils.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final bool _hasEmailPassProvider = AuthService().hasPasswordProvider();
  bool _isLoading = false;
  bool _hidePassword = true;
  String? _confirmPassword;

  @override
  void initState() {
    super.initState();
    _confirmPassword = _hasEmailPassProvider ? '' : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'Are you sure you want to delete your account?\n\nThis action is permanent.'),
          !_hasEmailPassProvider
              ? const SizedBox()
              : Form(
                  key: _formKey,
                  child: TextFormField(
                    validator: ((value) => value == null || value.isEmpty
                        ? 'Pleae enter a value'
                        : null),
                    onChanged: (value) =>
                        setState(() => _confirmPassword = value),
                    decoration: formDecoration.copyWith(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        icon: _hidePassword
                            ? const Icon(Icons.remove_red_eye)
                            : const Icon(Icons.remove_red_eye_outlined),
                      ),
                    ),
                  ))
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: _isLoading
          ? [const Loader()]
          : [
              ElevatedButton(
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? true)) return;

                    setState(() => _isLoading = true);
                    try {
                      // If successfull, auth state will change and redirect to
                      // login page.
                      await DBService(uid: AuthService().userUid)
                          .deleteUserData();
                      await AuthService().deleteUserAccount(_confirmPassword);
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text(e.message ??
                                'Something went wrong... Please try again later.'),
                          ),
                        );
                      }
                      setState(() => _isLoading = false);
                      return;
                    }
                    setState(() => _isLoading = false);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Yes, Delete it!')),
              ElevatedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('No'))
            ],
    );
  }
}
