import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _profileImage;

  bool _isEditing = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _updateField(String field, dynamic value) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({field: value});
        _showUpdateNotification('$field successfully updated');
      } catch (e) {
        print('Error updating $field: $e');
      }
    }
  }

Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final shouldSave = await _showConfirmationDialog();
    if (shouldSave == true) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _saveImageToFirestore();
    }
  }
}

Future<bool?> _showConfirmationDialog() {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirm Save'),
        content: Text('Do you want to save this profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      );
    },
  );
}

  Future<void> _saveImageToFirestore() async {
    final User? user = _auth.currentUser;
    if (user != null && _profileImage != null) {
      try {
        String fileName = 'profileImages/${user.uid}.jpg'; 
        UploadTask uploadTask = _storage.ref(fileName).putFile(_profileImage!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL(); 
        
        await _updateField('profileImage', downloadUrl);
      } catch (e) {
        print('Error saving profile image: $e');
      }
    }
  }

  void _showUpdateNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _clearProfileData() async {
    _usernameController.clear();
    _addressController.clear();
    _dobController.clear();
    _bioController.clear();

    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'username': '',
          'address': '',
          'dob': '',
          'bio': '',
          'profileImage': '',
        });
        _showUpdateNotification('Profile data cleared successfully');
      } catch (e) {
        print('Error clearing profile data: $e');
      }
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(backgroundColor: Colors.green),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    });

    if (shouldLogout == true) {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login'); // Replace with the correct login route
    }
  }

  void _deleteField(String field) {
    setState(() {
      if (field == 'username') {
        _usernameController.clear();
      } else if (field == 'address') {
        _addressController.clear();
      } else if (field == 'dob') {
        _dobController.clear();
      } else if (field == 'bio') {
        _bioController.clear();
      }
    });

    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        _firestore.collection('users').doc(user.uid).update({field: ''});
        _showUpdateNotification('$field cleared successfully');
      } catch (e) {
        print('Error clearing $field: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
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
                _usernameController.text = userData['username'] ?? '';
                _addressController.text = userData['address'] ?? '';
                _dobController.text = userData['dob'] ?? '';
                _bioController.text = userData['bio'] ?? '';
                final String? profileImageUrl = userData['profileImage'];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          backgroundColor: Colors.deepOrange,
                          child: profileImageUrl == null || profileImageUrl.isEmpty
                              ? Icon(Icons.person, size: 70, color: Colors.white)
                              : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(userData['name'] ?? 'No Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(userData['email'] ?? 'No Email', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 30),
                      _buildEditableField('Username', _usernameController, 'username'),
                      _buildEditableField('Address', _addressController, 'address'),
                      _buildEditableField('Date of Birth', _dobController, 'dob'),
                      _buildEditableField('Bio', _bioController, 'bio'),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isEditing)
                            ElevatedButton(
                              onPressed: _clearProfileData,
                              child: Text('Clear Profile Data'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            ),
                          SizedBox(width: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_isEditing) {
                                  _updateField('username', _usernameController.text);
                                  _updateField('address', _addressController.text);
                                  _updateField('dob', _dobController.text);
                                  _updateField('bio', _bioController.text);
                                  _usernameController.clear();
                                  _addressController.clear();
                                  _dobController.clear();
                                  _bioController.clear();
                                }
                                _isEditing = !_isEditing;
                              });
                            },
                            icon: Icon(_isEditing ? Icons.save : Icons.edit),
                            label: Text(_isEditing ? 'Save' : 'Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEditing ? Colors.green : Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, String fieldName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(),
              ),
              enabled: _isEditing,
            ),
          ),
          SizedBox(width: 10),
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteField(fieldName),
            ),
        ],
      ),
    );
  }
}
