import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SkillAnalysisScreen extends StatefulWidget {
  const SkillAnalysisScreen({super.key});

  @override
  _SkillAnalysisScreenState createState() => _SkillAnalysisScreenState();
}

class _SkillAnalysisScreenState extends State<SkillAnalysisScreen> {
  File? _resumeFile;
  String? _fileName;
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  Map<String, dynamic>? _analysisResult;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Add listener to update the UI when text changes
    _jobDescriptionController.addListener(_updateLength);
  }

  // This method will trigger a UI refresh when text changes
  void _updateLength() {
    setState(() {
      // Just triggering a rebuild
    });
  }

  // Method to pick a resume file
  Future<void> pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
      );

      if (result != null) {
        setState(() {
          _resumeFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error selecting file: $e";
      });
    }
  }

  Future<void> analyzeSkills() async {
    // Validate inputs
    if (_resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload a resume file"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final jobDescription = _jobDescriptionController.text.trim();
    if (jobDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a job description"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = null;
      _errorMessage = null;
    });

    try {
      // Create a proper MultipartRequest
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.152.184:5001/api/skill'));

      // Add the job description field - ensure the field name matches exactly what the API expects
      request.fields['job'] = jobDescription;

      // Add the resume file with the correct field name
      final file = await http.MultipartFile.fromPath(
          'resume', _resumeFile!.path,
          filename: _fileName ?? 'resume.pdf');
      request.files.add(file);

      // For debugging
      print("Sending request with job description: $jobDescription");
      print("File path: ${_resumeFile!.path}");
      print("Field names: ${request.fields.keys}");
      print("File field names: ${request.files.map((f) => f.field).toList()}");

      // Send the request with a timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              "Request timed out. Please check your network connection.");
        },
      );

      // Convert to a regular response
      final response = await http.Response.fromStream(streamedResponse);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          try {
            _analysisResult = json.decode(response.body);
          } catch (e) {
            _analysisResult = {"message": response.body};
          }
        });
      } else {
        // Handle error response
        String errorMsg = "Server error (${response.statusCode})";

        if (response.statusCode == 400) {
          errorMsg = "Bad request: The server couldn't process your request";
          try {
            final errorJson = json.decode(response.body);
            if (errorJson.containsKey('error')) {
              errorMsg = errorJson['error'];
            } else if (errorJson.containsKey('message')) {
              errorMsg = errorJson['message'];
            }
          } catch (_) {
            // If response isn't valid JSON
            if (response.body.isNotEmpty && response.body.length < 100) {
              errorMsg = "${response.statusCode}: ${response.body}";
            }
          }
        }

        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      print("Exception during API call: $e");
      setState(() {
        _errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Implementation of the alternative method
  Future<void> analyzeSkillsAlternative() async {
    // Validate inputs
    if (_resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload a resume file"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final jobDescription = _jobDescriptionController.text.trim();
    if (jobDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a job description"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = null;
      _errorMessage = null;
    });

    try {
      // Alternative approach using a different endpoint or method
      // In this example, we'll use a URL-encoded form instead of multipart

      // Read the resume file as bytes
      final bytes = await _resumeFile!.readAsBytes();
      final base64File = base64Encode(bytes);

      final response = await http
          .post(
        Uri.parse('http://192.168.152.184:5001/api/skill-alt'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'job': jobDescription,
          'resume_data': base64File,
          'filename': _fileName ?? 'resume.pdf',
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              "Request timed out. Please check your network connection.");
        },
      );

      print("Alternative method - Response status: ${response.statusCode}");
      print("Alternative method - Response body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          try {
            _analysisResult = json.decode(response.body);
          } catch (e) {
            _analysisResult = {"message": response.body};
          }
        });
      } else {
        // Handle error response
        String errorMsg = "Server error (${response.statusCode})";

        try {
          final errorJson = json.decode(response.body);
          if (errorJson.containsKey('error')) {
            errorMsg = errorJson['error'];
          } else if (errorJson.containsKey('message')) {
            errorMsg = errorJson['message'];
          }
        } catch (_) {
          // If response isn't valid JSON
          if (response.body.isNotEmpty && response.body.length < 100) {
            errorMsg = "${response.statusCode}: ${response.body}";
          }
        }

        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      print("Exception during alternative API call: $e");
      setState(() {
        _errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildResultCard(String title, dynamic content, {Color? color}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (content is List)
              ...content.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.toString())),
                      ],
                    ),
                  ))
            else if (content is Map)
              ...content.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${entry.key}:",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(entry.value.toString()),
                        ),
                      ],
                    ),
                  ))
            else
              Text(
                content.toString(),
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_errorMessage != null) {
      return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    "Error",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              const Text(
                "Troubleshooting tips:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("• Check if your API server is running"),
              const Text("• Verify the IP address and port are correct"),
              const Text("• Ensure your resume file is valid"),
              const Text("• Check network connectivity"),
              const Text("• Make sure the job description isn't too long"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text("Test Connection"),
                    onPressed: _testConnection,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Alternative Method"),
                    onPressed: analyzeSkillsAlternative,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    if (_analysisResult == null) {
      return const SizedBox();
    }

    if (_analysisResult!.containsKey("error") &&
        _analysisResult!["error"] == true) {
      return _buildResultCard(
        "Error",
        _analysisResult!["message"],
        color: Colors.red[50],
      );
    }

    // Assuming the response structure based on typical skill analysis APIs
    // Modify this based on your actual API response structure
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_analysisResult!.containsKey("match_percentage"))
          _buildScoreIndicator(_analysisResult!["match_percentage"]),

        if (_analysisResult!.containsKey("matching_skills"))
          _buildResultCard(
            "Matching Skills",
            _analysisResult!["matching_skills"],
            color: Colors.green[50],
          ),

        if (_analysisResult!.containsKey("missing_skills"))
          _buildResultCard(
            "Skills to Develop",
            _analysisResult!["missing_skills"],
            color: Colors.amber[50],
          ),

        if (_analysisResult!.containsKey("recommendations"))
          _buildResultCard(
            "Recommendations",
            _analysisResult!["recommendations"],
          ),

        // Fallback for unstructured responses
        if (!_analysisResult!.containsKey("match_percentage") &&
            !_analysisResult!.containsKey("matching_skills") &&
            !_analysisResult!.containsKey("missing_skills") &&
            !_analysisResult!.containsKey("recommendations") &&
            _analysisResult!.containsKey("message"))
          _buildResultCard("Analysis Result", _analysisResult!["message"]),

        // Raw data display for debugging
        ExpansionTile(
          title: const Text("Debug Information"),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                json.encode(_analysisResult),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Simple test connection method
  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('http://192.168.152.184:5001/api/skill');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException("Connection timed out. Server might be down.");
        },
      );

      setState(() {
        _errorMessage =
            "Server connection test: ${response.statusCode} ${response.reasonPhrase}";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Connection test failed: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildScoreIndicator(dynamic score) {
    double matchScore = 0;
    try {
      if (score is int) {
        matchScore = score / 100;
      } else if (score is double) {
        matchScore = score / 100;
      } else if (score is String) {
        matchScore = double.parse(score.replaceAll('%', '')) / 100;
      }
    } catch (e) {
      matchScore = 0;
    }

    matchScore = matchScore.clamp(0.0, 1.0);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Job Match Score",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: matchScore,
                      minHeight: 20,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        matchScore < 0.4
                            ? Colors.red
                            : matchScore < 0.7
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "${(matchScore * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Skill Analysis',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "Upload your resume and enter a job description to analyze skill match"),
                  duration: Duration(seconds: 5),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: pickResume,
                        icon: const Icon(Icons.upload_file),
                        label: Text(_resumeFile == null
                            ? "Upload Resume (PDF/DOCX)"
                            : "Resume: $_fileName"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _jobDescriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "Enter Job Description",
                          hintText: "Paste the job description here...",
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _jobDescriptionController.clear();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display job description length - now updates in real-time
                      Text(
                        "Description length: ${_jobDescriptionController.text.length} characters",
                        style: TextStyle(
                          color: _jobDescriptionController.text.length > 5000
                              ? Colors.red
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : analyzeSkills,
                              icon: _isLoading
                                  ? Container(
                                      width: 24,
                                      height: 24,
                                      padding: const EdgeInsets.all(2.0),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Icon(Icons.analytics),
                              label: Text(_isLoading
                                  ? "Analyzing..."
                                  : "Analyze Skills"),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    Colors.green.withOpacity(0.5),
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            tooltip: "More options",
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 1,
                                child: Text("Alternative Method"),
                              ),
                              const PopupMenuItem(
                                value: 2,
                                child: Text("Test Connection"),
                              ),
                              const PopupMenuItem(
                                value: 3,
                                child: Text("Clear All"),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 1) {
                                analyzeSkillsAlternative();
                              } else if (value == 2) {
                                _testConnection();
                              } else if (value == 3) {
                                setState(() {
                                  _resumeFile = null;
                                  _fileName = null;
                                  _jobDescriptionController.clear();
                                  _analysisResult = null;
                                  _errorMessage = null;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                              "Analyzing your resume against the job description..."),
                        ],
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: _buildResults(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Make sure to remove the listener before disposing the controller
    _jobDescriptionController.removeListener(_updateLength);
    _jobDescriptionController.dispose();
    super.dispose();
  }
}

// Define a timeout exception
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
