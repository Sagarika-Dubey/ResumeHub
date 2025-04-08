import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../services/enhanced_ai_service.dart';

// Enhanced flashcard model with additional fields
class EnhancedFlashcard {
  final String question;
  final String solution;
  final List<String> tags;
  final String? youtubeLink;
  final String? imageUrl;
  final bool isCommonlyAsked;
  bool isKnown;
  bool isInReview;

  EnhancedFlashcard({
    required this.question,
    required this.solution,
    this.tags = const [],
    this.youtubeLink,
    this.imageUrl,
    this.isCommonlyAsked = false,
    this.isKnown = false,
    this.isInReview = true,
  });

  // Convert from your existing format
  factory EnhancedFlashcard.fromLegacy(Map<String, String> legacy) {
    return EnhancedFlashcard(
      question: legacy['front'] ?? '',
      solution: legacy['back'] ?? '',
      tags: [],
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'solution': solution,
      'tags': tags,
      'youtubeLink': youtubeLink,
      'imageUrl': imageUrl,
      'isCommonlyAsked': isCommonlyAsked,
      'isKnown': isKnown,
      'isInReview': isInReview,
    };
  }

  // Convert from JSON for storage
  factory EnhancedFlashcard.fromJson(Map<String, dynamic> json) {
    return EnhancedFlashcard(
      question: json['question'] ?? '',
      solution: json['solution'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      youtubeLink: json['youtubeLink'],
      imageUrl: json['imageUrl'],
      isCommonlyAsked: json['isCommonlyAsked'] ?? false,
      isKnown: json['isKnown'] ?? false,
      isInReview: json['isInReview'] ?? true,
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  final List<Map<String, String>>? initialFlashcards;
  final String? categoryName;

  const FlashcardScreen({
    super.key,
    this.initialFlashcards,
    this.categoryName,
  });

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  List<EnhancedFlashcard> flashcards = [];
  List<Map<String, String>> legacyFlashcards = [];

  bool _isFlipped = false;
  int _currentIndex = 0;
  bool _isLoading = false;
  late String storageKey;
  int score = 0;
  int inReview = 0;
  int done = 0;

  // Animation controller for background pattern
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Theme colors from the Resume Hub screenshot
  final Color primaryColor = Color(0xFF1C78F2); // Main blue color
  final Color accentColor = Color(0xFF6FB6FF); // Light blue accent
  final Color backgroundColor = Colors.white; // White background
  final Color cardColor = Colors.white; // White card
  final Color textColor = Color(0xFF333333); // Dark text
  final Color secondaryTextColor = Color(0xFF666666); // Gray text

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_animationController);

    storageKey = widget.categoryName != null
        ? 'enhanced_flashcards_${widget.categoryName!.toLowerCase().replaceAll(' ', '_')}'
        : 'enhanced_flashcards';

    if (widget.initialFlashcards != null && widget.initialFlashcards!.isNotEmpty) {
      legacyFlashcards = widget.initialFlashcards!;
      // Convert legacy flashcards to enhanced format
      flashcards = legacyFlashcards.map((card) => EnhancedFlashcard.fromLegacy(card)).toList();
      _saveFlashcards();
    } else {
      _loadFlashcards();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFlashcards = prefs.getString(storageKey);

    if (savedFlashcards != null) {
      try {
        List<dynamic> decodedList = json.decode(savedFlashcards);
        setState(() {
          flashcards = decodedList
              .map((item) => EnhancedFlashcard.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      } catch (e) {
        // If enhanced format fails, try legacy format
        final legacyKey = widget.categoryName != null
            ? 'flashcards_${widget.categoryName!.toLowerCase().replaceAll(' ', '_')}'
            : 'flashcards';
        final legacySaved = prefs.getString(legacyKey);

        if (legacySaved != null) {
          List<dynamic> decodedList = json.decode(legacySaved);
          legacyFlashcards = decodedList
              .map((item) => Map<String, String>.from(item as Map))
              .toList();
          flashcards = legacyFlashcards.map((card) => EnhancedFlashcard.fromLegacy(card)).toList();
          _saveFlashcards(); // Save in new format
        }
      }
    }

    if (flashcards.isEmpty) {
      // Default cards
      flashcards = [
        EnhancedFlashcard(
          question: 'Add new cards',
          solution: 'Tap the + button to add cards',
          tags: ['Help'],
        )
      ];
    }

    _calculateStats();
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = json.encode(flashcards.map((card) => card.toJson()).toList());
    await prefs.setString(storageKey, encodedData);
  }

  void _calculateStats() {
    inReview = flashcards.where((card) => card.isInReview).length;
    done = flashcards.where((card) => !card.isInReview).length;
    int knownCards = flashcards.where((card) => card.isKnown).length;
    score = flashcards.isEmpty ? 0 : ((knownCards / flashcards.length) * 100).round();
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
      _currentIndex = (_currentIndex - 1 + flashcards.length) % flashcards.length;
    });
  }

  void _markAsKnown() {
    setState(() {
      flashcards[_currentIndex].isKnown = true;
      flashcards[_currentIndex].isInReview = false;
      _calculateStats();
      _saveFlashcards();
      _nextCard();
    });
  }

  void _markAsUnknown() {
    setState(() {
      flashcards[_currentIndex].isKnown = false;
      flashcards[_currentIndex].isInReview = true;
      _calculateStats();
      _saveFlashcards();
      _nextCard();
    });
  }

  Future<void> _generateNewCards() async {
    setState(() => _isLoading = true);

    try {
      final topic = widget.categoryName ?? 'Current Topic';
      final newCards = await EnhancedAIService.generateFlashcards(topic, 5);

      // Convert the legacy format to enhanced format
      final enhancedNewCards = newCards.map((card) =>
          EnhancedFlashcard(
            question: card['front'] ?? '',
            solution: card['back'] ?? '',
            tags: [topic],
            isCommonlyAsked: math.Random().nextBool(),
          )
      ).toList();

      setState(() {
        flashcards.addAll(enhancedNewCards);
        _isLoading = false;
      });
      _calculateStats();
      _saveFlashcards();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate new cards')));
    }
  }

  void _addCustomCard() {
    final questionController = TextEditingController();
    final solutionController = TextEditingController();
    final tagsController = TextEditingController();
    final youtubeLinkController = TextEditingController();
    bool isCommonlyAsked = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text('Add Custom Flashcard', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Question',
                  labelStyle: TextStyle(color: secondaryTextColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: solutionController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Solution',
                  labelStyle: TextStyle(color: secondaryTextColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: tagsController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Tags (comma separated)',
                  labelStyle: TextStyle(color: secondaryTextColor),
                  hintText: 'e.g. Flutter, Widgets, UI',
                  hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: youtubeLinkController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'YouTube Link (optional)',
                  labelStyle: TextStyle(color: secondaryTextColor),
                  hintText: 'https://youtu.be/...',
                  hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Mark as commonly asked', style: TextStyle(color: textColor)),
                value: isCommonlyAsked,
                onChanged: (value) {
                  setState(() {
                    isCommonlyAsked = value ?? false;
                  });
                },
                activeColor: primaryColor,
                checkColor: Colors.white,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: secondaryTextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.isNotEmpty &&
                  solutionController.text.isNotEmpty) {
                // Parse tags
                List<String> tags = [];
                if (tagsController.text.isNotEmpty) {
                  tags = tagsController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList();
                }

                // Add category name as a tag if available
                if (widget.categoryName != null) {
                  tags.add(widget.categoryName!);
                }

                setState(() {
                  flashcards.add(
                    EnhancedFlashcard(
                      question: questionController.text,
                      solution: solutionController.text,
                      tags: tags,
                      youtubeLink: youtubeLinkController.text.isNotEmpty
                          ? youtubeLinkController.text
                          : null,
                      isCommonlyAsked: isCommonlyAsked,
                    ),
                  );
                });
                _calculateStats();
                _saveFlashcards();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCurrentCard() {
    if (flashcards.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('Delete Card', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete this flashcard?',
              style: TextStyle(color: secondaryTextColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: secondaryTextColor)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  flashcards.removeAt(_currentIndex);
                  if (flashcards.isEmpty) {
                    // Add a default card if all are deleted
                    flashcards.add(EnhancedFlashcard(
                      question: 'Add new cards',
                      solution: 'Tap the + button to add cards',
                      tags: ['Help'],
                    ));
                  }
                  _currentIndex = _currentIndex % flashcards.length;
                });
                _calculateStats();
                _saveFlashcards();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  void _launchYoutubeLink(String? url) async {
    if (url != null && url.isNotEmpty) {
      try {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch video'),
              backgroundColor: Colors.red.shade800,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid URL'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timeline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                '$score/100',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'EXIT',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          Container(
            margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.refresh, color: accentColor, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '$inReview In Review',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '$done Done',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                Spacer(),
                TextButton(
                  onPressed: _generateNewCards,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.autorenew, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Practice',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Flashcard area
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
                      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: isFront
                              ? primaryColor.withOpacity(0.2)
                              : accentColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(isFront ? 0 : math.pi),
                        child: isFront
                            ? _buildQuestionSide(flashcards[_currentIndex])
                            : _buildSolutionSide(flashcards[_currentIndex]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Navigation area
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Card ${_currentIndex + 1} of ${flashcards.length}',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ],
            ),
          ),

          // Control buttons
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: secondaryTextColor),
                  onPressed: _previousCard,
                  tooltip: 'Previous Card',
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  child: Icon(Icons.add),
                  onPressed: _addCustomCard,
                  tooltip: 'Add New Card',
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: secondaryTextColor),
                  onPressed: _nextCard,
                  tooltip: 'Next Card',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade400),
                  onPressed: _deleteCurrentCard,
                  tooltip: 'Delete Card',
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionSide(EnhancedFlashcard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: primaryColor, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'QUESTION',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            if (card.isCommonlyAsked)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.orange, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'COMMONLY ASKED',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 24),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Text(
                card.question,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        _buildResponseButtons(card),
      ],
    );
  }

  Widget _buildResponseButtons(EnhancedFlashcard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _markAsKnown,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "I know this concept",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: _markAsUnknown,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.highlight_off, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  "I don't know this concept",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSolutionSide(EnhancedFlashcard card) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    Row(
    children: [
    Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
    color: accentColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: accentColor.withOpacity(0.3)),
    ),
    child: Row(
    children: [
    Icon(Icons.lightbulb_outline, color: accentColor, size: 14),
    SizedBox(width: 4),
    Text(
    'SOLUTION',
    style: TextStyle(
    color: accentColor,
    fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
    ),
    ],
    ),
    ),
      Spacer(),
      if (card.tags.isNotEmpty)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tag, color: secondaryTextColor, size: 14),
              SizedBox(width: 4),
              Text(
                card.tags.first,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (card.tags.length > 1)
                Text(
                  ' +${card.tags.length - 1}',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
    ],
    ),
          SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.solution,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                  if (card.imageUrl != null) ...[
                    SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        card.imageUrl!,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                      ),
                    ),
                  ],
                  if (card.youtubeLink != null) ...[
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () => _launchYoutubeLink(card.youtubeLink),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.play_circle_filled, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Watch explanation video',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          // Tags section
          if (card.tags.isNotEmpty) ...[
            Text(
              'Tags:',
              style: TextStyle(
                color: secondaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
    );
  }
}