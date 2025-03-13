import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class JobRecommendationScreen extends StatefulWidget {
  @override
  _JobRecommendationScreenState createState() =>
      _JobRecommendationScreenState();
}

class _JobRecommendationScreenState extends State<JobRecommendationScreen> {
  File? _resumeFile;
  Map<String, dynamic>? _jobRecommendation;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
        _errorMessage = ''; // Clear any previous error
      });
    }
  }

  Future<void> _recommendJob() async {
    if (_resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a resume first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _jobRecommendation = null;
      _errorMessage = '';
    });

    try {
      String baseUrl =
          'http://192.168.117.184:5000'; // Change to Flask Server IP

      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/recommend'));

      request.files.add(
        await http.MultipartFile.fromPath('resume', _resumeFile!.path),
      );

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        setState(() {
          _jobRecommendation = responseBody;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Detailed Error: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Recommender'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickResume,
              child: Text('Select Resume (PDF)'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 10),
            if (_resumeFile != null)
              Text(
                'Selected: ${_resumeFile!.path.split('/').last}',
                style: TextStyle(color: Colors.green),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _recommendJob,
              child: Text('Get Job Recommendation'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 16),
            if (_isLoading) Center(child: CircularProgressIndicator()),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            if (_jobRecommendation != null)
              Flexible(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended Job',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 15),
                          _buildDetailRow(
                              'Job Title',
                              _jobRecommendation!['recommendation']
                                      ?.get('job_title', 'N/A') ??
                                  'N/A'),
                          _buildDetailRow(
                              'Experience Required',
                              _jobRecommendation!['recommendation']
                                      ?.get('experience_required', 'N/A') ??
                                  'N/A'),
                          _buildDetailRow(
                              'Functional Area',
                              _jobRecommendation!['recommendation']
                                      ?.get('functional_area', 'N/A') ??
                                  'N/A'),
                          _buildDetailRow(
                              'Key Skills',
                              _jobRecommendation!['recommendation']
                                      ?.get('key_skills', 'N/A') ??
                                  'N/A'),
                          _buildDetailRow('Similarity Score',
                              '${_jobRecommendation!['recommendation']?.get('similarity_score', 0)}%'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
