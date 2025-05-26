class Forecast {
  final DateTime date;
  final double temperature;
  final String description;
  final String iconCode;

  Forecast({
    required this.date,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
    );
  }

  String get iconUrl => 'http://openweathermap.org/img/wn/$iconCode.png';
}
