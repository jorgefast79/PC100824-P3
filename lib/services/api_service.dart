import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car.dart';
import '../models/rental.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000'; // Emulador Android

  // ---------------- LOGIN (con TOTP) ----------------
  Future<bool> login(String email, String password, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'otp': otp, // código TOTP generado en Google Authenticator
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      return true;
    }
    return false;
  }

  // ---------------- REGISTRO (crea secreto TOTP) ----------------
  Future<Map<String, dynamic>?> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Devuelve info para mostrar QR del TOTP
      return data;
    }
    return null;
  }

  // ---------------- TOKEN ----------------
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ---------------- AUTOS DISPONIBLES ----------------
  Future<List<Car>> getAvailableCars() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/cars'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map<Car>((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener autos disponibles');
    }
  }

  // ---------------- ALQUILAR AUTO ----------------
  Future<bool> rentCar(Map<String, dynamic> rentalData) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/bookings'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(rentalData),
    );

    return response.statusCode == 201;
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
