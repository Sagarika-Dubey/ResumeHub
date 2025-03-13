import 'package:flutter/material.dart';
import '../services/job_service.dart';

class JobSearchScreen extends StatefulWidget {
  @override
  _JobSearchScreenState createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final JobSearchService jobService = JobSearchService();
  final TextEditingController skillController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  Future<List<dynamic>>? jobs;

  void searchJobs() {
    setState(() {
      jobs =
          jobService.fetchJobs(skillController.text, locationController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: skillController,
              decoration: InputDecoration(
                labelText: "Enter Job Skill",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: "Enter Location",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: searchJobs,
              child: Text("Search Jobs"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: jobs == null
                  ? Center(child: Text("Enter details to search for jobs"))
                  : FutureBuilder<List<dynamic>>(
                      future: jobs,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text("No jobs found"));
                        }

                        final jobList = snapshot.data!;
                        return ListView.builder(
                          itemCount: jobList.length,
                          itemBuilder: (context, index) {
                            final job = jobList[index];
                            return Card(
                              child: ListTile(
                                title: Text(job["title"] ?? "N/A"),
                                subtitle: Text(job["company"] ?? "Unknown"),
                                trailing: Text(job["location"] ?? "Anywhere"),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
