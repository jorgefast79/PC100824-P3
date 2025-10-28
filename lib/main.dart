import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/rent_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(RentacarApp());
}

class RentacarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RentaCar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/rent': (context) => RentScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
