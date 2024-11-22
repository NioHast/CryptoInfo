import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<dynamic>> getOhlcData(String coinId) async {
    final url = Uri.parse('$_baseUrl/coins/$coinId/ohlc?vs_currency=usd&days=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data;
    } else {
      throw Exception('Failed to load OHLC data');
    }
  }

  Future<List<dynamic>> getCryptoPrices() async {
    final url = Uri.parse('$_baseUrl/coins/markets?vs_currency=usd');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data;
    } else {
      throw Exception('Failed to load coin prices');
    }
  }
}