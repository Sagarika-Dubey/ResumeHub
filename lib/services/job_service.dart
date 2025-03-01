import 'dart:convert';
import 'package:http/http.dart' as http;

class JobApisService {
  static const String baseUrl = "https://findwork.dev/api/jobs/";
  final String apiKey =
      "fc176401ceb7a0803f7523e48caa9e131355ba8d"; // Replace with your Findwork API Key

  Future<List<dynamic>> fetchJobs(
      {String query = "developer", String location = ""}) async {
    try {
      final response = await http.get(
        Uri.parse(
            "$baseUrl?search=$query${location.isNotEmpty ? '&location=$location' : ''}"),
        headers: {
          "Authorization": "Token $apiKey",
          "Content-Type": "application/json",
        },
      );

      print("API Status Code: ${response.statusCode}"); // Debugging
      print("API Response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['results'] ?? [];
      } else {
        throw Exception("Failed to fetch jobs: ${response.body}");
      }
    } catch (e) {
      print("Error fetching jobs: $e");
      return [];
    }
  }
}
