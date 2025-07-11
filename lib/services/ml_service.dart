import 'dart:convert';
import 'package:http/http.dart' as http;

class MLService {
  final String baseUrl = 'http://192.168.18.5:8000'; // Cambia por la IP de tu PC

  Future<Map<String, dynamic>> fetchDashboardInsights() async {
    final response = await http.get(Uri.parse('$baseUrl/insights/dashboard'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener insights de ML');
    }
  }
}

