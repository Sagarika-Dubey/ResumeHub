import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../globals.dart';
import '../backButton.dart';

class personal_details_page extends StatefulWidget {
  const personal_details_page({Key? key}) : super(key: key);

  @override
  State<personal_details_page> createState() => _personal_details_pageState();
}

class _personal_details_pageState extends State<personal_details_page> {
  final Color myColor = const Color(0xff0475FF);
  final TextStyle sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: const Color(0xff0475FF).withOpacity(0.8),
  );

  final GlobalKey<FormState> personalDetailsFormKey = GlobalKey<FormState>();

  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController languageController = TextEditingController();

  // For handling form state
  List<String> customLanguages = [];
  bool formChanged = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if available
    dateOfBirthController.text = Global.dateOfBirth ?? '';
    nationalityController.text = Global.nationality ?? '';

    // Initialize custom languages if available
    if (Global.customLanguages != null && Global.customLanguages!.isNotEmpty) {
      customLanguages = List<String>.from(Global.customLanguages!);
    }

    // Add listeners to track form changes
    dateOfBirthController.addListener(_markFormChanged);
    nationalityController.addListener(_markFormChanged);
  }

  @override
  void dispose() {
    // Clean up controllers
    dateOfBirthController.removeListener(_markFormChanged);
    nationalityController.removeListener(_markFormChanged);
    dateOfBirthController.dispose();
    nationalityController.dispose();
    languageController.dispose();
    super.dispose();
  }

  void _markFormChanged() {
    if (!formChanged) {
      setState(() {
        formChanged = true;
      });
    }
  }

  // Function to show date picker with improved handling
  Future<void> _selectDate(BuildContext context) async {
    // Get current date for validating age
    final DateTime now = DateTime.now();

    // Parse existing date if available
    DateTime initialDate;
    try {
      if (dateOfBirthController.text.isNotEmpty) {
        List<String> parts = dateOfBirthController.text.split('/');
        initialDate = DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      } else {
        // Default to 18 years ago
        initialDate = DateTime(now.year - 18, now.month, now.day);
      }
    } catch (e) {
      // If parsing fails, use default date
      initialDate = DateTime(now.year - 18, now.month, now.day);
    }

    // Ensure initialDate is within the valid range
    if (initialDate.isAfter(now)) {
      initialDate = DateTime(now.year - 18, now.month, now.day);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: myColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
        formChanged = true;
      });
    }
  }

  // Function to add a custom language with validation
  void _addLanguage() {
    String language = languageController.text.trim();
    if (language.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a language name")),
      );
      return;
    }

    // Check for duplicates
    if (customLanguages.contains(language) ||
        (language.toLowerCase() == "english" && Global.englishCheckBox) ||
        (language.toLowerCase() == "hindi" && Global.hindiCheckBox) ||
        (language.toLowerCase() == "gujarati" && Global.gujratiCheckBox)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This language is already added")),
      );
      return;
    }

    setState(() {
      customLanguages.add(language);
      languageController.clear();
      formChanged = true;
    });
  }

  // Function to remove a language
  void _removeLanguage(int index) {
    setState(() {
      customLanguages.removeAt(index);
      formChanged = true;
    });
  }

  // Show unsaved changes dialog
  Future<bool> _onWillPop() async {
    if (!formChanged) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: backButton(context),
          backgroundColor: myColor,
          title: const Text("Personal Details"),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: width,
                alignment: const Alignment(0, 0.5),
                color: myColor,
              ),
            ),
            Expanded(
              flex: 18,
              child: Container(
                color: const Color(0xffEDEDED),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20, top: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: personalDetailsFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date of Birth Section
                                _buildSectionHeader("Date of Birth", height),
                                TextFormField(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please enter your date of birth";
                                    }
                                    // Date format validation
                                    RegExp dateRegex =
                                        RegExp(r'^\d{2}/\d{2}/\d{4}$');
                                    if (!dateRegex.hasMatch(val)) {
                                      return "Please use DD/MM/YYYY format";
                                    }

                                    // Basic date validation
                                    try {
                                      List<String> parts = val.split('/');
                                      int day = int.parse(parts[0]);
                                      int month = int.parse(parts[1]);
                                      int year = int.parse(parts[2]);

                                      if (day < 1 ||
                                          day > 31 ||
                                          month < 1 ||
                                          month > 12) {
                                        return "Please enter a valid date";
                                      }

                                      // Check if year is within reasonable range
                                      int currentYear = DateTime.now().year;
                                      if (year < 1940 || year > currentYear) {
                                        return "Year should be between 1940 and $currentYear";
                                      }
                                    } catch (e) {
                                      return "Please enter a valid date";
                                    }

                                    return null;
                                  },
                                  onSaved: (val) {
                                    setState(() {
                                      Global.dateOfBirth = val;
                                    });
                                  },
                                  readOnly: true,
                                  controller: dateOfBirthController,
                                  onTap: () => _selectDate(context),
                                  decoration: InputDecoration(
                                    hintText: "DD/MM/YYYY",
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.calendar_today),
                                      onPressed: () => _selectDate(context),
                                      color: myColor,
                                    ),
                                    fillColor: Colors.grey.shade50,
                                    filled: true,
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // Custom Languages Section
                                _buildSectionHeader("Add Languages", height),

                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: languageController,
                                        decoration: InputDecoration(
                                          hintText: "Enter language",
                                          border: const OutlineInputBorder(),
                                          fillColor: Colors.grey.shade50,
                                          filled: true,
                                        ),
                                        textCapitalization:
                                            TextCapitalization.words,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: _addLanguage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: myColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        minimumSize: const Size(80, 48),
                                      ),
                                      child: const Text("Add",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),

                                // Display custom languages with remove option
                                if (customLanguages.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(3)),
                                          ),
                                          child: const Text(
                                            "Custom Languages",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: customLanguages.length,
                                          separatorBuilder: (context, index) =>
                                              Divider(
                                                  height: 1,
                                                  color: Colors.grey.shade300),
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title:
                                                  Text(customLanguages[index]),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _removeLanguage(index),
                                              ),
                                              dense: true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 25),

                                // Nationality Section
                                _buildSectionHeader("Nationality", height),
                                TextFormField(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please enter your nationality";
                                    }
                                    return null;
                                  },
                                  onSaved: (val) {
                                    setState(() {
                                      Global.nationality = val;
                                    });
                                  },
                                  controller: nationalityController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintText: "Indian",
                                    border: const OutlineInputBorder(),
                                    fillColor: Colors.grey.shade50,
                                    filled: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Action Buttons
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (personalDetailsFormKey.currentState!
                                      .validate()) {
                                    personalDetailsFormKey.currentState!.save();
                                    // Save custom languages
                                    Global.customLanguages = customLanguages;
                                    setState(() {
                                      formChanged = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Personal details saved successfully"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: myColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text("Save",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  personalDetailsFormKey.currentState!.reset();
                                  dateOfBirthController.clear();
                                  nationalityController.clear();
                                  languageController.clear();
                                  setState(() {
                                    Global.dateOfBirth = null;

                                    Global.nationality = null;
                                    Global.englishCheckBox = false;
                                    Global.hindiCheckBox = false;
                                    Global.gujratiCheckBox = false;
                                    customLanguages.clear();
                                    Global.customLanguages = [];
                                    formChanged = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Form cleared")),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text("Clear",
                                    style: TextStyle(color: Colors.black87)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent section headers
  Widget _buildSectionHeader(String title, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: sectionTitleStyle),
        SizedBox(height: height * 0.01),
      ],
    );
  }
}
