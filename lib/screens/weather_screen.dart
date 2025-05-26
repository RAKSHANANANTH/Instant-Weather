import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:instant_weather/models/weather.dart';
import 'package:instant_weather/models/forecast.dart';
import 'package:instant_weather/services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _locationController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  Weather? _currentWeather;
  List<Forecast>? _fiveDayForecast;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  // Function to fetch weather data based on city name input
  Future<void> _fetchWeatherByCity() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cityName = _locationController.text.trim();
      if (cityName.isEmpty) {
        throw Exception('Please enter a location.');
      }
      final weather = await _weatherService.fetchCurrentWeatherByCity(cityName);
      final forecast = await _weatherService.fetchFiveDayForecastByCity(cityName);
      setState(() {
        _currentWeather = weather;
        _fiveDayForecast = forecast;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _currentWeather = null; // Clear previous weather data on error
        _fiveDayForecast = null; // Clear previous forecast data on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to fetch weather data based on current GPS location
  Future<void> _fetchWeatherByCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final position = await _weatherService.getCurrentLocation();
      final weather = await _weatherService.fetchCurrentWeatherByCoordinates(
          position.latitude, position.longitude);
      final forecast = await _weatherService.fetchFiveDayForecastByCoordinates(
          position.latitude, position.longitude);
      setState(() {
        _currentWeather = weather;
        _fiveDayForecast = forecast;
        _locationController.text = weather.cityName; // Update input field with detected city
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _currentWeather = null;
        _fiveDayForecast = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instant Weather'), // Or your Image.asset logo here
        centerTitle: true,
      ),
      body: SingleChildScrollView( // <--- This wraps the entire body content
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Location Input Field
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Enter City, Zip Code, or Landmark',
                hintText: 'e.g., Delhi, 110001, Connaught Place',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchWeatherByCity,
                ),
              ),
              onSubmitted: (_) => _fetchWeatherByCity(), // Fetch on pressing enter
            ),
            const SizedBox(height: 16.0),
            // Button to get weather for current location
            ElevatedButton.icon(
              onPressed: _fetchWeatherByCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Weather for Current Location'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // Make button full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Loading Indicator
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
            // Error Message Display
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              )
            else if (_currentWeather != null)
              // Current Weather Display and Forecast
                Column(
                  mainAxisSize: MainAxisSize.min, // Tells Column to be as small as its children
                  children: [
                    _buildCurrentWeatherCard(_currentWeather!),
                    const SizedBox(height: 24.0),
                    if (_fiveDayForecast != null && _fiveDayForecast!.isNotEmpty)
                      _buildFiveDayForecast(_fiveDayForecast!),
                  ],
                )
              else
              // Initial welcome message
                const Text(
                  'Enter a location or use your current location to get weather updates.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the current weather display card
  Widget _buildCurrentWeatherCard(Weather weather) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              weather.cityName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.network(
              weather.iconUrl,
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, size: 100), // Fallback icon
            ),
            Text(
              '${weather.temperature.round()}°C',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text(
              weather.description.capitalizeFirstofEach,
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail('Humidity', '${weather.humidity}%', Icons.water_drop),
                _buildWeatherDetail('Wind', '${weather.windSpeed} m/s', Icons.air),
                _buildWeatherDetail('Pressure', '${weather.pressure} hPa', Icons.speed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build individual weather detail items
  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Helper widget to build the 5-day forecast display
  Widget _buildFiveDayForecast(List<Forecast> forecasts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5-Day Forecast',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 155.0, // <--- CHANGED: Increased the height slightly to allow for full content, will adjust individual card's padding.
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  width: 120, // Fixed width for each forecast card
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // <--- CHANGED: Reduced vertical padding slightly
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE, MMM d').format(forecast.date),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        forecast.iconUrl,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, size: 50), // Fallback icon
                      ),
                      Text(
                        '${forecast.temperature.round()}°C',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // Ensure description text fits within one line or wraps without overflow
                      Text(
                        forecast.description.capitalizeFirstofEach,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                        maxLines: 2, // <--- ADDED: Allow up to 2 lines for description
                        overflow: TextOverflow.ellipsis, // <--- ADDED: Truncate if more than 2 lines
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Extension for string capitalization (keep this at the very bottom of weather_screen.dart)
extension StringExtension on String {
  String get capitalizeFirstofEach => split(" ").map((str) => str.capitalizeFirst).join(" ");
  String get capitalizeFirst => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}