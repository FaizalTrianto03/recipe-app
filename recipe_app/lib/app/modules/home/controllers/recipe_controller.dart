import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeController extends GetxController {
  var isLoading = true.obs;
  var ingredients = <Map<String, String>>[].obs;
  
  // Fetch recipe data from API
  Future<void> fetchRecipe(String mealId) async {
    final url = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId";
    
    try {
      isLoading(true);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meal = data['meals'][0];

        // Extracting ingredients and measures
        List<Map<String, String>> tempIngredients = [];
        for (int i = 1; i <= 20; i++) {
          final ingredient = meal['strIngredient$i'];
          final measure = meal['strMeasure$i'];

          if (ingredient != null && ingredient.isNotEmpty) {
            tempIngredients.add({
              'ingredient': ingredient,
              'measure': measure,
            });
          }
        }

        ingredients.value = tempIngredients;
      }
    } catch (e) {
      print("Error fetching recipe: $e");
    } finally {
      isLoading(false);
    }
  }
}
