import 'dart:convert';
import 'package:http/http.dart' as http;

class JobSearchService {
  static const String baseUrl =
      "https://api.indianapi.com/v1/jobs"; // Update with actual API endpoint
  static const String apiKey =
      "sk-live-ck5sQ3gkjWbIBsmxEGOPphQcQubkqift4spWWP5I"; // Replace with your API key

  Future<List<dynamic>> fetchJobs(String query, String location) async {
    final Uri url = Uri.parse("$baseUrl?query=$query&location=$location");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["jobs"]; // Modify based on API response structure
      } else {
        throw Exception("Failed to load jobs: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching jobs: $e");
      return [];
    }
  }
}
