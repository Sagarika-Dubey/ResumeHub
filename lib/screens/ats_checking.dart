import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class ResumeScreen extends StatefulWidget {
  @override
  _ResumeScreenState createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  File? selectedFile;
  String result = "Upload a resume to analyze and check ATS score";
  bool isLoading = false;
  Map<String, dynamic>? analysisResult;

  Future<void> pickFileAndUpload() async {
    setState(() {
      isLoading = true;
    });

    FilePickerResult? pickedResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (pickedResult != null && pickedResult.files.isNotEmpty) {
      setState(() {
        selectedFile = File(pickedResult.files.single.path!);
      });

      try {
        var response = await uploadResume(selectedFile!);
        setState(() {
          isLoading = false;
          analysisResult = response;

          var ats = response['ats'];
          var sections = response['sections'];
          var summary = response['summary'];

          result = """
## Resume Analysis Results

### Overall Score: ${summary?['score'] ?? 'N/A'}/100

### ATS Compatibility
- **Score**: ${ats?['score'] ?? 'N/A'}/100
- **Pass Likelihood**: ${ats?['passLikelihood'] ?? 'N/A'}
- **Likely Industry**: ${ats?['likely_industry'] ?? 'N/A'}

### Strengths
${summary?['strengths']?.map((s) => "- $s").join('\n') ?? '- None identified'}

### Areas for Improvement
${summary?['weaknesses']?.map((s) => "- $s").join('\n') ?? '- None identified'}

### Section Scores
- **Format**: ${sections?['format']?['score'] ?? 'N/A'}/100
- **Contact Info**: ${sections?['contact']?['score'] ?? 'N/A'}/100
- **Skills**: ${sections?['skills']?['score'] ?? 'N/A'}/100
- **Experience**: ${sections?['experience']?['score'] ?? 'N/A'}/100
- **Education**: ${sections?['education']?['score'] ?? 'N/A'}/100

### Keywords
**Found Industry Keywords**: ${ats?['industry_keywords_found']?.join(', ') ?? 'None'}

**Missing Keywords**: ${ats?['missing_keywords']?.join(', ') ?? 'None'}

### Technical Skills
${sections?['skills']?['technical_skills']?.join(', ') ?? 'None identified'}

### Soft Skills
${sections?['skills']?['soft_skills']?.join(', ') ?? 'None identified'}

### Recommendations
${ats?['suggestions']?.map((s) => "- $s").join('\n') ?? 'No suggestions'}

${sections?['experience']?['suggestions']?.map((s) => "- $s").join('\n') ?? ''}
""";
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          result = "Error: ${e.toString()}";
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print("❌ No file selected");
    }
  }

  Future<Map<String, dynamic>> uploadResume(File file) async {
    final String apiUrl =
        "http://192.168.0.227:5000/api/analyze"; // Replace with your Flask server IP

    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath("resume", file.path));

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

  // Completely redesigned score card widget
  Widget _buildScoreCard(String title, int score, String detail) {
    final Color color =
        score >= 80 ? Colors.green : (score >= 60 ? Colors.orange : Colors.red);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            Divider(height: 16),

            // Score row - simplified layout
            Row(
              children: [
                // Score number with color
                Text(
                  "$score",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  "/100",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                Spacer(),

                // Small indicator
                Container(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 4,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Detail text at bottom
            Text(
              detail,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDashboard() {
    if (analysisResult == null) return SizedBox();

    var summary = analysisResult!['summary'];
    var ats = analysisResult!['ats'];
    var sections = analysisResult!['sections'];

    return Column(
      children: [
        // Overall Score card
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Overall Resume Score",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    // Score with color - Wrapped in Expanded to prevent overflow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "${summary['score']}",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: summary['score'] >= 80
                                      ? Colors.green
                                      : (summary['score'] >= 60
                                          ? Colors.orange
                                          : Colors.red),
                                ),
                              ),
                              Text(
                                "/100",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          // Added constraints to ensure text wrapping
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 220),
                            child: Text(
                              "Based on format, content and ATS compatibility",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                        width: 8), // Added spacing between text and indicator

                    // Circular indicator
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: summary['score'] / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          summary['score'] >= 80
                              ? Colors.green
                              : (summary['score'] >= 60
                                  ? Colors.orange
                                  : Colors.red),
                        ),
                        strokeWidth: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Rest of the code remains the same
        SizedBox(height: 16),

        // Section scores in a grid
        LayoutBuilder(builder: (context, constraints) {
          return GridView.extent(
            maxCrossAxisExtent: 180,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildScoreCard("ATS Score", ats['score'],
                  ats['passLikelihood'] + " pass likelihood"),
              _buildScoreCard("Skills", sections['skills']['score'],
                  "${sections['skills']['technical_skills'].length} technical skills"),
              _buildScoreCard("Experience", sections['experience']['score'],
                  "${sections['experience']['action_verbs']} action verbs"),
              _buildScoreCard("Education", sections['education']['score'],
                  sections['education']['feedback']),
            ],
          );
        }),

        SizedBox(height: 24),

        // Strengths and Weaknesses
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Resume Analysis",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Strengths",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (summary['strengths'] as List)
                      .map((strength) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 18),
                                SizedBox(width: 8),
                                Expanded(child: Text(strength)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 16),
                Text(
                  "Areas for Improvement",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (summary['weaknesses'] as List)
                      .map((weakness) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.priority_high,
                                    color: Colors.orange, size: 18),
                                SizedBox(width: 8),
                                Expanded(child: Text(weakness)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Resume ATS Analyzer",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Color(0xFF6E8EFB),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Upload section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 60,
                          color: Color(0xFF6E8EFB),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Resume ATS Score Checker",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Upload your resume to analyze its ATS compatibility and get detailed feedback",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 24),
                        selectedFile != null
                            ? Row(
                                children: [
                                  Icon(Icons.description, color: Colors.indigo),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedFile!.path.split('/').last,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : pickFileAndUpload,
                          icon: Icon(
                            Icons.upload_file,
                            color: Colors.white,
                          ),
                          label: Text(
                            selectedFile == null
                                ? "Select Resume PDF"
                                : "Analyze Resume",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Loading indicator
                if (isLoading)
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Analyzing your resume..."),
                      ],
                    ),
                  ),

                // Result section
                if (!isLoading && analysisResult != null)
                  _buildResultDashboard(),

                // Detailed Markdown result
                if (!isLoading && analysisResult != null)
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.only(top: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Detailed Results",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Divider(),
                          Container(
                            height: 400,
                            child: Markdown(
                              data: result,
                              shrinkWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
