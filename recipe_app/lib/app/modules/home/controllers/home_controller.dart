import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeController extends GetxController {
  var categories = [].obs; // List of all categories
  var filteredMeals = [].obs; // List of filtered meals based on category
  var userName = "User".obs;
  var currentCategory = ''.obs; // Holds the active category
  var allMeals = [].obs; // List of all meals for filtering
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories(); // Fetch categories when the controller is initialized
    fetchAllMeals(); // Fetch all meals for the "All" category
  }

  // Fetch categories from TheMealDB API and add the "All" category as default
  Future<void> fetchCategories() async {
    const url = 'https://www.themealdb.com/api/json/v1/1/categories.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        categories.assignAll(data['categories']);
        categories.insert(0, {
          // Insert the "All" category as default
          'strCategory': 'All',
          'strCategoryThumb': '', // Leave blank since we'll handle this in the UI
        });
        currentCategory.value = 'All'; // Set the "All" category as default
        fetchAllMeals(); // Fetch all meals initially
      } else {
        Get.snackbar('Error', 'Failed to fetch categories');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Fetch all meals from TheMealDB API
  Future<void> fetchAllMeals() async {
    const url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var meals = data['meals'] ?? [];
        allMeals.assignAll(meals); // Show all meals when "All" is selected
        filteredMeals.assignAll(allMeals); // Default is all meals
      } else {
        Get.snackbar('Error', 'Failed to fetch meals');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Fetch meals based on selected category
  Future<void> fetchMealsByCategory(String category) async {
    if (category == 'All') {
      filteredMeals.assignAll(allMeals); // Show all meals if "All" is selected
    } else {
      const url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          var meals = data['meals'] ?? [];
          filteredMeals.assignAll(
              meals.where((meal) => meal['strCategory'] == category).toList());
        } else {
          Get.snackbar('Error', 'Failed to fetch meals');
        }
      } catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }
  }

  // Set active category and fetch meals for that category
  void setActiveCategory(String category) {
    currentCategory.value = category;
    fetchMealsByCategory(category);
  }

  // Function to change tab index
    void changeTabIndex(int index) {
    currentIndex.value = index; // Update the current index
  }
}
