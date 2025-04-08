import 'package:flutter/material.dart';
import 'package:resumehub/screens/backButton.dart';
import 'package:resumehub/screens/creative_template.dart';
import 'package:resumehub/screens/modern_temp.dart';
import 'package:resumehub/screens/pdf_page.dart';
import 'package:resumehub/screens/professional_temp.dart';

class ResumeTemplateSelector extends StatelessWidget {
  const ResumeTemplateSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Getting screen size to make layout more responsive
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: const Text(
          "Select Resume Template",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xff1d3557),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xff1d3557).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading - using less vertical space on small screens
                Padding(
                  padding: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 12.0),
                  child: const Text(
                    "Choose your style",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1d3557),
                    ),
                  ),
                ),
                // Grid view wrapped in Expanded to take remaining space
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isSmallScreen ? 0.85 : 0.75,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      // Template data
                      final templates = [
                        {
                          "title": "Classic Side-by-Side",
                          "description":
                              "Professional layout with a colorful sidebar",
                          "image": "assets/side-by-side.jpg",
                          "page": PDF_Page(),
                        },
                        {
                          "title": "Modern Minimalist",
                          "description": "Clean design with a focus on content",
                          "image": "assets/modern.jpg",
                          "page": ModernMinimalistResume(),
                        },
                        {
                          "title": "Classic Professional",
                          "description":
                              "Traditional layout with a formal look",
                          "image": "assets/professional.jpg",
                          "page": ClassicProfessionalResume(),
                        },
                        {
                          "title": "Creative Grid",
                          "description":
                              "Modern design with a grid-based layout",
                          "image": "assets/creative.jpg",
                          "page": CreativeGridResume(),
                        },
                      ];

                      return _buildTemplateCard(
                        context,
                        title: templates[index]["title"] as String,
                        description: templates[index]["description"] as String,
                        image: templates[index]["image"] as String,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    templates[index]["page"] as Widget),
                          );
                        },
                        isSmallScreen: isSmallScreen,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context, {
    required String title,
    required String description,
    required String image,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Template image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      image,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay for better visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Template info
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                      color: const Color(0xff1d3557),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
