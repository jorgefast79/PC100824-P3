import 'package:flutter/material.dart';
import '../models/car.dart';
import '../models/rental.dart';
import '../services/api_service.dart';

class RentScreen extends StatefulWidget {
  const RentScreen({Key? key}) : super(key: key);

  @override
  _RentScreenState createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  final ApiService api = ApiService();
  List<Car> availableCars = [];
  Car? selectedCar;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    try {
      final carsJson = await api.getAvailableCars();
      setState(() => availableCars = carsJson);
    } catch (e) {
      print('Error fetching cars: $e');
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _rentCar() async {
    if (selectedCar == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un auto y fechas válidas')),
      );
      return;
    }

    final rental = Rental(
      carId: selectedCar!.id,
      startDate: _startDate!,
      endDate: _endDate!,
    );

    try {
      final success = await api.rentCar(rental.toJson());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Auto alquilado correctamente'
            : 'Error al alquilar el auto'),
      ));
      if (success) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const azulFuerte = Color(0xFF0033A0);
    const azulClaro = Color(0xFF0073CF);
    const dorado = Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alquilar Auto'),
        backgroundColor: azulFuerte,
        elevation: 6,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [azulClaro, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Selecciona tu vehículo',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: azulFuerte),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<Car>(
                    hint: const Text('Selecciona un auto'),
                    value: selectedCar,
                    items: availableCars.map((car) {
                      return DropdownMenuItem<Car>(
                        value: car,
                        child: Text('${car.brand} ${car.model}'),
                      );
                    }).toList(),
                    onChanged: (car) => setState(() => selectedCar = car),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectStartDate(context),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: azulFuerte),
                          child: Text(_startDate == null
                              ? 'Fecha inicio'
                              : _startDate!.toLocal().toString().split(' ')[0]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectEndDate(context),
                          style:
                          ElevatedButton.styleFrom(backgroundColor: azulFuerte),
                          child: Text(_endDate == null
                              ? 'Fecha fin'
                              : _endDate!.toLocal().toString().split(' ')[0]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _rentCar,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmar Alquiler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dorado,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
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
