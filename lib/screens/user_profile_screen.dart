// user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resumehub/authentication/intropage.dart';
import 'package:file_picker/file_picker.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form key to validate inputs
  final _formKey = GlobalKey<FormState>();

  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _testFirestoreWrite(); // Test Firestore connectivity
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  // Test Firestore write capability
  Future<void> _testFirestoreWrite() async {
    try {
      await _firestore.collection('test').doc('test').set({
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Test write successful - Firestore connectivity is working');
    } catch (e) {
      print('Test write failed: $e');
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      User? user = _auth.currentUser;
      print('Current user: ${user?.uid}');

      if (user != null) {
        // Email is directly available from Firebase Auth
        _emailController.text = user.email ?? 'Email not available';

        // Get display name from Firebase Auth
        _nameController.text = user.displayName ?? 'Name not available';

        // Get additional profile data from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        print('User document exists: ${userDoc.exists}');

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          _phoneController.text = userData['phone'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _linkedinController.text = userData['linkedin'] ?? '';
          print('User data loaded successfully');
        } else {
          print('User document does not exist, creating new document');
          // Create a new document for the user if it doesn't exist
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        print('No user is currently logged in');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading user data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    print('_saveUserData method called');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      User? user = _auth.currentUser;
      print('Current user for saving: ${user?.uid}');

      if (user != null) {
        // Update display name in Firebase Auth
        await user.updateDisplayName(_nameController.text);
        print('Display name updated in Firebase Auth');

        // Update additional profile data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'linkedin': _linkedinController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('User data updated in Firestore');

        setState(() {
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        throw Exception('No user logged in');
      }
    } catch (e, stackTrace) {
      print('Error saving user data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Future<void> _uploadResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        // Here you would upload the file to Firebase Storage
        // and save the reference in Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Resume uploaded: ${result.files.single.name}')),
        );
      }
    } catch (e) {
      print('Error uploading resume: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload resume: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  print('Edit mode activated: $_isEditing');
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Profile avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6E8EFB), Color(0xFFA777E3)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(_nameController.text),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _nameController.text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Current Edit Status Debug Text
                      Text(
                        'Edit Mode: $_isEditing',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Profile info sections
                      _buildProfileField(
                        'Full Name',
                        Icons.person_outline,
                        _nameController,
                        _isEditing,
                      ),
                      const SizedBox(height: 16),

                      _buildProfileField(
                        'Email',
                        Icons.email_outlined,
                        _emailController,
                        false, // Email is not editable
                      ),
                      const SizedBox(height: 16),

                      _buildProfileField(
                        'Phone',
                        Icons.phone_outlined,
                        _phoneController,
                        _isEditing,
                      ),
                      const SizedBox(height: 16),

                      _buildProfileField(
                        'Location',
                        Icons.location_on_outlined,
                        _locationController,
                        _isEditing,
                      ),
                      const SizedBox(height: 16),

                      _buildProfileField(
                        'LinkedIn',
                        Icons.link_outlined,
                        _linkedinController,
                        _isEditing,
                      ),
                      const SizedBox(height: 30),

                      // Save profile button (only visible in edit mode)
                      if (_isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveUserData,
                            icon: _isSaving
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(2.0),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label:
                                Text(_isSaving ? 'Saving...' : 'Save Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                      if (_isEditing) const SizedBox(height: 16),

                      // Cancel button (only visible in edit mode)
                      if (_isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                print('Edit mode cancelled: $_isEditing');
                                _loadUserData(); // Reload data to discard changes
                              });
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                      if (_isEditing) const SizedBox(height: 30),

                      // Resume options - only visible when not editing
                      if (!_isEditing) const Divider(height: 40),

                      if (!_isEditing)
                        const Text(
                          'Resume Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      if (!_isEditing) const SizedBox(height: 20),

                      // Create Resume button
                      if (!_isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed("build_option_page");
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Create New Resume'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                      if (!_isEditing) const SizedBox(height: 16),

                      // Upload Resume button
                      if (!_isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _uploadResume,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Existing Resume'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                      if (!_isEditing) const SizedBox(height: 30),

                      // Sign out button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _auth.signOut();
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WelcomeScreen()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == 'Name not available') return '?';

    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  Widget _buildProfileField(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isEditable,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                isEditable
                    ? TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (value) {
                          if (label == 'Full Name' &&
                              (value == null || value.isEmpty)) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      )
                    : Text(
                        controller.text.isEmpty
                            ? 'Not provided'
                            : controller.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
