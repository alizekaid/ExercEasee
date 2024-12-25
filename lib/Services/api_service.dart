import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<Map<String, String>>> fetchGifs(String bodyPart, int painLevel) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getGifs?bodyPart=$bodyPart&painLevel=$painLevel'),
      );

      if (response.statusCode == 200) {
        // Assuming the API returns a JSON array of objects with "name" and "path" properties
        List<Map<String, String>> gifs = List<Map<String, String>>.from(
          json.decode(response.body).map((gif) => {
            'name': gif['name'],
            'path': gif['path']
          }),
        );
        return gifs;
      } else {
        throw Exception('Failed to load GIFs');
      }
    } catch (error) {
      print('Error fetching GIFs: $error');
      return [];
    }
  }
}
