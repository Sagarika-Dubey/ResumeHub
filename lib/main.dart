import 'package:flutter/material.dart';
import 'package:resumehub/screens/ats_checking.dart';
import 'package:resumehub/screens/build_options_page.dart';
import 'package:resumehub/screens/flashcard_screen.dart';
import 'package:resumehub/screens/jobscree.dart';
import 'package:resumehub/screens/options/achievement_page.dart';
import 'package:resumehub/screens/options/carrier_objective_page.dart';
import 'package:resumehub/screens/options/contact_info_page.dart';
import 'package:resumehub/screens/options/education_page.dart';
import 'package:resumehub/screens/options/experience_page.dart';
import 'package:resumehub/screens/options/interest_hobbies_page.dart';
import 'package:resumehub/screens/options/personal_details_page.dart';
import 'package:resumehub/screens/options/projects_page.dart';
import 'package:resumehub/screens/options/technical_skills_page.dart';
import 'package:resumehub/screens/pdf_page.dart';
import 'package:resumehub/services/skill.dart';
import '../services/job_recc.dart';
import 'authentication/intropage.dart';
import 'package:firebase_core/firebase_core.dart';
import './services/skill.dart';
import 'package:resumehub/screens/home_screen.dart'; // Import the new HomeScreen file
import '../services/job_recc.dart';
import 'authentication/intropage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:resumehub/screens/user_profile_screen.dart';
import 'screens/categories_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './screens/resume_templatescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🔥 Initializing Firebase...");
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const ResumeHubApp());
}

class ResumeHubApp extends StatelessWidget {
  const ResumeHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Segoe UI',
      ),
      home: const WelcomeScreen(),
      initialRoute: '/',
      routes: {
        'build_option_page': (context) => const Build_Options_Page(),
        'contact_info_page': (context) => const contact_info_page(),
        'carrier_objective_page': (context) => const carrier_objective_page(),
        'personal_details_page': (context) => const personal_details_page(),
        'education_page': (context) => const education_page(),
        'experience_page': (context) => const experience_page(),
        'technical_skills_page': (context) => const technical_skills_page(),
        'interest_hobbies_page': (context) => const interest_hobbies_page(),
        'projects_page': (context) => const projects_page(),
        'achievement_page': (context) => const achievement_page(),
        'Template_selection': (context) => const ResumeTemplateSelector(),
        'pdf_page': (context) => PDF_Page(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(), // Using the imported HomeScreen
    const QuizScreen(),
    const LearnScreen(),
    const CardsScreen(),
    const AIToolsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color myColor = const Color(0xffffffff);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColor,
        title: const Text("RESUME HUB"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              _showUserProfile(context);
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.quiz_rounded), label: 'Skill analysis'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded), label: 'Jobs'),
          BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_rounded), label: 'Cards'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'ATS'),
        ],
      ),
    );
  }
}

// Keep these other screen definitions
class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkillAnalysisScreen(),
    );
  }
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JobRecommendations(),
    );
  }
}

class CardsScreen extends StatelessWidget {
  const CardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CategoriesScreen();
  }
}

class AIToolsScreen extends StatelessWidget {
  const AIToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ResumeScreen());
  }
}
