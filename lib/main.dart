import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nood_food/firebase_options.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/views/auth/authenticator.dart';
import 'package:nood_food/views/pages/home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<NFUser?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
          title: 'Nood Food',
          theme: ThemeData(
            // useMaterial3: true,

            // Define the default brightness and colors.
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 170, 231, 220),
              // ···
              brightness: Brightness.dark,
            ),
            // ),

            // Define the default `TextTheme`. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.
            textTheme: TextTheme(
              displayLarge: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
              // ···
              titleLarge: GoogleFonts.oswald(
                fontSize: 30,
                // fontStyle: FontStyle.italic,
              ),
              bodyMedium: GoogleFonts.merriweather(),
              displaySmall: GoogleFonts.pacifico(),
            ),
          ),
          home: const Authenticator()),
    );
  }
}
