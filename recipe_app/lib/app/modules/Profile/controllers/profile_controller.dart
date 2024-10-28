import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final picker = ImagePicker();
  RxString profileImage = ''.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void onInit() {
    super.onInit();
    fetchProfileImage(); 
  }

  Future<void> fetchProfileImage() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc['profileImage'] != null) {
        profileImage.value = doc['profileImage'];
      }
    }
  }

  void showImageSourceDialog() {
    Get.defaultDialog(
      title: "Select Image Source",
      content: Column(
        children: [
          TextButton(
            onPressed: () {
              pickImage(ImageSource.camera);
              Get.back();
            },
            child: Text("Camera"),
          ),
          TextButton(
            onPressed: () {
              pickImage(ImageSource.gallery);
              Get.back();
            },
            child: Text("Gallery"),
          ),
        ],
      ),
    );
  }

  Future<void> pickProfileImage() async {
    showImageSourceDialog();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        String filePath = pickedFile.path;
        await uploadProfileImageToStorage(filePath);
      } else {
        Get.snackbar('No Image Selected', 'Please select an image.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> uploadProfileImageToStorage(String filePath) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        Reference storageRef = _storage.ref().child('profileImages').child('${user.uid}.jpg');

        UploadTask uploadTask = storageRef.putFile(File(filePath));

        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();

        await updateProfileImageUrl(downloadUrl);
      } catch (e) {
        Get.snackbar('Error', 'Failed to upload image: $e');
      }
    }
  }

  Future<void> updateProfileImageUrl(String imageUrl) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'profileImage': imageUrl,
        });
        profileImage.value = imageUrl; // Update lokal
        Get.snackbar('Success', 'Profile image updated successfully!');
      } catch (e) {
        print('Error updating profile image URL: $e');
        Get.snackbar('Error', 'Failed to update profile image: $e');
      }
    }
  }

  void confirmLogout() {
    Get.defaultDialog(
      title: "Logout Confirmation",
      content: Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            logout();
            Get.back();
          },
          child: Text("Logout"),
        ),
      ],
    );
  }

  void logout() {
    try {
      _auth.signOut();
      Get.snackbar('Success', 'You have logged out successfully.');
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e');
    }
  }
}
