import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:resumehub/globals.dart';
import 'package:resumehub/screens/backButton.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CreativeGridResume extends StatefulWidget {
  CreativeGridResume({Key? key}) : super(key: key);

  @override
  State<CreativeGridResume> createState() => _CreativeGridResumeState();
}

class _CreativeGridResumeState extends State<CreativeGridResume> {
  final pdf = pw.Document();

  // Color scheme
  Color primaryColor = const Color(0xff6200EA);
  Color accentColor = const Color(0xff03DAC6);

  late final pw.MemoryImage? profileImage;

  @override
  void initState() {
    super.initState();

    profileImage = Global.image != null
        ? pw.MemoryImage(File(Global.image!.path).readAsBytesSync())
        : null;

    buildPdf();
  }

  // PDF text styles
  final nameStylePw = pw.TextStyle(
    fontSize: 28,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.deepPurple800,
  );

  final titleStylePw = pw.TextStyle(
    fontSize: 16,
    color: PdfColors.grey700,
  );

  final sectionTitleStylePw = pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.deepPurple800,
  );

  final contentTitleStylePw = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.grey800,
  );

  final contentStylePw = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.grey800,
  );

  final highlightStylePw = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.deepPurple800,
    fontWeight: pw.FontWeight.bold,
  );

  void buildPdf() {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with color accent, name and photo
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(
                      color: PdfColors.deepPurple200,
                      width: 2,
                    ),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Accent color bar
                    pw.Container(
                      width: 15,
                      height: 100,
                      color: PdfColors.deepPurple800,
                      margin: const pw.EdgeInsets.only(right: 20),
                    ),

                    // Name and title
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (Global.name != null)
                            pw.Text(
                              Global.name!.toUpperCase(),
                              style: nameStylePw,
                            ),
                          pw.SizedBox(height: 5),
                          if (Global.careerObjectiveExperienced != null)
                            pw.Text(
                              Global.careerObjectiveExperienced!,
                              style: titleStylePw,
                            ),
                          pw.SizedBox(height: 10),
                          // Contact info
                          pw.Row(
                            children: [
                              if (Global.email != null) ...[
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.deepPurple50,
                                    borderRadius: pw.BorderRadius.circular(4),
                                  ),
                                  child: pw.Text(
                                    Global.email!,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.deepPurple800,
                                    ),
                                  ),
                                ),
                                pw.SizedBox(width: 10),
                              ],
                              if (Global.phone != null) ...[
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.deepPurple50,
                                    borderRadius: pw.BorderRadius.circular(4),
                                  ),
                                  child: pw.Text(
                                    Global.phone!,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.deepPurple800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Profile photo
                    if (profileImage != null)
                      pw.Container(
                        width: 100,
                        height: 100,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(
                            color: PdfColors.deepPurple200,
                            width: 3,
                          ),
                        ),
                        child: pw.ClipOval(
                          child: pw.Image(profileImage!, fit: pw.BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Main content grid (2 columns)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left column (60% width)
                  pw.Expanded(
                    flex: 60,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 15),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Profile section
                          if (Global.careerObjectiveDescription != null) ...[
                            pw.Container(
                              padding: const pw.EdgeInsets.only(bottom: 10),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.deepPurple200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    "PROFILE",
                                    style: sectionTitleStylePw,
                                  ),
                                  pw.SizedBox(height: 10),
                                  pw.Text(
                                    Global.careerObjectiveDescription!,
                                    style: contentStylePw,
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 20),
                          ],

                          // Experience section
                          if (Global.experienceCompanyName != null) ...[
                            pw.Container(
                              padding: const pw.EdgeInsets.only(bottom: 10),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.deepPurple200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    "EXPERIENCE",
                                    style: sectionTitleStylePw,
                                  ),
                                  pw.SizedBox(height: 10),
                                  buildExperienceSection(),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 20),
                          ],

                          // Projects section
                          if (Global.projectTitle != null) ...[
                            pw.Container(
                              padding: const pw.EdgeInsets.only(bottom: 10),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.deepPurple200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    "PROJECTS",
                                    style: sectionTitleStylePw,
                                  ),
                                  pw.SizedBox(height: 10),
                                  buildProjectsSection(),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Right column (40% width)
                  pw.Expanded(
                    flex: 40,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Education section
                        if (Global.course != null ||
                            Global.collage != null) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            decoration: pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(
                                  color: PdfColors.deepPurple200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "EDUCATION",
                                  style: sectionTitleStylePw,
                                ),
                                pw.SizedBox(height: 10),
                                buildEducationSection(),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 20),
                        ],

                        // Skills section with visual indicators
                        if (Global.technicalSkills.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            decoration: pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(
                                  color: PdfColors.deepPurple200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "SKILLS",
                                  style: sectionTitleStylePw,
                                ),
                                pw.SizedBox(height: 10),
                                buildSkillsSection(),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 20),
                        ],

                        // Languages section
                        if (Global.englishCheckBox ||
                            Global.hindiCheckBox ||
                            Global.gujratiCheckBox) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            decoration: pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(
                                  color: PdfColors.deepPurple200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "LANGUAGES",
                                  style: sectionTitleStylePw,
                                ),
                                pw.SizedBox(height: 10),
                                buildLanguagesSection(),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 20),
                        ],

                        // Achievements section
                        if (Global.achievement.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            decoration: pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(
                                  color: PdfColors.deepPurple200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "ACHIEVEMENTS",
                                  style: sectionTitleStylePw,
                                ),
                                pw.SizedBox(height: 10),
                                buildAchievementsSection(),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 20),
                        ],

                        // References section
                        if (Global.referenceName != null) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "REFERENCES",
                                  style: sectionTitleStylePw,
                                ),
                                pw.SizedBox(height: 10),
                                buildReferencesSection(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  pw.Widget buildExperienceSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      Global.experienceCollage ?? "",
                      style: contentTitleStylePw,
                    ),
                  ),
                  if (Global.experienceJoinDate != null &&
                      Global.experienceExitDate != null)
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.deepPurple100,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Text(
                        "${Global.experienceJoinDate} - ${Global.experienceExitDate}",
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.deepPurple800,
                        ),
                      ),
                    ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                Global.experienceCompanyName ?? "",
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.deepPurple800,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 5),
              if (Global.experienceRole != null &&
                  Global.experienceRole!.isNotEmpty)
                pw.Text(
                  "• ${Global.experienceRole}",
                  style: contentStylePw,
                ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget buildEducationSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  Global.course ?? "",
                  style: contentTitleStylePw,
                ),
              ),
              if (Global.passYear != null)
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.deepPurple100,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    Global.passYear!,
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.deepPurple800,
                    ),
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            Global.collage ?? "",
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.deepPurple800,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget buildSkillsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: Global.technicalSkills.map((skill) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                skill,
                style: contentStylePw,
              ),
              pw.SizedBox(height: 3),
              pw.Container(
                height: 6,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 80, // Fixed width for skill level indicator
                      decoration: pw.BoxDecoration(
                        color: PdfColors.deepPurple400,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget buildProjectsSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            Global.projectTitle ?? "",
            style: contentTitleStylePw,
          ),
          pw.SizedBox(height: 5),
          if (Global.projectDescription != null)
            pw.Text(
              Global.projectDescription!,
              style: contentStylePw,
            ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text(
                "Role: ",
                style: highlightStylePw,
              ),
              pw.Text(
                Global.projectRoles ?? "",
                style: contentStylePw,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            "Technologies:",
            style: highlightStylePw,
          ),
          pw.SizedBox(height: 5),
          pw.Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              if (Global.projectCheckBoxCProgramming == true)
                buildTechPill("C Programming"),
              if (Global.projectCheckBoxCPP == true) buildTechPill("C++"),
              if (Global.projectCheckBoxFlutter == true)
                buildTechPill("Flutter"),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget buildTechPill(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.deepPurple100,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.deepPurple800,
        ),
      ),
    );
  }

  pw.Widget buildAchievementsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: Global.achievement.map((achievement) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 5),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Text(
            achievement,
            style: contentStylePw,
          ),
        );
      }).toList(),
    );
  }

  pw.Widget buildLanguagesSection() {
    List<String> languages = [];

    if (Global.englishCheckBox) languages.add("English");
    if (Global.hindiCheckBox) languages.add("Hindi");
    if (Global.gujratiCheckBox) languages.add("Gujarati");

    return pw.Wrap(
      spacing: 5,
      runSpacing: 5,
      children: languages.map((language) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColors.deepPurple100,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Text(
            language,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.deepPurple800,
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget buildReferencesSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            Global.referenceName ?? "",
            style: contentTitleStylePw,
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            "${Global.referenceDesignation ?? ""}, ${Global.referenceOrganization ?? ""}",
            style: contentStylePw,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: const Text("Creative Grid Resume"),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: () async {
              Directory? dir = await getExternalStorageDirectory();
              File file = File("${dir!.path}/creative_grid_resume.pdf");
              await file.writeAsBytes(await pdf.save());

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("PDF Saved Successfully"),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: "Open",
                    onPressed: () async {
                      await OpenFile.open(file.path);
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              Uint8List bytes = await pdf.save();
              await Printing.layoutPdf(onLayout: (format) => bytes);
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdf.save(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }
}
