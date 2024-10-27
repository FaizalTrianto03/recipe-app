import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchRecipeAppController extends GetxController {
  var searchText = ''.obs;
  var filteredMeals = [].obs; // Untuk menyimpan hasil pencarian dari API

  // Fungsi untuk mencari makanan berdasarkan input pengguna
  Future<void> searchMeals(String query) async {
    if (query.isEmpty) {
      filteredMeals.clear(); // Jika pencarian kosong, kosongkan hasil pencarian
      return;
    }

    final url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=$query';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Jika data['meals'] tidak null, maka hasil pencarian ada
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          filteredMeals.assignAll(data['meals']);
        } else {
          filteredMeals.clear(); // Kosongkan jika tidak ada hasil yang cocok
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch data from API');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Fungsi untuk memperbarui teks pencarian
  void updateSearchText(String text) {
    searchText.value = text;
    searchMeals(text); // Panggil fungsi pencarian saat teks berubah
  }

  bool get isSearching => searchText.isNotEmpty;
}
