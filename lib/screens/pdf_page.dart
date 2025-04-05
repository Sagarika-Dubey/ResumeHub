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

class PDF_Page extends StatefulWidget {
  PDF_Page({Key? key}) : super(key: key);

  @override
  State<PDF_Page> createState() => _PDF_PageState();
}

class _PDF_PageState extends State<PDF_Page> {
  final pdf = pw.Document();

  // Changed main color to dark blue to match image
  Color myColor = const Color(0xff1d3557);
  Color accentColor = const Color(0xff2C3E50);

  late final pw.MemoryImage image;
  late final MemoryImage image2;

  @override
  void initState() {
    super.initState();

    if (Global.image != null) {
      image = pw.MemoryImage(
        File(Global.image!.path).readAsBytesSync(),
      );

      image2 = MemoryImage(
        File(Global.image!.path).readAsBytesSync(),
      );
    }

    buildPdf();
  }

  // Text styles for Flutter UI preview
  final nameStyle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xff2C3E50),
  );

  final nameAccentStyle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    color: Color(0xff4a4a4a),
  );

  final sectionTitleStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xff2C3E50),
  );

  final contentTitleStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xff2C3E50),
  );

  final contentStyle = const TextStyle(
    fontSize: 13,
    color: Color(0xff4A4A4A),
  );

  final sidebarTitleStyle = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final sidebarContentStyle = const TextStyle(
    fontSize: 13,
    color: Colors.white70,
  );

  // Text styles for PDF document
  final nameStylePw = pw.TextStyle(
    fontSize: 28,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey800,
  );

  final nameAccentStylePw = pw.TextStyle(
    fontSize: 28,
    fontWeight: pw.FontWeight.normal,
    color: PdfColors.grey800,
  );

  final sectionTitleStylePw = pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey800,
  );

  final contentTitleStylePw = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey800,
  );

  final contentStylePw = pw.TextStyle(
    fontSize: 13,
    color: PdfColors.grey800,
  );

  final sidebarTitleStylePw = pw.TextStyle(
    fontSize: 15,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  );

  final sidebarContentStylePw = pw.TextStyle(
    fontSize: 13,
    color: PdfColors.grey200,
  );

  void buildPdf() {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(0), // Remove margin for full bleed sidebar
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (pw.Context context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [ // Left Sidebar (Dark background)
              pw.Container(
                width: 170,
                height: 842, // A4 height
                color: PdfColors.blueGrey800,
                padding: const pw.EdgeInsets.all(15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Profile Photo
                    pw.Center(
                      child: Global.image != null
                          ? pw.Container(
                        width: 100,
                        height: 100,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: PdfColors.white, width: 2),
                        ),
                        child: pw.ClipOval(
                          child: pw.Image(image, fit: pw.BoxFit.cover),
                        ),
                      )
                          : pw.Container(),
                    ),
                    pw.SizedBox(height: 20),

                    // Contact Information
                    buildSidebarSectionPw("CONTACT"),
                    pw.SizedBox(height: 8),
                    if (Global.email != null)
                      buildSidebarItemWithIconPw("✉️", Global.email!),
                    if (Global.phone != null)
                      buildSidebarItemWithIconPw("📱", Global.phone!),

                    pw.SizedBox(height: 15),

                    // Education
                    buildSidebarSectionPw("EDUCATION"),
                    pw.SizedBox(height: 8),
                    buildEducationSidebarPw(),
                    pw.SizedBox(height: 15),

                    // Skills
                    buildSidebarSectionPw("SKILLS"),
                    pw.SizedBox(height: 8),
                    buildSkillsSidebarPw(),
                    pw.SizedBox(height: 15),

                    // Languages
                    buildSidebarSectionPw("LANGUAGES"),
                    pw.SizedBox(height: 8),
                    buildLanguagesSidebarPw(),
                  ],
                ),
              ),

              // Main content area
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header with Name and Title
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          if (Global.name != null)
                            pw.RichText(
                              text: pw.TextSpan(
                                children: [
                                  pw.TextSpan(
                                    text: Global.name!.split(' ').first + ' ',
                                    style: nameStylePw,
                                  ),
                                  pw.TextSpan(
                                    text: Global.name!.split(' ').skip(1).join(' '),
                                    style: nameAccentStylePw,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (Global.careerObjectiveExperienced != null)
                        pw.Text(
                          Global.careerObjectiveExperienced!.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                      pw.SizedBox(height: 5),
                      pw.Divider(color: PdfColors.blue800, thickness: 3, ),
                      pw.SizedBox(height: 15),

                      // Profile/Career Objective
                      pw.Text("PROFILE", style: sectionTitleStylePw),
                      pw.SizedBox(height: 8),
                      if (Global.careerObjectiveDescription != null)
                        pw.Text(
                          Global.careerObjectiveDescription!,
                          style: contentStylePw,
                        ),
                      pw.SizedBox(height: 15),

                      // Work Experience
                      pw.Text("WORK EXPERIENCE", style: sectionTitleStylePw),
                      pw.SizedBox(height: 8),
                      buildExperiencePw(),
                      pw.SizedBox(height: 15),

                      // Projects
                      buildProjectsPw(),
                      pw.SizedBox(height: 15),

                      // Achievements
                      buildAchievementsPw(),
                      pw.SizedBox(height: 15),

                      // References
                      buildReferencesPw(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: const Text("Resume Preview"),
        centerTitle: true,
        backgroundColor: myColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: () async {
              Directory? dir = await getExternalStorageDirectory();

              File file = File("${dir!.path}/my_resume.pdf");

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

  // Helper method for sidebar items with icons
  pw.Widget buildSidebarItemWithIconPw(String icon, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 16,
            child: pw.Text(icon, style: sidebarContentStylePw),
          ),
          pw.SizedBox(width: 5),
          pw.Expanded(
            child: pw.Text(text, style: sidebarContentStylePw),
          ),
        ],
      ),
    );
  }

  // Helper method for sidebar section headers
  pw.Widget buildSidebarSectionPw(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: sidebarTitleStylePw),
        pw.SizedBox(height: 3),
        pw.Divider(color: PdfColors.white, thickness: 0.5),
      ],
    );
  }

  // Helper method for education entries in sidebar
  pw.Widget buildEducationSidebarPw() {
    if (Global.course == null && Global.collage == null) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (Global.passYear != null)
          pw.Text(
            Global.passYear!,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        pw.SizedBox(height: 3),
        pw.Text(
          Global.course ?? "",
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          Global.collage ?? "",
          style: sidebarContentStylePw,
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  // Helper method for skills in sidebar
  pw.Widget buildSkillsSidebarPw() {
    if (Global.technicalSkills.isEmpty) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: Global.technicalSkills.map((skill) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text("• $skill", style: sidebarContentStylePw),
        );
      }).toList(),
    );
  }

  // Helper method for languages in sidebar
  pw.Widget buildLanguagesSidebarPw() {
    List<String> languages = [];

    if (Global.englishCheckBox) languages.add("English (Fluent)");
    if (Global.hindiCheckBox) languages.add("Hindi (Fluent)");
    if (Global.gujratiCheckBox) languages.add("Gujarati (Native)");

    if (languages.isEmpty) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: languages.map((language) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text("• $language", style: sidebarContentStylePw),
        );
      }).toList(),
    );
  }

  pw.Widget buildExperiencePw() {
    if (Global.experienceCompanyName == null) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left side (bullet point)
            pw.Container(
              width: 10,
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text("•", style: contentStylePw),
            ),
            pw.SizedBox(width: 5),
            // Right side (content)
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          Global.experienceCollage ?? "",
                          style: contentTitleStylePw,
                        ),
                      ),
                      if (Global.experienceJoinDate != null && Global.experienceExitDate != null)
                        pw.Text(
                          "${Global.experienceJoinDate} - ${Global.experienceExitDate}",
                          style: contentStylePw,
                        ),
                    ],
                  ),
                  pw.Text(
                    Global.experienceCompanyName ?? "",
                    style: contentStylePw,
                  ),
                  pw.SizedBox(height: 5),
                  if (Global.experienceRole != null && Global.experienceRole != "")
                    pw.Text(
                      "• ${Global.experienceRole}",
                      style: contentStylePw,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget buildProjectsPw() {
    if (Global.projectTitle == null) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("PROJECTS", style: sectionTitleStylePw),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left side (bullet point)
            pw.Container(
              width: 10,
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text("•", style: contentStylePw),
            ),
            pw.SizedBox(width: 5),
            // Right side (content)
            pw.Expanded(
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
                    style: contentStylePw,
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    "Technologies:",
                    style: contentStylePw,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    children: [
                      if (Global.projectCheckBoxCProgramming == true)
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const pw.EdgeInsets.only(right: 5),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text("C Programming", style: contentStylePw),
                        ),
                      if (Global.projectCheckBoxCPP == true)
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const pw.EdgeInsets.only(right: 5),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text("C++", style: contentStylePw),
                        ),
                      if (Global.projectCheckBoxFlutter == true)
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const pw.EdgeInsets.only(right: 5),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text("Flutter", style: contentStylePw),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget buildAchievementsPw() {
    if (Global.achievement.isEmpty) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("ACHIEVEMENTS", style: sectionTitleStylePw),
        pw.SizedBox(height: 5),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: Global.achievement.map((achievement) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(
                "• $achievement",
                style: contentStylePw,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget buildReferencesPw() {
    if (Global.referenceName == null) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("REFERENCE", style: sectionTitleStylePw),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    Global.referenceName ?? "",
                    style: contentTitleStylePw,
                  ),
                  pw.Text(
                    "${Global.referenceDesignation ?? ""}, ${Global
                        .referenceOrganization ?? ""}",
                    style: contentStylePw,
                  ),
                  // Removed the referencePhone and referenceEmail fields that aren't in your Global class
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}