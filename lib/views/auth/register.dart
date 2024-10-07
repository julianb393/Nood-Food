import 'package:auth_buttons/auth_buttons.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/div_text.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/common/form_utils.dart';

class Register extends StatefulWidget {
  final Function toggleScreen;
  const Register({super.key, required this.toggleScreen});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  // 0: email/pass, 1: google
  final List<bool> _isLoadingButtons = [false, false];

  bool _hidePassword = true;
  String inputEmail = '';
  String inputPassword = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 75,
              backgroundImage: AssetImage('assets/nood_food_logo.png'),
            ),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (email) {
                    return email != null && EmailValidator.validate(email)
                        ? null
                        : 'Please enter a valid email address';
                  },
                  decoration: formDecoration.copyWith(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                  ),
                  onChanged: (val) => setState(() => inputEmail = val),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  validator: (password) {
                    return password != null && validatePassword(password)
                        ? null
                        : 'Please enter a password with the following:\n6 characters, 1 number, and 1 special character';
                  },
                  decoration: formDecoration.copyWith(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      icon: _hidePassword
                          ? const Icon(Icons.remove_red_eye)
                          : const Icon(Icons.remove_red_eye_outlined),
                    ),
                  ),
                  obscureText: _hidePassword,
                  onChanged: (val) => setState(() => inputPassword = val),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: _isLoadingButtons.contains(true)
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() {
                            _isLoadingButtons[0] = true;
                          });

                          // Would show whether login unsuccessful, otherwise
                          // navigate to home page
                          bool isCreated = true;
                          String errMsg = '';
                          try {
                            isCreated = await _authService.registerWithEmail(
                                inputEmail, inputPassword, context);
                          } on FirebaseAuthException {
                            // credentials issue, this case should have been
                            // already covered in the auth service manually.
                            errMsg = 'This email has already been registed.';
                          } catch (error) {
                            // server issue
                            errMsg =
                                'We\'re having issues connecting to our server. Please try again later...';
                          }
                          if (!isCreated) {
                            errMsg = 'This email has already been registed.';
                            setState(() => _isLoadingButtons[0] = false);

                            // This check is needed for async functions for snackbars.
                            if (context.mounted && errMsg.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Text(errMsg),
                                ),
                              );
                            }
                          }
                        },
                  child: _isLoadingButtons[0]
                      ? const Loader()
                      : const Text('Register'),
                ),
              ],
            ),
          ),
          const DivText(text: 'Or continue with'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GoogleAuthButton(
                onPressed: () async {
                  // Disables the button
                  if (_isLoadingButtons.contains(true)) return;
                  setState(() => _isLoadingButtons[1] = true);
                  await _authService.logInWithGoogle(context);
                  setState(() => _isLoadingButtons[1] = false);
                },
                themeMode: ThemeMode.dark,
                isLoading: _isLoadingButtons[1],
                style: const AuthButtonStyle(
                  buttonType: AuthButtonType.icon,
                  iconType: AuthIconType.outlined,
                ),
              ),
              const SizedBox(width: 10),
              // TODO: Apple authentication
              // AppleAuthButton(
              //   onPressed: () async {
              //     setState(() => _isLoading = true);
              //     await _authService.logInWithApple(context);
              //     setState(() => _isLoading = true);
              //   },
              //   themeMode: ThemeMode.dark,
              //   isLoading: _isLoading,
              //   style: const AuthButtonStyle(
              //     buttonType: AuthButtonType.icon,
              //     iconType: AuthIconType.outlined,
              //   ),
              // ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () => widget.toggleScreen(),
              child: const Text('Login'),
            ),
          )
        ],
      ),
    );
  }
}
