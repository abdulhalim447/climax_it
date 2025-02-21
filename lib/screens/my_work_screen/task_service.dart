import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskService {
  final String apiUrl =
      "https://climaxitbd.com/php/my_work_section/admin/get_save_task.php";

  Future<List<dynamic>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          return jsonData['data'];
        } else {
          throw Exception(jsonData['message']);
        }
      } else {
        throw Exception("Failed to load tasks");
      }
    } catch (e) {
      throw Exception("Error fetching tasks: $e");
    }
  }
}
