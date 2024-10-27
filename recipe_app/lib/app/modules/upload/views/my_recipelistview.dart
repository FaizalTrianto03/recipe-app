import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/upload_controller.dart'; // Adjust the import path as necessary
import 'my_recipe_view.dart'; // Import the MyRecipeView

class MyRecipeListView extends StatelessWidget {
  const MyRecipeListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uploadController = Get.find<UploadController>();
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Obx(() {
          final savedMeals = uploadController.savedMeals;
          if (savedMeals.isEmpty) {
            return const Center(child: Text('No recipes saved.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: savedMeals.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final meal = savedMeals[index];
                return _buildRecipeCard(meal, primaryColor);
              },
            ),
          );
        }),
      ),
    );
  }

  // Recipe Card Widget
  Widget _buildRecipeCard(Map<String, dynamic> meal, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        // Navigate to MyRecipeView with the selected meal as an argument
        Get.to(() => MyRecipeView(meal: meal));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        shadowColor: Colors.grey.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 120, // Set a fixed height for the image
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                image: DecorationImage(
                  image: meal['strMealThumb'] != null && File(meal['strMealThumb']).existsSync()
                      ? FileImage(File(meal['strMealThumb']))
                      : const AssetImage('assets/placeholder.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Information Section
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Name
                  Text(
                    meal['strMeal'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Calories and Time
                  Text(
                    'Calories: ${meal['strCalories'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Time: ${meal['strTime'] ?? 'N/A'} mins',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
