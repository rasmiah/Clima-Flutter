import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clima/utilities/constants.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  final TextEditingController _controller = TextEditingController();
  String? cityName;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();

    }
  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('city_history', []); // reset instead of remove
    setState(() => _history = []);
  }


  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('city_history') ?? [];
    });
  }

  Future<void> _saveToHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('city_history') ?? [];

    // avoid duplicates, most recent first
    list.remove(city);
    list.insert(0, city);

    // keep only last 5
    if (list.length > 5) list.removeRange(5, list.length);

    await prefs.setStringList('city_history', list);
    setState(() => _history = list);
  }

  void _submit(String city) {
    if (city.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city name')),
      );
      return;
    }
    _saveToHistory(city.trim());
    Navigator.pop(context, city.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/city_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, size: 50.0),
                ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _controller,
                  onChanged: (value) => cityName = value,
                  onSubmitted: _submit,
                  style: const TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: Icon(Icons.location_city, color: Colors.white),
                    hintText: 'Enter City Name',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // History chips
              // History "textbox" card
              // History "textbox" card — always visible
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 3),
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent cities',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Clear',
                            icon: const Icon(Icons.delete_outline, size: 20), // less “menu”-like
                            onPressed: _history.isEmpty ? null : _clearHistory,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Content: chips or placeholder
                      _history.isEmpty
                          ? const Text(
                        'No recent cities',
                        style: TextStyle(
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                          : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _history.map((city) {
                          return ActionChip(
                            label: Text(city),
                            onPressed: () => _submit(city),
                            backgroundColor: Colors.white,
                            labelStyle: const TextStyle(color: Colors.black87),
                            shape: const StadiumBorder(
                              side: BorderSide(color: Colors.black12),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),



              const Spacer(),

              TextButton(
                onPressed: () => _submit(cityName ?? ''),
                child: const Text('Get Weather', style: kButtonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
