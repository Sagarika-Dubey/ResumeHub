import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../services/enhanced_ai_service.dart';

final List<LinearGradient> cardGradients = [
  LinearGradient(colors: [Color(0xFF4158D0), Color(0xFFC850C0)]),
  LinearGradient(colors: [Color(0xFF0093E9), Color(0xFF80D0C7)]),
  LinearGradient(colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)]),
  LinearGradient(colors: [Color(0xFFD9AFD9), Color(0xFF97D9E1)]),
  LinearGradient(colors: [Color(0xFF00DBDE), Color(0xFFFC00FF)]),
];

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Map<String, String>> flashcards = [
    {'front': 'flutter', 'back': 'made by google'},
    {'front': 'github', 'back': 'version controlling'},
  ];

  bool _isFlipped = false;
  int _currentIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFlashcards = prefs.getString('flashcards');

    if (savedFlashcards != null) {
      List<dynamic> decodedList = json.decode(savedFlashcards);
      setState(() {
        flashcards = decodedList
            .map((item) => Map<String, String>.from(item as Map))
            .toList();
      });
    }
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flashcards', json.encode(flashcards));
  }

  void _nextCard() {
    setState(() {
      _isFlipped = false;
      _currentIndex = (_currentIndex + 1) % flashcards.length;
    });
  }

  void _previousCard() {
    setState(() {
      _isFlipped = false;
      _currentIndex =
          (_currentIndex - 1 + flashcards.length) % flashcards.length;
    });
  }

  Future<void> _generateNewCards() async {
    setState(() => _isLoading = true);

    try {
      final newCards =
          await EnhancedAIService.generateFlashcards('Current Topic', 5);
      setState(() {
        flashcards.addAll(newCards);
        _isLoading = false;
      });
      _saveFlashcards();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate new cards')));
    }
  }

  void _addCustomCard() {
    final frontController = TextEditingController();
    final backController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: frontController,
                decoration: InputDecoration(
                    labelText: 'Front (Question)',
                    border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextField(
                controller: backController,
                decoration: InputDecoration(
                    labelText: 'Back (Answer)', border: OutlineInputBorder()),
                maxLines: 2),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (frontController.text.isNotEmpty &&
                  backController.text.isNotEmpty) {
                setState(() {
                  flashcards.add({
                    'front': frontController.text,
                    'back': backController.text
                  });
                });
                _saveFlashcards();
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCurrentCard() {
    if (flashcards.isNotEmpty) {
      setState(() {
        flashcards.removeAt(_currentIndex);
        _currentIndex = _currentIndex % flashcards.length;
      });
      _saveFlashcards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isFlipped = !_isFlipped),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: _isFlipped ? 180 : 0),
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              builder: (context, double value, child) {
                bool isFront = value < 90;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY((value * math.pi) / 180),
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.all(32),
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: cardGradients[
                              _currentIndex % cardGradients.length],
                        ),
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(isFront ? 0 : math.pi),
                            child: Text(
                              isFront
                                  ? flashcards[_currentIndex]['front']!
                                  : flashcards[_currentIndex]['back']!,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        LinearProgressIndicator(
            value: (flashcards.isEmpty
                ? 0
                : (_currentIndex + 1) / flashcards.length)),
        Text('Card ${_currentIndex + 1} of ${flashcards.length}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: _previousCard,
                color: Colors.blue),
            IconButton(
                icon: Icon(Icons.add_circle),
                onPressed: _addCustomCard,
                color: Colors.blue),
            IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: _nextCard,
                color: Colors.blue),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: _deleteCurrentCard,
                color: Colors.red),
          ],
        ),
      ],
    );
  }
}
