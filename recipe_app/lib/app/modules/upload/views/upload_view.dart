import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import '../controllers/upload_controller.dart'; // Adjust the import path as necessary
import 'my_recipe_view.dart'; // Import the MyRecipeView
import 'package:recipe_app/app/widgets/custom_bottom_nav_bar.dart'; // Custom Bottom Navigation

class UploadView extends StatelessWidget {
  const UploadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the UploadController instance
    final uploadController = Get.find<UploadController>();
    final primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 3, // Three tabs: Ingredients, Instructions, More
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Add Recipes'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark), // Save icon
              color: primaryColor,
              onPressed: () {
                // Navigate to MyRecipeListView when bookmark is pressed
                Get.toNamed(
                    '/my-recipe-list-view'); // Use the route for MyRecipeListView
              },
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Ingredients'),
              Tab(text: 'Instructions'),
              Tab(text: 'More'),
            ],
            labelColor: primaryColor,
            indicatorColor: primaryColor,
          ),
        ),

        body: SafeArea(
          child: TabBarView(
            children: [
              // Ingredients Tab
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker
                    Obx(() => _buildImagePicker(uploadController)),
                    const SizedBox(height: 24),

                    // Meal Name
                    _buildTextField(
                      controller: uploadController.mealNameController,
                      label: 'Meal Name',
                    ),
                    const SizedBox(height: 16),

                    // Calories and Time in a single row for better layout
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: uploadController.caloriesController,
                            label: 'Calories',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: uploadController.timeController,
                            label: 'Prep Time (mins)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Category and Area Dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => _buildDropdownField(
                                label: 'Category',
                                value: uploadController.selectedCategory.value,
                                items: uploadController.categories,
                                onChanged: (value) => uploadController
                                    .selectedCategory.value = value ?? '',
                              )),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() => _buildDropdownField(
                                label: 'Area',
                                value: uploadController.selectedArea.value,
                                items: uploadController.areas,
                                onChanged: (value) => uploadController
                                    .selectedArea.value = value ?? '',
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Ingredients List and Add Ingredient Fields
                    Obx(() => _buildIngredientList(uploadController)),
                    const SizedBox(height: 16),
                    _buildAddIngredientFields(uploadController),
                  ],
                ),
              ),

              // Instructions Tab
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => _buildInstructionList(uploadController)),
                    const SizedBox(height: 16),
                    _buildAddInstructionField(uploadController),
                  ],
                ),
              ),

              // More Tab (Tags, YouTube Link, Article Link)
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: uploadController.tagsController,
                      label: 'Tags (Optional)',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: uploadController.youtubeLinkController,
                      label: 'YouTube Link (Optional)',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: uploadController.articleLinkController,
                      label: 'Article Link (Optional)',
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: uploadController.saveMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Save Recipe',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(), // Custom Bottom Navigation
      ),
    );
  }

  // Image Picker Widget
  Widget _buildImagePicker(UploadController controller) {
    return GestureDetector(
      onTap: controller.pickImage,
      child: DottedBorder(
        color: Colors.grey.shade400,
        strokeWidth: 1,
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [6, 4],
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: controller.imageUrl.value != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(controller.imageUrl.value!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 48, color: Colors.grey.shade600),
                    const SizedBox(height: 8),
                    Text('Tap to add a photo',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
        ),
      ),
    );
  }

  // Text Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text, // Default to text input
  }) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Dropdown Field Widget
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: value.isEmpty ? null : value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  // Ingredient List Widget
  Widget _buildIngredientList(UploadController controller) {
    return Column(
      children: controller.ingredients.map((ingredient) {
        int index = controller.ingredients.indexOf(ingredient);
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Image.network(
              ingredient['image'],
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported),
            ),
            title: Text(
              '${ingredient['ingredient']} (${ingredient['measure']})',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
              onPressed: () => controller.removeIngredient(index),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Add Ingredient Fields
  Widget _buildAddIngredientFields(UploadController controller) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    return Column(
      children: [
        _buildAutoCompleteField(
          controller: controller.currentIngredientNameController,
          label: 'Ingredient',
          suggestions: controller.ingredientList,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.currentMeasureController,
          label: 'Measure',
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: controller.addIngredient,
          icon: const Icon(Icons.add),
          label: const Text('Add Ingredient'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // Instruction List Widget
  Widget _buildInstructionList(UploadController controller) {
    return Column(
      children: controller.instructions.map((instruction) {
        int index = controller.instructions.indexOf(instruction);
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(
              '${index + 1}. $instruction',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
              onPressed: () => controller.removeInstruction(index),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Add Instruction Field
  Widget _buildAddInstructionField(UploadController controller) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: controller.currentInstructionController,
            label: 'Instruction',
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: controller.addInstruction,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
          ),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  // Autocomplete TextField for Ingredients
  Widget _buildAutoCompleteField({
    required TextEditingController controller,
    required String label,
    required List<String> suggestions,
  }) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        } else {
          return suggestions.where((suggestion) => suggestion
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase()));
        }
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey.shade700),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      },
    );
  }

  // Recipe Card Widget
  Widget _buildRecipeCard(Map<String, dynamic> meal) {
    return GestureDetector(
      onTap: () {
        // Navigate to MyRecipeView when the card is tapped
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                image: DecorationImage(
                  image: meal['strMealThumb'] != null &&
                          File(meal['strMealThumb']).existsSync()
                      ? FileImage(File(meal['strMealThumb']))
                      : const AssetImage('assets/placeholder.png')
                          as ImageProvider,
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
