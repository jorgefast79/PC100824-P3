import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'rent_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();

  void _logout() async {
    await _apiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _goToRentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const azulFuerte = Color(0xFF0033A0);
    const azulClaro = Color(0xFF0073CF);
    const dorado = Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RentaCar El Salvador 🇸🇻',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: azulFuerte,
        elevation: 6,
      ),
      drawer: Drawer(
        child: Container(
          color: azulClaro,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: azulFuerte),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.directions_car, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Menú Principal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.white),
                title: const Text('Alquilar Auto',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _goToRentScreen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Cerrar sesión',
                    style: TextStyle(color: Colors.white)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [azulFuerte, azulClaro],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            color: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car_filled,
                      color: azulFuerte, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Bienvenido a RentaCar El Salvador 🇸🇻',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: azulFuerte,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _goToRentScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dorado,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: const Icon(Icons.car_rental, color: Colors.white),
                    label: const Text(
                      'Alquilar un Auto',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
