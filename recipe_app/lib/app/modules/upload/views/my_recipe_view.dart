// lib/app/modules/upload/views/my_recipe_view.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/upload_controller.dart';

class MyRecipeView extends StatelessWidget {
  final Map<String, dynamic> meal;

  const MyRecipeView({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UploadController uploadController = Get.find<UploadController>();

    // Extract ingredients
    final ingredients = meal['ingredients'] as List<dynamic>? ?? [];

    // Split instructions into a list
    final instructions =
        (meal['strInstructions'] as String?)?.split('\n') ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(meal['strMeal'] ?? 'Recipe'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Confirm deletion with the user
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor:
                      Colors.white, // Set the background color to white
                  title: Text(
                    'Delete Recipe',
                    style: TextStyle(
                        color: Theme.of(context)
                            .primaryColor), // Set title text color
                  ),
                  content: Text(
                    'Are you sure you want to delete this recipe?',
                    style: TextStyle(
                        color: Theme.of(context)
                            .primaryColor), // Set content text color
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(), // Close the dialog
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: Colors.white), // Set button text color
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Delete the meal
                        uploadController.deleteMeal(meal['idMeal']);
                        Get.toNamed('/upload'); // Close the dialog
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(
                            color: Colors.white), // Set button text color
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Image
            if (meal['strMealThumb'] != null &&
                File(meal['strMealThumb']).existsSync())
              Image.file(
                File(meal['strMealThumb']),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
            else
              Image.asset(
                'assets/placeholder.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            // Meal Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                meal['strMeal'] ?? 'No Name',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            // Category and Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${meal['strCategory'] ?? 'Unknown'} - ${meal['strArea'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            // Calories and Time
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (meal['strCalories'] != null &&
                      meal['strCalories'].isNotEmpty)
                    Text(
                      'Calories: ${meal['strCalories']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(width: 16),
                  if (meal['strTime'] != null && meal['strTime'].isNotEmpty)
                    Text(
                      'Time: ${meal['strTime']} mins',
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Ingredients
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Ingredients',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...ingredients.map<Widget>((ingredient) {
              return ListTile(
                leading: Image.network(
                  ingredient['image'],
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
                title: Text(
                    '${ingredient['ingredient']} (${ingredient['measure']})'),
              );
            }).toList(),
            const SizedBox(height: 16),
            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Instructions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: instructions.map((instruction) {
                  final index = instructions.indexOf(instruction) + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('$index. $instruction'),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
