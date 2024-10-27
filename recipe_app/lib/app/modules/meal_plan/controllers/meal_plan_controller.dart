import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MealPlanController extends GetxController {
  var isLoading = true.obs;
  var mealsByDay = <String, List<Map<String, dynamic>>>{}.obs;

  final String apiUrl = 'https://www.themealdb.com/api/json/v1/1/filter.php?c=Beef'; // Ganti dengan kategori yang sesuai

  @override
  void onInit() {
    super.onInit();
    fetchMeals();
  }

  void fetchMeals() async {
    isLoading(true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> meals = List<Map<String, dynamic>>.from(data['meals']);

        // Mengelompokkan makanan berdasarkan hari riil
        DateTime today = DateTime.now();
        List<String> daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

        // Menginisialisasi mealsByDay dengan daftar hari
        for (var day in daysOfWeek) {
          mealsByDay[day] = [];
        }

        // Menambahkan makanan ke hari yang sesuai
        for (int i = 0; i < meals.length; i++) {
          String day = daysOfWeek[(today.weekday + i) % 7]; // Mengelompokkan makanan ke hari berdasarkan index
          mealsByDay[day]?.add(meals[i]);
        }
      } else {
        print("Failed to fetch meals: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching meals: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>?> fetchMealDetail(String mealId) async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['meals'] != null && data['meals'].isNotEmpty) {
        return data['meals'][0];
      }
    }
    return null;
  }
}
