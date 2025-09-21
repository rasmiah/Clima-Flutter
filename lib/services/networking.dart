import 'package:http/http.dart' as http;
import 'dart:convert';


class NetworkHelper{
  NetworkHelper(this.url);

  final  String url;

  Future<Map<String, dynamic>> getData() async {
    final uri = Uri.parse(url);
    print('FETCH: $uri'); // <-- shows the exact coordinates & units
    final res = await http.get(uri);
    print('STATUS: ${res.statusCode}');
    print('BODY: ${res.body}'); // <-- shows the full JSON (or error)

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // Return a shaped error instead of null
    return {'cod': res.statusCode, 'message': res.body};
  }
}