import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/common/form_decoration.dart';

class Register extends StatefulWidget {
  final Function toggleScreen;
  const Register({super.key, required this.toggleScreen});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final RegExp specialCharsRegex =
      RegExp(r'[~`!@#\$%^&*()-_+=|}\]{\[":;?/>.<,]');
  final RegExp numsRegex = RegExp(r'[0-9]');
  bool _isLoading = false;
  bool _hidePassword = true;
  String inputEmail = '';
  String inputPassword = '';

  bool _validatePassword(String password) {
    return password.length >= 6 &&
        password.contains(numsRegex) &&
        password.contains(specialCharsRegex);
  }

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
                    return password != null && _validatePassword(password)
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
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            print('Form is invalid');
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                          });

                          // Would show whether login unsuccessful, otherwise
                          // navigate to home page
                          String errMsg;
                          try {
                            await _authService.registerWithEmail(
                                inputEmail, inputPassword);
                            return;
                          } on FirebaseAuthException catch (error) {
                            // credentiala issue
                            errMsg = 'This email has already been registed.';
                            print(error);
                          } catch (error) {
                            // server issue
                            errMsg = 'We\'re having issues connecting to' +
                                ' our server. Please try again later...';
                            print(error);
                          }

                          setState(() {
                            _isLoading = false;
                          });

                          // This check is needed for async functions for snackbars.
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text(errMsg),
                              ),
                            );
                          }
                        },
                  child: _isLoading ? const Loader() : const Text('Register'),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          SignInButton(
            Buttons.Google,
            onPressed: () async {
              setState(() => _isLoading = true);
              await _authService.logInWithGoogle();
              setState(() => _isLoading = false);
            },
          ),
          SignInButton(
            Buttons.Apple,
            onPressed: () {},
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () => widget.toggleScreen(),
              child: const Text('or Login'),
            ),
          )
        ],
      ),
    );
  }
}
