import 'package:flutter/material.dart';
import 'package:nood_food/views/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // useMaterial3: true,

        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 170, 231, 220),
          // ···
          brightness: Brightness.dark,
          // ),

          // Define the default `TextTheme`. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          // textTheme: TextTheme(
          //   displayLarge: const TextStyle(
          //     fontSize: 72,
          //     fontWeight: FontWeight.bold,
          //   ),
          //   // ···
          //   titleLarge: GoogleFonts.oswald(
          //     fontSize: 30,
          //     fontStyle: FontStyle.italic,
          //   ),
          //   bodyMedium: GoogleFonts.merriweather(),
          //   displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      home: const Home(),
    );
  }
}
