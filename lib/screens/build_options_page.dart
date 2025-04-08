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
  final List<Map<String, dynamic>> options = [
    {
      "id": 1,
      "option_name": "Contact Information",
      "description": "Your email, phone and address details",
      "image": "assets/icons/contact_detail-removebg-preview (1).png",
      "routes": "contact_info_page",
      "completed": false,
      "validator": () {
        try {
          return Global.name != null &&
              Global.name!.isNotEmpty &&
              Global.image != null;
        } catch (e) {
          return false;
        }
      },
      "required": true,
      "weight": 2.0, // Higher weight for required field
    },
    {
      "id": 2,
      "option_name": "Career Objective",
      "description": "A brief summary of your career goals",
      "image": "assets/icons/briefcase.png",
      "routes": "carrier_objective_page",
      "completed": false,
      "validator": () {
        try {
          return Global.careerObjectiveDescription != null &&
              Global.careerObjectiveDescription!.isNotEmpty;
        } catch (e) {
          return false;
        }
      },
      "required": false,
      "weight": 1.0,
    },
    {
      "id": 3,
      "option_name": "Personal Details",
      "description": "About yourself and background",
      "image": "assets/icons/prsnl_details.png",
      "routes": "personal_details_page",
      "completed": false,
      "validator": () {
        try {
          // Check if any personal details are filled
          return Global.dateOfBirth != null ||
              Global.maritalStatus != null ||
              Global.nationality != null;
        } catch (e) {
          return false;
        }
      },
      "required": false,
      "weight": 1.0,
    },
    {
      "id": 4,
      "option_name": "Education",
      "description": "Your academic qualifications",
      "image": "assets/icons/graduation-cap.png",
      "routes": "education_page",
      "completed": false,
      "validator": () {
        try {
          return Global.course != null &&
              Global.course!.isNotEmpty &&
              Global.collage != null &&
              Global.collage!.isNotEmpty;
        } catch (e) {
          return false;
        }
      },
      "required": false,
      "weight": 1.0,
    },
    {
      "id": 5,
      "option_name": "Experience",
      "description": "Your work history and responsibilities",
      "image": "assets/icons/logical-thinking.png",
      "routes": "experience_page",
      "completed": false,
      "validator": () {
        try {
          return Global.experienceCompanyName != null &&
              Global.experienceCompanyName!.isNotEmpty;
        } catch (e) {
          return false;
        }
      },
      "required": false,
      "weight": 1.0,
    },
    {
      "id": 6,
      "option_name": "Technical Skills",
      "description": "Software, tools, and technologies you know",
      "image": "assets/icons/certificate.png",
      "routes": "technical_skills_page",
      "completed": false,
      "validator": () {
        try {
          return Global.technicalSkills.isNotEmpty;
        } catch (e) {
          return false;
        }
      },
      "required": false,
      "weight": 1.0,
    },
    {
      "id": 7,
      "option_name": "Interests & Hobbies",
      "description": "Activities you enjoy outside of work",
      "image": "assets/icons/open-book.png",
      "routes": "interest_hobbies_page",
      "completed": false,
      "validator": () {
        try {
          return Global.interestHobbies.isNotEmpty;
        } catch (e) {
          return false;
        }
      },
      "required": false,
      "weight": 1.0,
    },
    {
      "id": 8,
      "option_name": "Projects",
      "description": "Key projects you've contributed to",
      "image": "assets/icons/project-management.png",
      "routes": "projects_page",
      "completed": false,
      "validator": () {
        try {
          return Global.projectTitle != null && Global.projectTitle!.isNotEmpty;
        } catch (e) {
          return false;
        }
      },
      "required": false,
      "weight": 1.0,
    },
    {
      "id": 9,
      "option_name": "Achievements",
      "description": "Awards, recognitions and accomplishments",
      "image": "assets/icons/experience.png",
      "routes": "achievement_page",
      "completed": false,
      "validator": () {
        try {
          return Global.achievement.isNotEmpty;
        } catch (e) {
          return false;
        }
      },
      "required": false,
      "weight": 1.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCompletionStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCompletionStatus();
  }

  // This function updates the completion status of each option
  void _updateCompletionStatus() {
    setState(() {
      for (var option in options) {
        Function validator = option["validator"];
        try {
          bool isCompleted = validator();
          option["completed"] = isCompleted;
        } catch (e) {
          print("Error validating ${option['option_name']}: $e");
          option["completed"] = false;
        }
      }
    });
  }

  // Calculate progress percentage taking weights into account
  double _calculateProgress() {
    double totalWeight = 0;
    double completedWeight = 0;

    for (var option in options) {
      double weight = option["weight"] ?? 1.0;
      totalWeight += weight;

      if (option["completed"] == true) {
        completedWeight += weight;
      }
    }

    // Prevent division by zero
    if (totalWeight == 0) return 0;

    return completedWeight / totalWeight;
  }

  int _completedSections() {
    return options.where((option) => option["completed"] == true).length;
  }

  // Check if basic requirements (name and photo) are met
  bool _areBasicRequirementsMet() {
    try {
      return Global.name != null &&
          Global.name!.isNotEmpty &&
          Global.image != null;
    } catch (e) {
      return false;
    }
  }

  String _getMissingBasicRequirements() {
    List<String> missing = [];

    try {
      if (Global.name == null || Global.name!.isEmpty) {
        missing.add("Name");
      }

      if (Global.image == null) {
        missing.add("Photo");
      }
    } catch (e) {
      // If there's an error, assume both are missing
      return "Name and Photo";
    }

    return missing.join(' and ');
  }

  void _navigateToResumeTemplates() {
    if (_areBasicRequirementsMet()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResumeTemplateSelector()),
      ).then((_) {
        _updateCompletionStatus();
      });
    } else {
      // Show error for missing basic requirements
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Please add your ${_getMissingBasicRequirements()} in Contact Information"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'GO TO CONTACT',
          onPressed: () {
            Navigator.of(context).pushNamed("contact_info_page");
          },
        ),
      ));
    }
  }

  void _navigateToSection(String route) {
    Navigator.of(context).pushNamed(route).then((_) {
      // Important: Update completion status when returning from a section
      _updateCompletionStatus();
    });
  }

  // Get status message based on completion status
  String _getStatusMessage() {
    double progress = _calculateProgress();

    if (!_areBasicRequirementsMet()) {
      return "Add your ${_getMissingBasicRequirements()} to generate resume";
    } else if (progress < 0.3) {
      return "Getting started! Add more details";
    } else if (progress < 0.6) {
      return "Making good progress! Keep going";
    } else if (progress < 1.0) {
      return "Almost there! Add final details";
    } else {
      return "All sections complete! Ready to generate";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xff2c8cfb);
    final accentColor = themeColor.withOpacity(0.1);
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate progress percentage for the progress bar
    final double progressPercentage = _calculateProgress();

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
                          value:
                              progressPercentage, // Use calculated percentage
                          backgroundColor: Colors.white.withOpacity(0.3),
                          color: Colors.white,
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "${(progressPercentage * 100).toInt()}%", // Show percentage
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getStatusMessage(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "${_completedSections()}/${options.length} sections",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                final bool isRequired = option["required"] == true;

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
                            : isRequired
                                ? Colors.orange.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.2),
                        width: option["completed"] == true ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _navigateToSection(option["routes"]),
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
                                  Row(
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
                                      if (isRequired)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: option["completed"] == true
                                                  ? themeColor.withOpacity(0.1)
                                                  : Colors.orange
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "Required",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color:
                                                    option["completed"] == true
                                                        ? themeColor
                                                        : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
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
        onPressed: _navigateToResumeTemplates,
      ),
    );
  }
}
