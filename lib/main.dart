import 'package:flutter/material.dart';
import 'package:resumehub/screens/ats_checking.dart';
import 'package:resumehub/screens/build_options_page.dart';
import 'package:resumehub/screens/flashcard_screen.dart';
import 'package:resumehub/screens/jobs_screen.dart';
import 'package:resumehub/screens/options/achievement_page.dart';
import 'package:resumehub/screens/options/carrier_objective_page.dart';
import 'package:resumehub/screens/options/contact_info_page.dart';
import 'package:resumehub/screens/options/declaration_page.dart';
import 'package:resumehub/screens/options/education_page.dart';
import 'package:resumehub/screens/options/experience_page.dart';
import 'package:resumehub/screens/options/interest_hobbies_page.dart';
import 'package:resumehub/screens/options/personal_details_page.dart';
import 'package:resumehub/screens/options/projects_page.dart';
import 'package:resumehub/screens/options/reference_page.dart';
import 'package:resumehub/screens/options/technical_skills_page.dart';
import 'package:resumehub/screens/pdf_page.dart';

void main() {
  runApp(const ResumeHubApp());
}

class ResumeHubApp extends StatelessWidget {
  const ResumeHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
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
        'reference_page': (context) => const reference_page(),
        'declaration_page': (context) => const declaration_page(),
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
    const HomeScreen(),
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

  @override
  Widget build(BuildContext context) {
    Color myColor = const Color(0xffffffff);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColor,
        title: const Text("Resume Builder"),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("build_option_page");
        },
        backgroundColor: myColor,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
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
              icon: Icon(Icons.quiz_rounded), label: 'Quiz'),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/icons/open-cardboard-box.png", height: 100),
          const SizedBox(height: 20),
          const Text(
            "No Resumes + Create new Resume",
            style: TextStyle(fontSize: 21, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Quiz Page"));
  }
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JobsScreen(),
    );
  }
}

class CardsScreen extends StatelessWidget {
  const CardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlashcardScreen();
  }
}

class AIToolsScreen extends StatelessWidget {
  const AIToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ResumeScreen());
  }
}
