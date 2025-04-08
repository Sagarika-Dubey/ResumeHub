import 'package:flutter/material.dart';
import 'package:resumehub/screens/resume_templatescreen.dart';
import '../globals.dart';
import 'backButton.dart';

class Build_Options_Page extends StatefulWidget {
  const Build_Options_Page({Key? key}) : super(key: key);

  @override
  State<Build_Options_Page> createState() => _Build_Options_PageState();
}

class _Build_Options_PageState extends State<Build_Options_Page> {
  final List<Map> options = [
    {
      "id": 1,
      "option_name": "Contact Information",
      "description": "Your email, phone and address details",
      "image": "assets/icons/contact_detail-removebg-preview (1).png",
      "routes": "contact_info_page",
      "completed": false,
    },
    {
      "id": 2,
      "option_name": "Career Objective",
      "description": "A brief summary of your career goals",
      "image": "assets/icons/briefcase.png",
      "routes": "carrier_objective_page",
      "completed": false,
    },
    {
      "id": 3,
      "option_name": "Personal Details",
      "description": "About yourself and background",
      "image": "assets/icons/prsnl_details.png",
      "routes": "personal_details_page",
      "completed": false,
    },
    {
      "id": 4,
      "option_name": "Education",
      "description": "Your academic qualifications",
      "image": "assets/icons/graduation-cap.png",
      "routes": "education_page",
      "completed": false,
    },
    {
      "id": 5,
      "option_name": "Experience",
      "description": "Your work history and responsibilities",
      "image": "assets/icons/logical-thinking.png",
      "routes": "experience_page",
      "completed": false,
    },
    {
      "id": 6,
      "option_name": "Technical Skills",
      "description": "Software, tools, and technologies you know",
      "image": "assets/icons/certificate.png",
      "routes": "technical_skills_page",
      "completed": false,
    },
    {
      "id": 7,
      "option_name": "Interests & Hobbies",
      "description": "Activities you enjoy outside of work",
      "image": "assets/icons/open-book.png",
      "routes": "interest_hobbies_page",
      "completed": false,
    },
    {
      "id": 8,
      "option_name": "Projects",
      "description": "Key projects you've contributed to",
      "image": "assets/icons/project-management.png",
      "routes": "projects_page",
      "completed": false,
    },
    {
      "id": 9,
      "option_name": "Achievements",
      "description": "Awards, recognitions and accomplishments",
      "image": "assets/icons/experience.png",
      "routes": "achievement_page",
      "completed": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Update completion status based on Global data
    _updateCompletionStatus();
  }

  void _updateCompletionStatus() {
    // This is a placeholder - you would check Global data to see if sections are completed
    // For example: options[0]["completed"] = Global.contactInfo != null;
  }

  int _completedSections() {
    return options.where((option) => option["completed"] == true).length;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xff2c8cfb);
    final accentColor = themeColor.withOpacity(0.1);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        backgroundColor: themeColor,
        title: const Text(
          "Resume Builder",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Tooltip(
            message: "Generate PDF",
            child: InkWell(
              onTap: () {
                if (Global.image != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResumeTemplateSelector()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please add a profile image first"),
                    behavior: SnackBarBehavior.floating,
                  ));
                  Navigator.of(context).pushNamed("contact_info_page");
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.picture_as_pdf),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Header section with progress indicator
          Container(
            width: screenWidth,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            color: themeColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Resume Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _completedSections() / options.length,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          color: Colors.white,
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "${_completedSections()}/${options.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Complete all sections for a comprehensive resume",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Options list
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: option["completed"] == true
                            ? themeColor
                            : Colors.grey.withOpacity(0.2),
                        width: option["completed"] == true ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(option["routes"]);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                option["image"],
                                height: 30,
                                color: themeColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option["option_name"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: option["completed"] == true
                                          ? themeColor
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option["description"],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            option["completed"] == true
                                ? Icon(Icons.check_circle, color: themeColor)
                                : Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Colors.grey[400],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        child: const Icon(Icons.picture_as_pdf),
        onPressed: () {
          if (Global.image != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResumeTemplateSelector()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Please add a profile image first"),
              behavior: SnackBarBehavior.floating,
            ));
            Navigator.of(context).pushNamed("contact_info_page");
          }
        },
      ),
    );
  }
}
