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

class ModernMinimalistResume extends StatefulWidget {
  ModernMinimalistResume({Key? key}) : super(key: key);

  @override
  State<ModernMinimalistResume> createState() => _ModernMinimalistResumeState();
}

class _ModernMinimalistResumeState extends State<ModernMinimalistResume> {
  final pdf = pw.Document();

  // Color scheme
  Color primaryColor = const Color(0xff4A90E2);
  Color textColor = const Color(0xff333333);
  Color accentColor = const Color(0xffF5F5F5);

  late final pw.MemoryImage? profileImage;

  @override
  void initState() {
    super.initState();

    profileImage = Global.image != null
        ? pw.MemoryImage(File(Global.image!.path).readAsBytesSync())
        : null;

    buildPdf();
  }

  // Text styles for PDF document
  final headingStylePw = pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey800,
  );

  final subheadingStylePw = pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue700,
  );

  final sectionTitleStylePw = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue700,
    letterSpacing: 1.2,
  );

  final contentTitleStylePw = pw.TextStyle(
    fontSize: 13,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey800,
  );

  final contentStylePw = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.blueGrey800,
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
              // Header section with name, title and contact info
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 15),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Profile photo if available
                    if (profileImage != null)
                      pw.Container(
                        width: 90,
                        height: 90,
                        margin: const pw.EdgeInsets.only(right: 15),
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColors.grey200,
                        ),
                        child: pw.ClipOval(
                          child: pw.Image(profileImage!, fit: pw.BoxFit.cover),
                        ),
                      ),

                    // Name and title
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (Global.name != null)
                            pw.Text(
                              Global.name!.toUpperCase(),
                              style: headingStylePw,
                            ),
                          pw.SizedBox(height: 4),
                          if (Global.careerObjectiveExperienced != null)
                            pw.Text(
                              Global.careerObjectiveExperienced!,
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.grey700,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Contact information
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        if (Global.email != null)
                          pw.Text(Global.email!, style: contentStylePw),
                        if (Global.phone != null)
                          pw.Text(Global.phone!, style: contentStylePw),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Divider(color: PdfColors.blue700, thickness: 1),
              pw.SizedBox(height: 15),

              // Two-column layout for the rest of the content
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left column (65% width)
                  pw.Expanded(
                    flex: 65,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Profile section
                        if (Global.careerObjectiveDescription != null) ...[
                          pw.Text("PROFILE", style: sectionTitleStylePw),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            Global.careerObjectiveDescription!,
                            style: contentStylePw,
                          ),
                          pw.SizedBox(height: 15),
                        ],

                        // Experience section
                        if (Global.experienceCompanyName != null) ...[
                          pw.Text("PROFESSIONAL EXPERIENCE",
                              style: sectionTitleStylePw),
                          pw.SizedBox(height: 10),
                          buildExperienceSection(),
                          pw.SizedBox(height: 15),
                        ],

                        // Projects section
                        if (Global.projectTitle != null) ...[
                          buildProjectsSection(),
                          pw.SizedBox(height: 15),
                        ],

                        // Achievements section
                        if (Global.achievement.isNotEmpty) ...[
                          buildAchievementsSection(),
                        ],
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 20),

                  // Right column (35% width)
                  pw.Expanded(
                    flex: 35,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Education section
                        if (Global.course != null ||
                            Global.collage != null) ...[
                          pw.Text("EDUCATION", style: sectionTitleStylePw),
                          pw.SizedBox(height: 10),
                          buildEducationSection(),
                          pw.SizedBox(height: 15),
                        ],

                        // Skills section
                        if (Global.technicalSkills.isNotEmpty) ...[
                          pw.Text("SKILLS", style: sectionTitleStylePw),
                          pw.SizedBox(height: 10),
                          buildSkillsSection(),
                          pw.SizedBox(height: 15),
                        ],

                        // Languages section
                        if (Global.englishCheckBox ||
                            Global.hindiCheckBox ||
                            Global.gujratiCheckBox) ...[
                          pw.Text("LANGUAGES", style: sectionTitleStylePw),
                          pw.SizedBox(height: 10),
                          buildLanguagesSection(),
                          pw.SizedBox(height: 15),
                        ],

                        // References section
                        if (Global.referenceName != null) ...[
                          pw.Text("REFERENCES", style: sectionTitleStylePw),
                          pw.SizedBox(height: 10),
                          buildReferencesSection(),
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
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    Global.experienceCollage ?? "",
                    style: contentTitleStylePw,
                  ),
                  if (Global.experienceJoinDate != null &&
                      Global.experienceExitDate != null)
                    pw.Text(
                      "${Global.experienceJoinDate} - ${Global.experienceExitDate}",
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                ],
              ),
              pw.Text(
                Global.experienceCompanyName ?? "",
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
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

  pw.Widget buildProjectsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("PROJECTS", style: sectionTitleStylePw),
        pw.SizedBox(height: 10),
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                Global.projectTitle ?? "",
                style: contentTitleStylePw,
              ),
              pw.SizedBox(height: 3),
              if (Global.projectDescription != null)
                pw.Text(
                  Global.projectDescription!,
                  style: contentStylePw,
                ),
              pw.SizedBox(height: 5),
              pw.Text(
                "Role: ${Global.projectRoles ?? ""}",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                "Technologies:",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
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
        ),
      ],
    );
  }

  pw.Widget buildTechPill(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  pw.Widget buildAchievementsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("ACHIEVEMENTS", style: sectionTitleStylePw),
        pw.SizedBox(height: 10),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: Global.achievement.map((achievement) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("•", style: contentStylePw),
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                    child: pw.Text(
                      achievement,
                      style: contentStylePw,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget buildEducationSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    Global.course ?? "",
                    style: contentTitleStylePw,
                  ),
                  if (Global.passYear != null)
                    pw.Text(
                      Global.passYear!,
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                ],
              ),
              pw.Text(
                Global.collage ?? "",
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget buildSkillsSection() {
    return pw.Wrap(
      spacing: 5,
      runSpacing: 5,
      children: Global.technicalSkills.map((skill) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(
            skill,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey800,
            ),
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

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: languages.map((language) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text(
            "• $language",
            style: contentStylePw,
          ),
        );
      }).toList(),
    );
  }

  pw.Widget buildReferencesSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          Global.referenceName ?? "",
          style: contentTitleStylePw,
        ),
        pw.Text(
          "${Global.referenceDesignation ?? ""}, ${Global.referenceOrganization ?? ""}",
          style: contentStylePw,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: const Text("Modern Minimalist Resume"),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: () async {
              Directory? dir = await getExternalStorageDirectory();
              File file = File("${dir!.path}/modern_minimalist_resume.pdf");
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
