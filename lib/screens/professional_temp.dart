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

class ClassicProfessionalResume extends StatefulWidget {
  ClassicProfessionalResume({Key? key}) : super(key: key);

  @override
  State<ClassicProfessionalResume> createState() =>
      _ClassicProfessionalResumeState();
}

class _ClassicProfessionalResumeState extends State<ClassicProfessionalResume> {
  final pdf = pw.Document();

  // Color scheme
  Color primaryColor = const Color(0xff2C3E50);
  Color accentColor = const Color(0xff34495E);

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
  final headerStylePw = pw.TextStyle(
    fontSize: 22,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey900,
  );

  final subheaderStylePw = pw.TextStyle(
    fontSize: 16,
    color: PdfColors.blueGrey700,
  );

  final sectionTitleStylePw = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey800,
  );

  final contentTitleStylePw = pw.TextStyle(
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey800,
  );

  final contentStylePw = pw.TextStyle(
    fontSize: 11,
    color: PdfColors.blueGrey800,
  );

  void buildPdf() {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(30),
        theme: pw.ThemeData.withFont(
          base: pw.Font.times(),
          bold: pw.Font.timesBold(),
          italic: pw.Font.timesItalic(),
          boldItalic: pw.Font.timesBoldItalic(),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with name and contact info
              pw.Center(
                child: pw.Column(
                  children: [
                    if (Global.name != null)
                      pw.Text(
                        Global.name!.toUpperCase(),
                        style: headerStylePw,
                      ),
                    pw.SizedBox(height: 4),
                    if (Global.careerObjectiveExperienced != null)
                      pw.Text(
                        Global.careerObjectiveExperienced!,
                        style: subheaderStylePw,
                      ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        if (Global.email != null) ...[
                          pw.Text("Email: ", style: contentTitleStylePw),
                          pw.Text(Global.email!, style: contentStylePw),
                        ],
                        if (Global.email != null && Global.phone != null)
                          pw.Text("  |  ", style: contentStylePw),
                        if (Global.phone != null) ...[
                          pw.Text("Phone: ", style: contentTitleStylePw),
                          pw.Text(Global.phone!, style: contentStylePw),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 15),
              pw.Divider(color: PdfColors.blueGrey800, thickness: 1),
              pw.SizedBox(height: 15),

              // Profile/Summary section
              if (Global.careerObjectiveDescription != null) ...[
                pw.Row(
                  children: [
                    pw.Container(
                      width: 120,
                      child: pw.Text("PROFILE", style: sectionTitleStylePw),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            Global.careerObjectiveDescription!,
                            style: contentStylePw,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
              ],

              // Experience section
              if (Global.experienceCompanyName != null) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120,
                      child: pw.Text("EXPERIENCE", style: sectionTitleStylePw),
                    ),
                    pw.Expanded(
                      child: buildExperienceSection(),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
              ],

              // Education section
              if (Global.course != null || Global.collage != null) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120,
                      child: pw.Text("EDUCATION", style: sectionTitleStylePw),
                    ),
                    pw.Expanded(
                      child: buildEducationSection(),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
              ],

              // Skills section
              if (Global.technicalSkills.isNotEmpty) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120,
                      child: pw.Text("SKILLS", style: sectionTitleStylePw),
                    ),
                    pw.Expanded(
                      child: buildSkillsSection(),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
              ],

              // Projects section
              if (Global.projectTitle != null) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120,
                      child: pw.Text("PROJECTS", style: sectionTitleStylePw),
                    ),
                    pw.Expanded(
                      child: buildProjectsSection(),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
              ],

              // Achievements section
              if (Global.achievement.isNotEmpty) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120,
                      child:
                          pw.Text("ACHIEVEMENTS", style: sectionTitleStylePw),
                    ),
                    pw.Expanded(
                      child: buildAchievementsSection(),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
              ],

              // Languages section
              if (Global.englishCheckBox ||
                  Global.hindiCheckBox ||
                  Global.gujratiCheckBox) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120,
                      child: pw.Text("LANGUAGES", style: sectionTitleStylePw),
                    ),
                    pw.Expanded(
                      child: buildLanguagesSection(),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
              ],

              // References section
              if (Global.referenceName != null) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120,
                      child: pw.Text("REFERENCES", style: sectionTitleStylePw),
                    ),
                    pw.Expanded(
                      child: buildReferencesSection(),
                    ),
                  ],
                ),
              ],
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
                  pw.Expanded(
                    child: pw.Text(
                      Global.experienceCollage ?? "",
                      style: contentTitleStylePw,
                    ),
                  ),
                  if (Global.experienceJoinDate != null &&
                      Global.experienceExitDate != null)
                    pw.Text(
                      "${Global.experienceJoinDate} - ${Global.experienceExitDate}",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                ],
              ),
              pw.Text(
                Global.experienceCompanyName ?? "",
                style: pw.TextStyle(
                  fontSize: 11,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 3),
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
                  pw.Expanded(
                    child: pw.Text(
                      Global.course ?? "",
                      style: contentTitleStylePw,
                    ),
                  ),
                  if (Global.passYear != null)
                    pw.Text(
                      Global.passYear!,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                ],
              ),
              pw.Text(
                Global.collage ?? "",
                style: pw.TextStyle(
                  fontSize: 11,
                  fontStyle: pw.FontStyle.italic,
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
      children: [
        for (var skill in Global.technicalSkills)
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 10, bottom: 3),
            child: pw.Text(
              "• $skill",
              style: contentStylePw,
            ),
          ),
      ],
    );
  }

  pw.Widget buildProjectsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
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
              pw.SizedBox(height: 3),
              pw.Text(
                "Role: ${Global.projectRoles ?? ""}",
                style: pw.TextStyle(
                  fontSize: 11,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                "Technologies: " +
                    [
                      if (Global.projectCheckBoxCProgramming == true)
                        "C Programming",
                      if (Global.projectCheckBoxCPP == true) "C++",
                      if (Global.projectCheckBoxFlutter == true) "Flutter",
                    ].join(", "),
                style: contentStylePw,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget buildAchievementsSection() {
    return pw.Column(
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
    );
  }

  pw.Widget buildLanguagesSection() {
    List<String> languages = [];

    if (Global.englishCheckBox) languages.add("English");
    if (Global.hindiCheckBox) languages.add("Hindi");
    if (Global.gujratiCheckBox) languages.add("Gujarati");

    return pw.Text(
      languages.join(", "),
      style: contentStylePw,
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
        title: const Text("Classic Professional Resume"),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: () async {
              Directory? dir = await getExternalStorageDirectory();
              File file = File("${dir!.path}/classic_professional_resume.pdf");
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
