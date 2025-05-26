import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:instant_weather/models/weather.dart'; // UPDATED - Ensure this path is correct
import 'package:instant_weather/models/forecast.dart'; // UPDATED - Ensure this path is correct
import 'package:instant_weather/utils/constants.dart'; // UPDATED - Ensure this path is correct

class WeatherService {
  // Fetches current weather data by city name
  Future<Weather> fetchCurrentWeatherByCity(String cityName) async {
    final response = await http.get(
      Uri.parse('$openWeatherMapBaseUrl/weather?q=$cityName&appid=$openWeatherMapApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('City not found. Please check the spelling.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API Key. Please check your OpenWeatherMap API key.');
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  // Fetches current weather data by GPS coordinates
  Future<Weather> fetchCurrentWeatherByCoordinates(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$openWeatherMapBaseUrl/weather?lat=$latitude&lon=$longitude&appid=$openWeatherMapApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API Key. Please check your OpenWeatherMap API key.');
    } else {
      throw Exception('Failed to load weather data for current location: ${response.statusCode}');
    }
  }

  // Fetches 5-day forecast data by city name
  Future<List<Forecast>> fetchFiveDayForecastByCity(String cityName) async {
    final response = await http.get(
      Uri.parse('$openWeatherMapBaseUrl/forecast?q=$cityName&appid=$openWeatherMapApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      List<Forecast> forecasts = [];
      final data = jsonDecode(response.body);
      // OpenWeatherMap's 5-day forecast provides data every 3 hours.
      // We'll extract one entry per day, typically around noon or closest to it.
      // This logic picks one entry per day for the next 5 days.
      Set<String> uniqueDates = {};
      for (var item in data['list']) {
        final forecast = Forecast.fromJson(item);
        final dateString = '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';
        if (uniqueDates.length < 5 && !uniqueDates.contains(dateString)) {
          forecasts.add(forecast);
          uniqueDates.add(dateString);
        }
        if (uniqueDates.length == 5) break; // Stop after collecting 5 unique days
      }
      return forecasts;
    } else if (response.statusCode == 404) {
      throw Exception('City not found for forecast. Please check the spelling.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API Key. Please check your OpenWeatherMap API key.');
    } else {
      throw Exception('Failed to load forecast data: ${response.statusCode}');
    }
  }

  // Fetches 5-day forecast data by GPS coordinates
  Future<List<Forecast>> fetchFiveDayForecastByCoordinates(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$openWeatherMapBaseUrl/forecast?lat=$latitude&lon=$longitude&appid=$openWeatherMapApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      List<Forecast> forecasts = [];
      final data = jsonDecode(response.body);
      Set<String> uniqueDates = {};
      for (var item in data['list']) {
        final forecast = Forecast.fromJson(item);
        final dateString = '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';
        if (uniqueDates.length < 5 && !uniqueDates.contains(dateString)) {
          forecasts.add(forecast);
          uniqueDates.add(dateString);
        }
        if (uniqueDates.length == 5) break;
      }
      return forecasts;
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API Key. Please check your OpenWeatherMap API key.');
    } else {
      throw Exception('Failed to load forecast data for current location: ${response.statusCode}');
    }
  }

  // Checks and requests location permissions
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users to enable the location services.
      throw Exception('Location services are disabled. Please enable them.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}