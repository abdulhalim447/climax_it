import 'package:http/http.dart' as http;
import 'dart:convert';

Future<double> fetchIncome(String userId, String filter) async {
  final response = await http.post(
    Uri.parse('https://climaxitbd.com/php/income_filter/filter_income.php'),
    body: {
      'user_id': userId,
      'filter': filter,
    },
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    if (data['status'] == 'success') {
      return double.tryParse(data['income'].toString()) ?? 0.0;
    } else {
      throw Exception('Failed to load income');
    }
  } else {
    throw Exception('Failed to load income');
  }
}
