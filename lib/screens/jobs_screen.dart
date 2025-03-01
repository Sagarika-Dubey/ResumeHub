import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../services/job_service.dart';
import 'package:url_launcher/url_launcher.dart';

class JobsScreen extends StatefulWidget {
  @override
  _JobsScreenState createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final JobApisService _jobService = JobApisService();
  List<dynamic> _jobs = [];
  bool _isLoading = false;
  bool _noJobsFound = false;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _noJobsFound = false;
    });

    try {
      List<dynamic> jobs = await _jobService.fetchJobs(
        query: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : "developer",
        location: _locationController.text.trim(),
      );

      setState(() {
        _jobs = jobs;
        _isLoading = false;
        _noJobsFound = jobs.isEmpty;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _noJobsFound = true;
      });
      print("Error fetching jobs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Recommendations")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: "Enter Job Role"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration:
                  InputDecoration(labelText: "Enter Location (Optional)"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchJobs,
              child: Text("Find Jobs"),
            ),
            if (_isLoading) Center(child: CircularProgressIndicator()),
            if (_noJobsFound)
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "No jobs found. Try another keyword or location.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  var job = _jobs[index];
                  return Card(
                    child: ListTile(
                      title: Text(job['title'] ?? "No Title"),
                      subtitle: Text(job['company_name'] ?? "No Company"),
                      trailing: Icon(Icons.open_in_new),
                      onTap: () => _openJobUrl(job['url']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openJobUrl(String? url) async {
    if (url == null || url.isEmpty) {
      print("Invalid URL");
      return;
    }

    Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }
}
