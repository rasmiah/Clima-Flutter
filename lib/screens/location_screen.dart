import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
import 'package:clima/services/weather.dart';
import 'package:clima/screens/city_screen.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({this.locationWeather});
  final locationWeather;
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weatherModel = WeatherModel();
  bool _showCelsius = true; // true = show °C, false = show °F

int? temp;
String? weatherIcon;
String? cityName;
String? weatherMessage;
int? _humidity;
int? _pressure;
double? _wind; // m/s

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateUI(widget.locationWeather);
  }

  void updateUI(dynamic weatherData) {
    if (weatherData == null) {
      temp = 0;
      weatherIcon = 'Error';
      weatherMessage = 'Unable to get weather data';
      cityName = '';
      return;
    }
    final num t = weatherData['main']['temp'];          // e.g., 24.16
    final int condition = weatherData['weather'][0]['id']; // e.g., 721 (Haze)
    final String name = weatherData['name'];

    final main = weatherData['main'] as Map<String, dynamic>;
    final wind = (weatherData['wind'] as Map?) ?? const {};
    final int? humidity = main['humidity'];
    final int? pressure = main['pressure'];
    final double? windSpd = (wind['speed'] as num?)?.toDouble();

    setState(() {
      temp = t.round();                          // -> int °C
      weatherIcon = weatherModel.getWeatherIcon(condition);
      weatherMessage = weatherModel.getMessage(temp!);
      cityName = name;

      _humidity = humidity;
      _pressure = pressure;
      _wind = windSpd;
    });

    // Debug (see exactly what you're passing)
    print('cond=$condition temp=$temp city=$cityName icon=$weatherIcon msg=$weatherMessage');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/location_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.8), BlendMode.dstATop),
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () async {
                      var weatherData = await weatherModel.getLocationWeather();
                      updateUI(weatherData);
                    },
                    child: Icon(
                      Icons.near_me,
                      size: 50.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _showCelsius = !_showCelsius);
                    },
                    child: Text(
                      _showCelsius ? '°C' : '°F',
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      var typedName = await Navigator.push(context, MaterialPageRoute(builder: (context){
                        return CityScreen();
                      }));
                      if(typedName != null){
                       var weatherData= await weatherModel.getCityWeather(typedName);
                       updateUI(weatherData);
                      }
                    },
                    child: Icon(
                      Icons.location_city,
                      size: 50.0,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          (() {
                            if (temp == null) return '--°';
                            final c = temp!;
                            final display = _showCelsius ? c : ((c * 9 / 5) + 32).round();
                            return '$display°'; // only the number changes
                          })(),
                          style: kTempTextStyle,
                        ),

                        Text(weatherIcon ?? '', style: kConditionTextStyle),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (_humidity != null)
                          _StatChip(label: 'Humidity', value: '${_humidity!}%'),
                        if (_pressure != null) ...[
                          const SizedBox(width: 8),
                          _StatChip(label: 'Pressure', value: '${_pressure!} hPa'),
                        ],
                        if (_wind != null) ...[
                          const SizedBox(width: 8),
                          _StatChip(label: 'Wind', value: '${_wind!.toStringAsFixed(1)} m/s'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  "$weatherMessage in $cityName!",
                  textAlign: TextAlign.right,
                  style: kMessageTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
              )),
          const SizedBox(width: 6),
          Text(value,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              )),
        ],
      ),
    );
  }
}


