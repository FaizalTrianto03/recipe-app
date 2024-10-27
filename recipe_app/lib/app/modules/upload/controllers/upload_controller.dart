import 'dart:convert';
// import 'dart:io'; // Required for File operations
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadController extends GetxController {
  // Initialize GetStorage for local storage
  final storage = GetStorage();
  // Initialize ImagePicker for picking images
  final picker = ImagePicker();

  // **Text Controllers** for form fields
  final mealNameController = TextEditingController();
  final caloriesController = TextEditingController(); // For Calories input
  final timeController = TextEditingController(); // For Preparation Time input
  final tagsController = TextEditingController();
  final youtubeLinkController = TextEditingController();
  final currentIngredientNameController = TextEditingController();
  final currentMeasureController = TextEditingController();
  final currentInstructionController = TextEditingController();
  final articleLinkController = TextEditingController(); // New controller for Article Link

  // **Reactive variables** using Rx types from GetX
  Rx<String?> imageUrl = Rx<String?>(null); // Stores the selected image path
  RxList<String> instructions = RxList<String>([]); // List of instructions
  RxList<Map<String, dynamic>> ingredients = RxList<Map<String, dynamic>>([]); // List of ingredients

  // **Dropdown selections**
  RxString selectedCategory = ''.obs; // Selected category
  RxString selectedArea = ''.obs; // Selected area

  // **Lists populated from API**
  RxList<String> categories = RxList<String>([]); // List of categories
  RxList<String> areas = RxList<String>([]); // List of areas
  RxList<String> ingredientList = RxList<String>([]); // List of available ingredients

  // **Saved meals**
  RxList<Map<String, dynamic>> savedMeals = RxList<Map<String, dynamic>>([]); // List of saved meals

  @override
  void onInit() {
    super.onInit();
    // Fetch data from APIs when the controller is initialized
    fetchCategories();
    fetchAreas();
    fetchIngredients();
    loadSavedMeals();
  }

  // **Fetch categories from API**
  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?c=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categoriesData = data['meals'];
      categories.addAll(categoriesData.map((category) => category['strCategory'] as String).toList());
    } else {
      Get.snackbar('Error', 'Failed to fetch categories.');
    }
  }

  // **Fetch areas from API**
  Future<void> fetchAreas() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?a=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List areasData = data['meals'];
      areas.addAll(areasData.map((area) => area['strArea'] as String).toList());
    } else {
      Get.snackbar('Error', 'Failed to fetch areas.');
    }
  }

  // **Fetch ingredients from API**
  Future<void> fetchIngredients() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?i=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List ingredientsData = data['meals'];
      ingredientList.addAll(ingredientsData.map((ingredient) => ingredient['strIngredient'] as String).toList());
    } else {
      Get.snackbar('Error', 'Failed to fetch ingredients.');
    }
  }

  // **Load saved meals from local storage**
  void loadSavedMeals() {
    List<dynamic> meals = storage.read('meals') ?? [];
    savedMeals.value = meals.cast<Map<String, dynamic>>();
  }

  // **Pick image using ImagePicker**
  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageUrl.value = pickedFile.path;
      } else {
        Get.snackbar('No Image Selected', 'Please select an image.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // **Add Ingredient to the ingredients list**
  Future<void> addIngredient() async {
    final ingredientName = currentIngredientNameController.text.trim();
    final measure = currentMeasureController.text.trim();

    if (ingredientName.isNotEmpty && measure.isNotEmpty) {
      // Construct the image URL for the ingredient
      final ingredientImageUrl =
          'https://www.themealdb.com/images/ingredients/${Uri.encodeComponent(ingredientName)}.png';

      ingredients.add({
        'ingredient': ingredientName,
        'measure': measure,
        'image': ingredientImageUrl,
      });

      // Clear input fields after adding
      currentIngredientNameController.clear();
      currentMeasureController.clear();
    } else {
      Get.snackbar('Error', 'Please enter both ingredient and measure.');
    }
  }

  // **Remove Ingredient from the ingredients list**
  void removeIngredient(int index) {
    ingredients.removeAt(index);
  }

  // **Add Instruction to the instructions list**
  void addInstruction() {
    final instruction = currentInstructionController.text.trim();
    if (instruction.isNotEmpty) {
      instructions.add(instruction);
      currentInstructionController.clear();
    } else {
      Get.snackbar('Error', 'Please enter an instruction.');
    }
  }

  // **Remove Instruction from the instructions list**
  void removeInstruction(int index) {
    instructions.removeAt(index);
  }

  // **Save Meal to local storage**
  void saveMeal() {
    // Validation to ensure at least one ingredient and one instruction
    if (ingredients.isEmpty) {
      Get.snackbar('Error', 'Please add at least one ingredient.');
      return;
    }

    if (instructions.isEmpty) {
      Get.snackbar('Error', 'Please add at least one instruction.');
      return;
    }

    if (mealNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter the meal name.');
      return;
    }

    final meal = {
      "strMeal": mealNameController.text.trim(),
      "strCalories": caloriesController.text.trim(), // Add calories
      "strTime": timeController.text.trim(), // Add preparation time
      "strCategory": selectedCategory.value,
      "strArea": selectedArea.value,
      "strInstructions": instructions.join("\n"),
      "strMealThumb": imageUrl.value,
      "strTags": tagsController.text.trim(),
      "strYoutube": youtubeLinkController.text.trim(),
      "strArticle": articleLinkController.text.trim(), // Save article link
      "ingredients": ingredients,
    };

    // Generate a unique ID for the meal
    int id = storage.read('meal_id') ?? 1;
    meal['idMeal'] = id.toString();

    // Retrieve existing meals and add the new one
    List<dynamic> meals = storage.read('meals') ?? [];
    meals.add(meal);

    // Save meals and increment the ID for future meals
    storage.write('meals', meals);
    storage.write('meal_id', id + 1);

    // Update the reactive savedMeals list
    savedMeals.value = meals.cast<Map<String, dynamic>>();

    // Clear form fields after saving
    clearFields();
    Get.snackbar('Success', 'Recipe saved successfully!');
  }

  // **Delete Meal Method**
  void deleteMeal(String idMeal) {
    // Remove the meal from the savedMeals list
    savedMeals.removeWhere((meal) => meal['idMeal'] == idMeal);

    // Update local storage
    storage.write('meals', savedMeals);

    // Show a confirmation message
    Get.snackbar('Deleted', 'Recipe has been deleted.');
  }

  // **Clear all input fields and reset selections**
  void clearFields() {
    mealNameController.clear();
    caloriesController.clear();
    timeController.clear();
    tagsController.clear();
    youtubeLinkController.clear();
    currentIngredientNameController.clear();
    currentMeasureController.clear();
    currentInstructionController.clear();
    articleLinkController.clear(); // Clear article link
    imageUrl.value = null;
    instructions.clear();
    ingredients.clear();
    selectedCategory.value = '';
    selectedArea.value = '';
  }

  @override
  void onClose() {
    // Dispose of controllers to free up resources
    mealNameController.dispose();
    caloriesController.dispose();
    timeController.dispose();
    tagsController.dispose();
    youtubeLinkController.dispose();
    currentIngredientNameController.dispose();
    currentMeasureController.dispose();
    currentInstructionController.dispose();
    articleLinkController.dispose(); // Dispose article link controller
    super.onClose();
  }
}
