import 'dart:convert';
import 'package:http/http.dart' as http;

class ExpenseService {
  final String baseUrl = 'http://192.168.18.5:8082'; // Cambia por la IP de tu PC y el puerto correcto

  Future<List<dynamic>> fetchExpenses(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/$userId/expenses'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener gastos');
    }
  }
}
