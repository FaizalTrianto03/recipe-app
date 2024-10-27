import 'package:get/get.dart';
import 'package:recipe_app/app/modules/home/views/home_view.dart';
import 'package:recipe_app/app/modules/home/bindings/home_binding.dart';
import 'package:recipe_app/app/modules/home/views/view_all_page.dart'; // Import ViewAllPage
import 'package:recipe_app/app/modules/favorite/views/favorite_view.dart'; // Import FavoriteView
import 'package:recipe_app/app/modules/favorite/bindings/favorite_binding.dart'; // Import FavoriteBinding
import 'package:recipe_app/app/modules/home/views/start_cooking_view.dart'; // Import StartCookingView
import 'package:recipe_app/app/modules/upload/views/my_recipe_start_cooking.dart'; // Import MyRecipeStartCooking
import 'package:recipe_app/app/modules/upload/views/upload_view.dart'; // Import UploadView
import 'package:recipe_app/app/modules/upload/views/my_recipe_view.dart'; // Import MyRecipeView
import 'package:recipe_app/app/modules/upload/views/my_recipelistview.dart'; // Import MyRecipeListView
import 'package:recipe_app/app/modules/upload/bindings/upload_binding.dart'; // Import UploadBinding
part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // Halaman untuk View All
    GetPage(
      name: _Paths.VIEW_ALL, // Route untuk View All
      page: () => ViewAllPage(categoryName: Get.parameters['category'] ?? 'All'),
      binding: HomeBinding(),
    ),
    // Halaman untuk Favorite
    GetPage(
      name: _Paths.FAVORITE, // Route untuk Favorite
      page: () => const FavoriteView(),
      binding: FavoriteBinding(),
    ),
    // Halaman untuk Start Cooking
    GetPage(
      name: _Paths.START_COOKING, // Route untuk Start Cooking
      page: () => StartCookingView(food: Get.arguments), // Mengirim data 'food' ke halaman
    ),
    // Halaman untuk Upload Recipe
    GetPage(
      name: _Paths.UPLOAD, // Route untuk Upload
      page: () => const UploadView(), // Page untuk Upload Recipe
      binding: UploadBinding(), // Binding untuk Upload
    ),
    GetPage(
      name: _Paths.MY_RECIPE_VIEW, // Route untuk My Recipe View
      page: () => MyRecipeView(meal: Get.arguments), // Page untuk My Recipe View, menerima argument 'meal'
      binding: UploadBinding(), // Binding untuk My Recipe View
    ),
    GetPage(
      name: _Paths.MY_START_COOKING, // Route untuk My Start Cooking
      page: () => MyRecipeStartCooking(meal: Get.arguments), // Page untuk My Start Cooking
    ),
    GetPage(
      name: _Paths.MY_RECIPE_LIST_VIEW, // Route untuk My Recipe List View
      page: () => const MyRecipeListView(), // Page untuk menampilkan daftar resep yang disimpan
      binding: UploadBinding(), // Binding untuk My Recipe List View
    ),
  ];
}
