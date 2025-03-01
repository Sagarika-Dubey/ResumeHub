import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResumeScreen extends StatefulWidget {
  @override
  _ResumeScreenState createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  File? selectedFile;
  String result = "Upload a resume to check ATS Score";

  Future<void> pickFileAndUpload() async {
    FilePickerResult? pickedResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (pickedResult != null && pickedResult.files.isNotEmpty) {
      File selectedFile = File(pickedResult.files.single.path!);

      try {
        var response = await uploadResume(selectedFile);
        setState(() {
          result = response['ats_score']?.toString() ?? "No score received";
        });
      } catch (e) {
        setState(() {
          result = "Error: ${e.toString()}";
        });
      }
    } else {
      print("❌ No file selected");
    }
  }

  Future<Map<String, dynamic>> uploadResume(File file) async {
    final String apiUrl =
        "http://192.168.0.227:5000/ats_score"; // Replace with your Flask server IP

    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath("resume", file.path));
      request.fields['job_description'] =
          "Software Engineer"; // Change accordingly

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("✅ Success: ${json.decode(responseBody)}");
        return json.decode(responseBody);
      } else {
        print("❌ Failed: ${response.statusCode}, Response: $responseBody");
        throw Exception("Failed to upload. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error uploading resume: $e");
      throw Exception("Error uploading resume: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Resume for ATS Score")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: pickFileAndUpload,
                child: Text("Upload Resume"),
              ),
              SizedBox(height: 20),
              Text(result, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
