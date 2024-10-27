// lib/app/modules/upload/views/my_recipe_start_cooking.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/upload_controller.dart';

class MyRecipeStartCooking extends StatefulWidget {
  final Map<String, dynamic> meal;

  const MyRecipeStartCooking({Key? key, required this.meal}) : super(key: key);

  @override
  _MyRecipeStartCookingState createState() => _MyRecipeStartCookingState();
}

class _MyRecipeStartCookingState extends State<MyRecipeStartCooking> {
  final UploadController uploadController = Get.find<UploadController>();
  int currentStep = 0;
  late final Color primaryColor;

  @override
  void initState() {
    super.initState();
    // Avoid accessing Theme.of(context) here
    // Initialize primaryColor in build or didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    primaryColor = Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    // Extract instructions
    final instructions = (widget.meal['strInstructions'] as String?)?.split('\n') ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Start Cooking'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: instructions.isNotEmpty
          ? Column(
              children: [
                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: LinearProgressIndicator(
                    value: (currentStep + 1) / instructions.length,
                    backgroundColor: Colors.grey.shade300,
                    color: primaryColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 10),

                // Step Count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Step ${currentStep + 1} of ${instructions.length}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // Instruction Text
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      instructions[currentStep],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Button
                      ElevatedButton(
                        onPressed: currentStep > 0
                            ? () {
                                setState(() {
                                  currentStep--;
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Previous', style: TextStyle(fontSize: 16)),
                      ),
                      // Next or Finish Button
                      ElevatedButton(
                        onPressed: currentStep < instructions.length - 1
                            ? () {
                                setState(() {
                                  currentStep++;
                                });
                              }
                            : () {
                                // Finish Cooking
                                Get.back();
                                Get.snackbar(
                                  'Congratulations!',
                                  'You have completed the recipe.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.shade600,
                                  colorText: Colors.white,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          currentStep < instructions.length - 1 ? 'Next' : 'Finish',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                'No instructions available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
    );
  }
}
