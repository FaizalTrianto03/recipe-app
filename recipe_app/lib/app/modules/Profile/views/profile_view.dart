import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  File? _profileImage;

  @override
  void dispose() {
    _usernameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _updateField(String field, String value) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          field: value,
        });
        if (mounted) {
          _showUpdateNotification('$field berhasil diperbarui');
        }
      } catch (e) {
        print('Error updating $field: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: Text('Camera', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: Text('Gallery', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _profileImage = File(pickedFile.path);
          });
          await _saveImageToFirestore();
        }
      }
    }
  }

  Future<void> _saveImageToFirestore() async {
    final User? user = _auth.currentUser;
    if (user != null && _profileImage != null) {
      try {
        final bytes = await _profileImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        await _updateField('profileImage', base64Image);
      } catch (e) {
        print('Error saving profile image: $e');
      }
    }
  }

  void _showUpdateNotification(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
            ),
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                Get.offAllNamed('/login');
              },
              child: Text('Logout', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? Center(child: Text('No user logged in'))
          : FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(user.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('User data not found'));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final String name = userData['name'] ?? 'No Name';
                final String email = userData['email'] ?? 'No Email';
                final String username = userData['username'] ?? 'username';
                _usernameController.text = username;
                _addressController.text = userData['address'] ?? '';
                _dobController.text = userData['dob'] ?? '';
                final String? base64Image = userData['profileImage'];

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: base64Image != null
                              ? MemoryImage(base64Decode(base64Image))
                              : null,
                          backgroundColor: Colors.deepOrange,
                          child: base64Image == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Email: $email',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),
                      _buildEditableField('Username', _usernameController, 'username'),
                      _buildEditableField('Address', _addressController, 'address'),
                      _buildEditableField('Date of Birth', _dobController, 'dob'),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showLogoutConfirmation, // Show logout confirmation dialog
                        child: Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, String field) {
    return ListTile(
      title: Text(label),
      subtitle: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final newValue = await _showEditDialog(label, controller.text);
              if (newValue != null && newValue.isNotEmpty) {
                setState(() {
                  controller.text = newValue;
                });
                _updateField(field, newValue);
              }
            },
          ),
        ),
        readOnly: true,
      ),
    );
  }

  Future<String?> _showEditDialog(String label, String currentValue) {
    final TextEditingController dialogController = TextEditingController(text: currentValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: dialogController,
          decoration: InputDecoration(hintText: 'Enter new $label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepOrange,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(dialogController.text),
            child: Text('Save', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }
}
