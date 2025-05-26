import 'package:flutter/material.dart';
import 'package:instant_weather/screens/weather_screen.dart'; // UPDATED

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instant Weather', // Changed title for consistency
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: const WeatherScreen(),
    );
  }
}
