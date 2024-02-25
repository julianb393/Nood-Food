import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/form_utils.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/services/auth_service.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _currentPassword = '';
  String _newPassword = '';
  bool _showThisPage = false;
  bool _isLoading = false;
  bool _hidePasswords = true;

  @override
  void initState() {
    super.initState();
    _showThisPage = _authService.hasPasswordProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: !_showThisPage
            ? const Center(
                child: Text(
                    'You created this account using an external provider like Google or Apple.'))
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        obscureText: _hidePasswords,
                        onChanged: (value) =>
                            setState(() => _currentPassword = value),
                        decoration: formDecoration.copyWith(
                          labelText: 'Current Password',
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                                () => _hidePasswords = !_hidePasswords),
                            icon: _hidePasswords
                                ? const Icon(Icons.remove_red_eye)
                                : const Icon(Icons.remove_red_eye_outlined),
                          ),
                        )),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: _hidePasswords,
                      onChanged: (value) =>
                          setState(() => _newPassword = value),
                      validator: (password) {
                        return password != null && validatePassword(password)
                            ? null
                            : 'Please enter a password with the following:\n6 characters, 1 number, and 1 special character';
                      },
                      decoration: formDecoration.copyWith(
                        labelText: 'New Password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePasswords = !_hidePasswords),
                          icon: _hidePasswords
                              ? const Icon(Icons.remove_red_eye)
                              : const Icon(Icons.remove_red_eye_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                        obscureText: _hidePasswords,
                        validator: (value) => value != _newPassword
                            ? 'This does not match the New Password'
                            : null,
                        decoration: formDecoration.copyWith(
                          labelText: 'New Password Confirmation',
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                                () => _hidePasswords = !_hidePasswords),
                            icon: _hidePasswords
                                ? const Icon(Icons.remove_red_eye)
                                : const Icon(Icons.remove_red_eye_outlined),
                          ),
                        )),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              setState(() => _isLoading = true);
                              try {
                                await _authService.changePassword(
                                    _currentPassword, _newPassword);
                                if (mounted) Navigator.pop(context);
                              } on FirebaseAuthException catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.redAccent,
                                      content: Text(e.message!),
                                    ),
                                  );
                                }
                              }
                              setState(() => _isLoading = true);
                            },
                      child: _isLoading
                          ? const Loader()
                          : const Text('Change Password'),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
