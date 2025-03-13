import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> uploadResume(
      String jobDescription, File resumeFile) async {
    var uri = Uri.parse("http://192.168.0.227:5000/api/analyze"); // Flask URL

    var request = http.MultipartRequest('POST', uri)
      //..fields['job_description'] = jobDescription
      ..files.add(await http.MultipartFile.fromPath('resume', resumeFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      throw Exception(
          "Failed to upload resume. Status Code: ${response.statusCode}");
    }
  }
}
