import 'package:flutter/material.dart';
import 'package:clima/screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 👈 add this
  runApp( MyApp()); // your app widget
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: LoadingScreen(),
    );
  }
}
