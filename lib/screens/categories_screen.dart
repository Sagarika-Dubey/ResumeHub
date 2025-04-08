import 'package:flutter/material.dart';
import 'dart:convert';
import 'flashcard_screen.dart';

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
          color: Colors.blue.shade600,
          flashcardData: {
            'python interview questions': [
              '{"front": "What is Python?", "back": "Python is a high-level, interpreted programming language known for its readability and versatility."}',
              '{"front": "Who created Python?", "back": "Guido van Rossum created Python in 1991."}',
              '{"front": "What is PEP 8?", "back": "PEP 8 is Python\'s style guide for writing clean, readable code."}',
              '{"front": "Explain list comprehensions in Python.", "back": "List comprehensions are a concise way to create lists. Example: [x**2 for x in range(10) if x % 2 == 0] creates a list of squares of even numbers from 0-9."}',
              '{"front": "What\'s the difference between \'==\' and \'is\' in Python?", "back": "\'==\' checks if two objects have the same value, while \'is\' checks if two references point to the same object in memory."}',
              '{"front": "How does memory management work in Python?", "back": "Python uses automatic memory management with garbage collection. The memory manager allocates memory for objects and the garbage collector reclaims memory from objects that are no longer referenced."}',
              '{"front": "What are decorators in Python?", "back": "Decorators are functions that modify the behavior of other functions. They use the @decorator syntax and are a powerful way to extend or modify functions without modifying their code."}',
              '{"front": "Explain the difference between a list and a tuple.", "back": "Lists are mutable (can be changed after creation) and use square brackets []. Tuples are immutable (cannot be changed after creation) and use parentheses (). Tuples are typically faster and safer for fixed data."}',
            ],
          },
        ),
        CategoryItem(
          name: 'Java',
          icon: Icons.coffee,
          color: Colors.brown.shade600,
          flashcardData: {
            'java interview questions': [
              '{"front": "What is Java?", "back": "Java is a class-based, object-oriented programming language designed to have as few implementation dependencies as possible."}',
              '{"front": "What is JVM?", "back": "Java Virtual Machine (JVM) is an engine that provides a runtime environment to drive the Java code."}',
              '{"front": "Explain the difference between JDK, JRE and JVM.", "back": "JDK (Java Development Kit) contains tools for development, JRE (Java Runtime Environment) contains libraries and JVM for running Java applications, and JVM (Java Virtual Machine) executes Java bytecode."}',
              '{"front": "What is the difference between final, finally, and finalize in Java?", "back": "final is a keyword used to make variables, methods, or classes unchangeable. finally is a block in exception handling that always executes. finalize() is a method called by the garbage collector before object destruction."}',
              '{"front": "What are the main principles of OOP in Java?", "back": "The main principles are: 1) Encapsulation - bundling data and methods, 2) Inheritance - creating new classes from existing ones, 3) Polymorphism - ability of objects to take multiple forms, and 4) Abstraction - hiding implementation details."}',
              '{"front": "What is the difference between method overloading and overriding?", "back": "Method overloading means having multiple methods with the same name but different parameters within the same class. Method overriding means providing a new implementation for a method in a subclass that was already defined in the parent class."}',
              '{"front": "Explain Java\'s garbage collection.", "back": "Garbage collection automatically reclaims memory occupied by unused objects. The JVM identifies objects that are no longer being referenced and removes them to free up memory."}',
            ],
          },
        ),
        CategoryItem(
          name: 'JavaScript',
          icon: Icons.javascript,
          color: Colors.amber.shade700,
          flashcardData: {
            'javascript interview questions': [
              '{"front": "What is JavaScript?", "back": "JavaScript is a scripting language that enables dynamic content on web pages."}',
              '{"front": "What is the DOM?", "back": "Document Object Model (DOM) is a programming interface for web documents."}',
              '{"front": "Explain closures in JavaScript.", "back": "A closure is a function that has access to variables in its outer (enclosing) lexical scope, even after the outer function has returned. They\'re used to create private variables and function factories."}',
              '{"front": "What\'s the difference between let, const, and var?", "back": "var is function-scoped and can be redeclared. let is block-scoped and can be reassigned but not redeclared. const is block-scoped and cannot be reassigned or redeclared after initialization."}',
              '{"front": "What is hoisting in JavaScript?", "back": "Hoisting is JavaScript\'s default behavior of moving declarations to the top of the current scope before code execution. Variables defined with var are hoisted (initialized with undefined), while let and const variables are not initialized until their definition is evaluated."}',
              '{"front": "Explain event bubbling and event capturing.", "back": "Event bubbling is when an event triggers on the deepest target element and propagates upward. Event capturing is the opposite - events are first captured by the outermost element and propagated to the inner elements."}',
              '{"front": "What is the \'this\' keyword in JavaScript?", "back": "\'this\' refers to the object it belongs to. In a method, \'this\' refers to the owner object. In a function, \'this\' refers to the global object (in non-strict mode) or undefined (in strict mode). In an event, \'this\' refers to the element that received the event."}',
            ],
          },
        ),
        CategoryItem(
          name: 'C++',
          icon: Icons.code,
          color: Colors.indigo.shade600,
          flashcardData: {
            'c++ interview questions': [
              '{"front": "What is C++?", "back": "C++ is a general-purpose programming language created as an extension of the C language."}',
              '{"front": "What are pointers?", "back": "Pointers are variables that store memory addresses of other variables."}',
              '{"front": "What is the difference between stack and heap memory allocation?", "back": "Stack memory is used for static memory allocation (local variables, function calls) and is automatically managed. Heap memory is used for dynamic memory allocation (with new/delete) and must be manually managed by the programmer."}',
              '{"front": "Explain the difference between references and pointers.", "back": "References are like constant pointers that are always dereferenced and never null. Pointers can be reassigned, can be null, and must be dereferenced with * to access the value they point to."}',
              '{"front": "What is function overloading?", "back": "Function overloading allows multiple functions with the same name but different parameters (number, type, or order of parameters). The compiler determines which function to call based on the arguments provided."}',
              '{"front": "What are virtual functions and how do they work?", "back": "Virtual functions enable polymorphism in C++. They allow a function in a derived class to override a function in the base class. When accessed through a base class pointer, the derived class\'s implementation will be called if the function is marked as virtual."}',
              '{"front": "What is RAII?", "back": "Resource Acquisition Is Initialization (RAII) is a C++ programming technique where resource management is tied to object lifetime. Resources are acquired during object construction and released during object destruction, which helps prevent resource leaks."}',
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
          color: Colors.lightBlue.shade600,
          flashcardData: {
            'flutter interview questions': [
              '{"front": "What is Flutter?", "back": "Flutter is Google\'s UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase."}',
              '{"front": "What is a Widget?", "back": "Widgets are the basic building blocks of a Flutter app\'s user interface."}',
              '{"front": "What\'s the difference between StatelessWidget and StatefulWidget?", "back": "StatelessWidget is immutable and doesn\'t change its state during the lifetime of the widget. StatefulWidget can change its appearance in response to events and maintains state that might change during its lifetime."}',
              '{"front": "Explain the widget tree and rendering pipeline in Flutter.", "back": "Flutter\'s UI is built as a tree of widgets. When a widget\'s state changes, Flutter rebuilds the widget subtree. The rendering pipeline converts this widget tree to a render tree, then to a layer tree, and finally to the screen via the GPU."}',
              '{"front": "What is hot reload in Flutter?", "back": "Hot reload allows developers to see changes in the code reflected immediately in the running app without losing the current state, which significantly speeds up development."}',
              '{"front": "What are keys in Flutter and when should you use them?", "back": "Keys in Flutter uniquely identify widgets in the widget tree. They help Flutter distinguish between widgets when their state or configuration changes. Keys are essential when working with dynamic lists or when you need to maintain state across widget rebuilds."}',
              '{"front": "Explain the difference between main axis and cross axis in Flutter.", "back": "In a Row widget, the main axis runs horizontally and the cross axis runs vertically. In a Column widget, the main axis runs vertically and the cross axis runs horizontally. MainAxisAlignment and CrossAxisAlignment properties control how children are positioned along these axes."}',
            ],
          },
        ),
        CategoryItem(
          name: 'React Native',
          icon: Icons.smartphone,
          color: Colors.blue.shade700,
          flashcardData: {
            'react native interview questions': [
              '{"front": "What is React Native?", "back": "React Native is a framework for building native apps using React and JavaScript."}',
              '{"front": "What is JSX?", "back": "JSX is a syntax extension for JavaScript that looks similar to HTML and is used with React."}',
              '{"front": "What is the difference between React Native and React?", "back": "React is a JavaScript library for building web UIs using a virtual DOM. React Native uses React\'s architecture but renders to native mobile components instead of DOM elements, allowing for true native mobile apps using JavaScript."}',
              '{"front": "Explain the component lifecycle in React Native.", "back": "The main lifecycle phases are: Mounting (constructor, render, componentDidMount), Updating (render, componentDidUpdate), and Unmounting (componentWillUnmount). In modern React Native, functional components with hooks like useEffect are preferred."}',
              '{"front": "What are hooks in React Native?", "back": "Hooks are functions that let you use state and other React features in functional components. Common hooks include useState (for state management), useEffect (for side effects), useContext (for context), and useRef (for persistent mutable values)."}',
              '{"front": "How does React Native bridge work?", "back": "The bridge is a communication layer between JavaScript and native code. It allows JavaScript to call native modules and vice versa. JavaScript runs in a separate thread, and the bridge serializes data between JavaScript and native side asynchronously."}',
              '{"front": "What is the purpose of the FlatList component?", "back": "FlatList is a performant component for rendering scrollable lists. It renders items lazily, only creating components for items currently visible on screen, which improves performance for large lists."}',
            ],
          },
        ),
        CategoryItem(
          name: 'Android SDK',
          icon: Icons.android,
          color: Colors.green.shade600,
          flashcardData: {
            'android interview questions': [
              '{"front": "What is Android SDK?", "back": "Android SDK is a software development kit that enables developers to create applications for the Android platform."}',
              '{"front": "What is an Activity?", "back": "An Activity is a single, focused thing that the user can do in an Android app."}',
              '{"front": "Explain the Android activity lifecycle.", "back": "The Android activity lifecycle consists of these methods: onCreate() (activity is created), onStart() (becoming visible), onResume() (user interaction), onPause() (partially hidden), onStop() (fully hidden), onRestart() (restarting after stopped), and onDestroy() (activity is destroyed)."}',
              '{"front": "What are Intents in Android?", "back": "Intents are messaging objects used to request actions from components. Explicit intents specify the component to start by name, while implicit intents declare a general action to perform, allowing the system to find a component that can handle it."}',
              '{"front": "What is the Fragment lifecycle?", "back": "Fragments have their own lifecycle similar to activities: onAttach(), onCreate(), onCreateView(), onViewCreated(), onStart(), onResume(), onPause(), onStop(), onDestroyView(), onDestroy(), and onDetach()."}',
              '{"front": "What are Services in Android?", "back": "Services are components that run in the background to perform long-running operations or to perform work for remote processes. They don\'t provide a user interface and continue running even if the user switches to another application."}',
              '{"front": "What is the difference between SharedPreferences and SQLite Database?", "back": "SharedPreferences stores private primitive data in key-value pairs, good for small data like user settings. SQLite is a relational database for structured data storage when you need complex queries and larger datasets."}',
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
          color: Colors.cyan.shade600,
          flashcardData: {
            'react interview questions': [
              '{"front": "What is React?", "back": "React is a JavaScript library for building user interfaces, particularly single-page applications."}',
              '{"front": "What is JSX?", "back": "JSX is a syntax extension for JavaScript that looks similar to HTML and is used with React."}',
              '{"front": "What is the Virtual DOM?", "back": "The Virtual DOM is a lightweight copy of the actual DOM. React uses it to determine what parts of the actual DOM need to change when state changes, making UI updates more efficient."}',
              '{"front": "Explain the component lifecycle in React.", "back": "React components go through phases: Mounting (constructor, render, componentDidMount), Updating (render, componentDidUpdate), and Unmounting (componentWillUnmount). Modern React uses hooks like useEffect instead of these lifecycle methods."}',
              '{"front": "What are controlled components?", "back": "Controlled components are form elements whose values are controlled by React state. The state serves as the \'single source of truth\' for the input\'s value, and changes are handled through event handlers."}',
              '{"front": "What is Redux and when should you use it?", "back": "Redux is a state management library that helps manage application state in a predictable way. It\'s useful for applications with complex state logic, shared state across many components, or when you need time-travel debugging."}',
              '{"front": "What are React hooks?", "back": "Hooks are functions that let you use state and other React features in functional components. Common hooks include useState (state), useEffect (side effects), useContext (context API), useReducer (complex state logic), and useRef (persistent values)."}',
            ],
          },
        ),
        CategoryItem(
          name: 'Angular',
          icon: Icons.web_asset,
          color: Colors.red.shade600,
          flashcardData: {
            'angular interview questions': [
              '{"front": "What is Angular?", "back": "Angular is a platform and framework for building single-page client applications using HTML and TypeScript."}',
              '{"front": "What is a component?", "back": "Components are the building blocks of Angular applications."}',
              '{"front": "What is a service in Angular?", "back": "Services are singleton objects that provide shared functionality across the application. They\'re used for data sharing, implementing business logic, and external interactions like HTTP requests."}',
              '{"front": "Explain Angular directives.", "back": "Directives are instructions in the DOM that tell Angular how to render templates. There are three types: 1) Component directives (with templates), 2) Structural directives (change DOM layout, e.g., *ngIf, *ngFor), and 3) Attribute directives (change appearance or behavior, e.g., [ngClass])."}',
              '{"front": "What is dependency injection in Angular?", "back": "Dependency Injection (DI) is a design pattern where a class requests dependencies from external sources rather than creating them. Angular\'s DI system provides dependencies to a class when it\'s instantiated."}',
              '{"front": "What is Angular routing?", "back": "Angular Router enables navigation from one view to another as users perform application tasks. It\'s configured with paths that map to components, supports parameters, guards, and lazy loading of feature modules."}',
              '{"front": "What are observables in Angular?", "back": "Observables are a way to handle asynchronous data streams. Angular uses RxJS observables for event handling, asynchronous programming, and handling multiple values over time. They support operations like mapping, filtering, and error handling."}',
            ],
          },
        ),
        CategoryItem(
          name: 'Django',
          icon: Icons.language,
          color: Colors.green.shade700,
          flashcardData: {
            'django interview questions': [
              '{"front": "What is Django?", "back": "Django is a high-level Python web framework that encourages rapid development and clean, pragmatic design."}',
              '{"front": "What is MTV?", "back": "MTV stands for Model-Template-View, Django\'s software design pattern."}',
              '{"front": "Explain Django\'s request/response cycle.", "back": "The cycle includes: 1) Browser sends request to server, 2) Django\'s URL dispatcher routes the request to the appropriate view, 3) View processes the request using models if needed, 4) View returns an HTTP response, often rendering a template, 5) Response is sent back to the browser."}',
              '{"front": "What are Django migrations?", "back": "Migrations are Django\'s way of propagating changes made to models (adding fields, deleting models, etc.) into the database schema. They allow you to update your database schema without losing data."}',
              '{"front": "Explain Django\'s ORM.", "back": "Django\'s Object-Relational Mapper (ORM) allows developers to interact with databases using Python objects instead of SQL. It abstracts database operations, supports multiple database backends, and provides a high-level, Pythonic API for queries."}',
              '{"front": "What is middleware in Django?", "back": "Middleware is a framework of hooks into Django\'s request/response processing. It\'s a light, low-level plugin system for globally altering Django\'s input or output, such as for authentication, sessions, security, or CSRF protection."}',
              '{"front": "What are Django forms and how do they work?", "back": "Django forms handle form rendering, data validation, and conversion to Python types. They generate HTML forms, validate user input based on defined rules, clean data, and convert it to appropriate Python objects. They also handle CSRF protection."}',
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Practice Cards',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sections.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          section['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount:
                          (section['items'] as List<CategoryItem>).length,
                      itemBuilder: (context, index) {
                        final item =
                            (section['items'] as List<CategoryItem>)[index];
                        return _buildCategoryItem(context, item);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4299E1),
        child: const Icon(Icons.add, color: Colors.white),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item.color.withOpacity(0.8),
              item.color,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${item.flashcardData.values.expand((cards) => cards).length} Cards',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
