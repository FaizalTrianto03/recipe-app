import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadController extends GetxController {
  final storage = GetStorage();
  final picker = ImagePicker();

  final mealNameController = TextEditingController();
  final caloriesController = TextEditingController();
  final timeController = TextEditingController();
  final tagsController = TextEditingController();
  final youtubeLinkController = TextEditingController();
  final currentIngredientNameController = TextEditingController();
  final currentMeasureController = TextEditingController();
  final currentInstructionController = TextEditingController();

  Rx<String?> imageUrl = Rx<String?>(null);
  RxList<String> instructions = RxList<String>([]);
  RxList<Map<String, dynamic>> ingredients = RxList<Map<String, dynamic>>([]);

  RxString selectedCategory = ''.obs;
  RxString selectedArea = ''.obs;

  RxList<String> categories = RxList<String>([]);
  RxList<String> areas = RxList<String>([]);
  RxList<String> ingredientList = RxList<String>([]);

  RxList<Map<String, dynamic>> savedMeals = RxList<Map<String, dynamic>>([]);

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchAreas();
    fetchIngredients();
    loadSavedMeals();
  }

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

  void loadSavedMeals() {
    List<dynamic> meals = storage.read('meals') ?? [];
    savedMeals.value = meals.cast<Map<String, dynamic>>();
  }

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

  Future<void> addIngredient() async {
    final ingredientName = currentIngredientNameController.text.trim();
    final measure = currentMeasureController.text.trim();

    if (ingredientName.isNotEmpty && measure.isNotEmpty) {
      final ingredientImageUrl =
          'https://www.themealdb.com/images/ingredients/${Uri.encodeComponent(ingredientName)}.png';

      ingredients.add({
        'ingredient': ingredientName,
        'measure': measure,
        'image': ingredientImageUrl,
      });

      currentIngredientNameController.clear();
      currentMeasureController.clear();
    } else {
      Get.snackbar('Error', 'Please enter both ingredient and measure.');
    }
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
  }

  void addInstruction() {
    final instruction = currentInstructionController.text.trim();
    if (instruction.isNotEmpty) {
      instructions.add(instruction);
      currentInstructionController.clear();
    } else {
      Get.snackbar('Error', 'Please enter an instruction.');
    }
  }

  void removeInstruction(int index) {
    instructions.removeAt(index);
  }

  Future<void> saveMeal() async {
    final meal = {
      "strMeal": mealNameController.text.trim(),
      "strCalories": caloriesController.text.trim(),
      "strTime": timeController.text.trim(),
      "strCategory": selectedCategory.value,
      "strArea": selectedArea.value,
      "strInstructions": instructions.join("\n"),
      "strMealThumb": imageUrl.value,
      "strTags": tagsController.text.trim(),
      "strYoutube": youtubeLinkController.text.trim(),
      "ingredients": ingredients,
    };

    int id = storage.read('meal_id') ?? 1;
    meal['idMeal'] = id.toString();

    List<dynamic> meals = storage.read('meals') ?? [];
    meals.add(meal);

    storage.write('meals', meals);
    storage.write('meal_id', id + 1);

    await saveMealToFirestore(meal);

    savedMeals.value = meals.cast<Map<String, dynamic>>();

    clearFields();
    Get.snackbar('Success', 'Recipe saved successfully!');
  }

  Future<void> saveMealToFirestore(Map<String, dynamic> meal) async {
    try {
      await FirebaseFirestore.instance.collection('meals').add(meal);
      Get.snackbar('Success', 'Recipe saved to Firestore successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save recipe to Firestore: $e');
    }
  }

  void deleteMeal(String idMeal) {
    savedMeals.removeWhere((meal) => meal['idMeal'] == idMeal);

    storage.write('meals', savedMeals);

    Get.snackbar('Deleted', 'Recipe has been deleted.');
  }

  void clearFields() {
    mealNameController.clear();
    caloriesController.clear();
    timeController.clear();
    tagsController.clear();
    youtubeLinkController.clear();
    currentIngredientNameController.clear();
    currentMeasureController.clear();
    currentInstructionController.clear();
    imageUrl.value = null;
    instructions.clear();
    ingredients.clear();
    selectedCategory.value = '';
    selectedArea.value = '';
  }
}
