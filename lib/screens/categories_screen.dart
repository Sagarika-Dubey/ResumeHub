import 'package:flutter/material.dart';
import 'dart:convert'; // Add this import for json
import 'flashcard_screen.dart'; // Import your existing flashcard screen

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final Map<String, List<String>> flashcardData;

  CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.flashcardData,
  });
}

class CategoriesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> sections = [
    {
      'title': 'Programming Languages',
      'items': [
        CategoryItem(
          name: 'Python',
          icon: Icons.code,
          color: Colors.blue,
          flashcardData: {
            'python basics': [
              '{"front": "What is Python?", "back": "Python is a high-level, interpreted programming language known for its readability and versatility."}',
              '{"front": "Who created Python?", "back": "Guido van Rossum created Python in 1991."}',
              '{"front": "What is PEP 8?", "back": "PEP 8 is Python\'s style guide for writing clean, readable code."}',
            ],
          },
        ),
        CategoryItem(
          name: 'Java',
          icon: Icons.coffee,
          color: Colors.brown,
          flashcardData: {
            'java basics': [
              '{"front": "What is Java?", "back": "Java is a class-based, object-oriented programming language designed to have as few implementation dependencies as possible."}',
              '{"front": "What is JVM?", "back": "Java Virtual Machine (JVM) is an engine that provides a runtime environment to drive the Java code."}',
            ],
          },
        ),
        CategoryItem(
          name: 'JavaScript',
          icon: Icons.javascript,
          color: Colors.amber,
          flashcardData: {
            'javascript basics': [
              '{"front": "What is JavaScript?", "back": "JavaScript is a scripting language that enables dynamic content on web pages."}',
              '{"front": "What is the DOM?", "back": "Document Object Model (DOM) is a programming interface for web documents."}',
            ],
          },
        ),
        CategoryItem(
          name: 'C++',
          icon: Icons.code,
          color: Colors.blue,
          flashcardData: {
            'c++ basics': [
              '{"front": "What is C++?", "back": "C++ is a general-purpose programming language created as an extension of the C language."}',
              '{"front": "What are pointers?", "back": "Pointers are variables that store memory addresses of other variables."}',
            ],
          },
        ),
      ],
    },
    {
      'title': 'Mobile Development',
      'items': [
        CategoryItem(
          name: 'Flutter',
          icon: Icons.flutter_dash,
          color: Colors.lightBlue,
          flashcardData: {
            'flutter basics': [
              '{"front": "What is Flutter?", "back": "Flutter is Google\'s UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase."}',
              '{"front": "What is a Widget?", "back": "Widgets are the basic building blocks of a Flutter app\'s user interface."}',
            ],
          },
        ),
        CategoryItem(
          name: 'React Native',
          icon: Icons.smartphone,
          color: Colors.blue,
          flashcardData: {
            'react native basics': [
              '{"front": "What is React Native?", "back": "React Native is a framework for building native apps using React and JavaScript."}',
              '{"front": "What is JSX?", "back": "JSX is a syntax extension for JavaScript that looks similar to HTML and is used with React."}',
            ],
          },
        ),
        CategoryItem(
          name: 'Android SDK',
          icon: Icons.android,
          color: Colors.green,
          flashcardData: {
            'android basics': [
              '{"front": "What is Android SDK?", "back": "Android SDK is a software development kit that enables developers to create applications for the Android platform."}',
              '{"front": "What is an Activity?", "back": "An Activity is a single, focused thing that the user can do in an Android app."}',
            ],
          },
        ),
      ],
    },
    {
      'title': 'Web Development',
      'items': [
        CategoryItem(
          name: 'React',
          icon: Icons.web,
          color: Colors.cyan,
          flashcardData: {
            'react basics': [
              '{"front": "What is React?", "back": "React is a JavaScript library for building user interfaces, particularly single-page applications."}',
              '{"front": "What is JSX?", "back": "JSX is a syntax extension for JavaScript that looks similar to HTML and is used with React."}',
            ],
          },
        ),
        CategoryItem(
          name: 'Angular',
          icon: Icons.web_asset,
          color: Colors.red,
          flashcardData: {
            'angular basics': [
              '{"front": "What is Angular?", "back": "Angular is a platform and framework for building single-page client applications using HTML and TypeScript."}',
              '{"front": "What is a component?", "back": "Components are the building blocks of Angular applications."}',
            ],
          },
        ),
        CategoryItem(
          name: 'Django',
          icon: Icons.language,
          color: Colors.green,
          flashcardData: {
            'django basics': [
              '{"front": "What is Django?", "back": "Django is a high-level Python web framework that encourages rapid development and clean, pragmatic design."}',
              '{"front": "What is MTV?", "back": "MTV stands for Model-Template-View, Django\'s software design pattern."}',
            ],
          },
        ),
      ],
    },
  ];

  CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Practice Cards',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections.map((section) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      section['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: (section['items'] as List<CategoryItem>).map((item) {
                      return _buildCategoryItem(context, item);
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Assuming "Cards" is selected
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Interviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Resumes',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryItem item) {
    return InkWell(
      onTap: () {
        // Convert flashcard data to the format expected by FlashcardScreen
        List<Map<String, String>> flashcards = [];

        item.flashcardData.forEach((topic, cards) {
          for (String cardJson in cards) {
            Map<String, dynamic> parsedCard = json.decode(cardJson);
            flashcards.add({
              'front': parsedCard['front'],
              'back': parsedCard['back'],
            });
          }
        });

        // Navigate to FlashcardScreen with the data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlashcardScreen(
              initialFlashcards: flashcards,
              categoryName: item.name,
            ),
          ),
        );
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: item.color, size: 28),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}