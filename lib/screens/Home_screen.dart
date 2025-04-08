import 'package:flutter/material.dart';
import 'package:resumehub/screens/ats_checking.dart';
import 'package:resumehub/screens/flashcard_screen.dart';
import './jobscree.dart';
import 'package:resumehub/screens/user_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resumehub/screens/categories_screen.dart';
import 'package:resumehub/services/job_recc.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Create a common card styling
    final cardDecoration = BoxDecoration(
      color: isDarkMode ? Color(0xFF1E1E2E) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          child: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              // Implement refresh functionality here
              await Future.delayed(Duration(milliseconds: 800));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Bar with profile
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Hello, ",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w400,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                TextSpan(
                                  text: "User",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader = LinearGradient(
                                        colors: [
                                          Color(0xFF4776E6),
                                          Color(0xFF8E54E9),
                                        ],
                                      ).createShader(
                                          Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Create Resume Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      margin: const EdgeInsets.only(bottom: 32.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [Color(0xFF2B2B42), Color(0xFF1E1E2E)]
                              : [Color(0xFFF0F4FF), Color(0xFFE4ECFF)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4776E6).withOpacity(0.12),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4776E6).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.description_outlined,
                                  color: Color(0xFF4776E6),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Resume Builder",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Color(0xFF333647),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "No resumes created yet",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pushNamed(context, 'build_option_page');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4776E6),
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 56),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF4776E6),
                                    Color(0xFF8E54E9)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                height: 56,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      "CREATE NEW RESUME",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Section Header - Resume Tools
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Container(
                            height: 24,
                            width: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFF4776E6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Resume Tools",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? Colors.white : Color(0xFF333647),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Resume Tools Cards - Grid Layout
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        // AI Resume Feedback
                        _buildToolCard(
                          context,
                          title: "Resume\nFeedback",
                          icon: Icons.rate_review,
                          gradient: [Color(0xFFAD5CFF), Color(0xFF823FFC)],
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResumeScreen()),
                            );
                          },
                        ),

                        // Flashcards
                        _buildToolCard(
                          context,
                          title: "Interview\nFlashcards",
                          icon: Icons.flash_on_rounded,
                          gradient: [Color(0xFFFF8C42), Color(0xFFFF5757)],
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoriesScreen()),
                            );
                          },
                        ),

                        // Job Recommendations
                        _buildToolCard(
                          context,
                          title: "Job\nMatches",
                          icon: Icons.work_outline,
                          gradient: [Color(0xFF0BAB64), Color(0xFF3BB78F)],
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => JobRecommendations()),
                            );
                          },
                        ),

                        // CV Scanner
                        _buildToolCard(
                          context,
                          title: "ATS\nChecker",
                          icon: Icons.document_scanner,
                          gradient: [Color(0xFF00C6FF), Color(0xFF0078FF)],
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResumeScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Learning Resources Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 24,
                              width: 4,
                              decoration: BoxDecoration(
                                color: Color(0xFF4776E6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Career Resources",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : Color(0xFF333647),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all resources
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFF4776E6),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            "See All",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Video Cards with horizontal scroll - FIXED HEIGHT
                    Container(
                      height: 240, // Increased height to accommodate content
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        children: [
                          _buildVideoCard(
                            context,
                            title: "Ace Your Tech Interview",
                            duration: "12:45",
                            thumbnailUrl:
                                "https://img.youtube.com/vi/gDN7cJ3Rt80/mqdefault.jpg",
                            videoUrl:
                                "https://youtu.be/gDN7cJ3Rt80?si=s8mUhlam2_qGes4p",
                          ),
                          _buildVideoCard(
                            context,
                            title: "Resume Building Masterclass",
                            duration: "18:27",
                            thumbnailUrl:
                                "https://img.youtube.com/vi/y3R9e2L8I9E/mqdefault.jpg",
                            videoUrl:
                                "https://youtu.be/y3R9e2L8I9E?si=boeYJfXn0EvmLBB1",
                          ),
                          _buildVideoCard(
                            context,
                            title:
                                "How I Optimized my LinkedIn Profile and Got 20+ Interview RAG",
                            duration: "8.52",
                            thumbnailUrl:
                                "https://i.ytimg.com/an_webp/dQ6RNltrXro/mqdefault_6s.webp?du=3000&sqp=CKj21b8G&rs=AOn4CLCjPrQMku8Of-Rt1gAhtTlO3GNQXw",
                            videoUrl:
                                "https://www.youtube.com/watch?v=dQ6RNltrXro",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Stats Dashboard
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [Color(0xFF22223B), Color(0xFF1A1A2E)]
                              : [Colors.white, Color(0xFFF8FAFF)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4776E6).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.analytics_outlined,
                                  color: Color(0xFF4776E6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Your Progress",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Color(0xFF333647),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                context,
                                "0",
                                "Resumes",
                                Icons.description_outlined,
                                Color(0xFF4776E6),
                              ),
                              _buildStatItem(
                                context,
                                "0",
                                "Flashcards",
                                Icons.flash_on_outlined,
                                Color(0xFFFF8C42),
                              ),
                              _buildStatItem(
                                context,
                                "0",
                                "Applications",
                                Icons.send_outlined,
                                Color(0xFF0BAB64),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Add some bottom padding to prevent overflows at the end of the page
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Color(0xFF333647),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context, {
    required String title,
    required String duration,
    required String thumbnailUrl,
    required String videoUrl,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _launchURL(videoUrl),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button and duration
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    thumbnailUrl,
                    height:
                        150, // Slightly reduced height to help with overflow
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey.shade700,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                // Play button
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                // Duration pill
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Video title and info
            Padding(
              padding: const EdgeInsets.all(12.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15, // Slightly smaller font
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Color(0xFF333647),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6), // Reduced spacing
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 14, // Smaller icon
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4), // Reduced spacing
                      Text(
                        "Career Tips",
                        style: TextStyle(
                          fontSize: 12, // Smaller font
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Color(0xFF333647),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
