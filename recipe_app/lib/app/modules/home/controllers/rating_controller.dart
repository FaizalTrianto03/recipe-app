import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RatingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var averageRating = 0.0.obs;
  var totalRatings = 0.obs;
  var reviews = <Map<String, dynamic>>[].obs;

  // Fetch ratings and calculate average
  void fetchRatingsData(String mealId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('mealId', isEqualTo: mealId)
        .get();

    double totalScore = 0;
    int count = 0;
    var fetchedReviews = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      totalScore += data['rating'];
      count++;
      fetchedReviews.add({
        'id': doc.id,
        'rating': data['rating'],
        'review': data['review'],
        'userEmail': data['userEmail'],
        'timestamp': data['timestamp'],
      });
    }

    averageRating.value = count > 0 ? totalScore / count : 0.0;
    totalRatings.value = count;
    reviews.value = fetchedReviews;
  }

  // Submit a new review
  Future<void> submitReview(String mealId, int rating, String review, BuildContext context) async {
    final User? user = _auth.currentUser;
    final userEmail = user?.email;

    if (userEmail != null && rating > 0 && review.isNotEmpty) {
      await _firestore.collection('reviews').add({
        'mealId': mealId,
        'rating': rating,
        'review': review,
        'userEmail': userEmail,
        'timestamp': Timestamp.now(),
      });
      fetchRatingsData(mealId);
      Navigator.of(context).pop(); // Close modal after submission
    }
  }

  // Update an existing review
  Future<void> updateReview(String reviewId, int newRating, String newReview, BuildContext context) async {
    await _firestore.collection('reviews').doc(reviewId).update({
      'rating': newRating,
      'review': newReview,
      'timestamp': Timestamp.now(), // Update timestamp for modified reviews
    });
    fetchRatingsData(reviewId);
    Navigator.of(context).pop(); // Close modal after updating
  }

  // Delete a review by ID
  Future<void> deleteReview(String reviewId, BuildContext context) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
    Navigator.of(context).pop(); // Close modal after deletion
  }
}
