import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final picker = ImagePicker();
  RxString profileImage = ''.obs; // Menyimpan URL gambar profil
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchProfileImage(); // Mengambil gambar profil saat inisialisasi
  }

  // Mengambil gambar profil dari Firestore
  Future<void> fetchProfileImage() async {
    // Ganti 'userId' dengan ID pengguna yang sesuai
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc['profileImage'] != null) {
        profileImage.value = doc['profileImage'];
      }
    }
  }

  // Menampilkan dialog untuk memilih sumber gambar
  void showImageSourceDialog() {
    Get.defaultDialog(
      title: "Select Image Source",
      content: Column(
        children: [
          TextButton(
            onPressed: () {
              pickImage(ImageSource.camera);
              Get.back(); // Menutup dialog
            },
            child: Text("Camera"),
          ),
          TextButton(
            onPressed: () {
              pickImage(ImageSource.gallery);
              Get.back(); // Menutup dialog
            },
            child: Text("Gallery"),
          ),
        ],
      ),
    );
  }

  // Memanggil dialog pemilihan gambar
  Future<void> pickProfileImage() async {
    showImageSourceDialog(); // Panggil dialog untuk memilih sumber gambar
  }

  // Memilih gambar dari sumber yang ditentukan
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        String imageUrl = pickedFile.path; // Mendapatkan path gambar lokal
        updateProfileImageUrl(imageUrl); // Memperbarui URL gambar profil di Firestore
      } else {
        Get.snackbar('No Image Selected', 'Please select an image.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Memperbarui URL gambar profil di Firestore
  Future<void> updateProfileImageUrl(String imageUrl) async {
    // Ganti 'userId' dengan ID pengguna yang sesuai
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

  // Menampilkan konfirmasi sebelum logout
  void confirmLogout() {
    Get.defaultDialog(
      title: "Logout Confirmation",
      content: Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Menutup dialog
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            logout();
            Get.back(); // Menutup dialog
          },
          child: Text("Logout"),
        ),
      ],
    );
  }

  // Fungsi logout
  void logout() {
    try {
      _auth.signOut();
      Get.snackbar('Success', 'You have logged out successfully.');
      // Navigasi ke halaman login jika diperlukan
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e');
    }
  }
}
