import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/app/modules/home/views/card_menu.dart'; // Menggunakan CardMenu
import 'package:recipe_app/app/modules/home/views/home_appbar.dart';
import 'package:recipe_app/app/modules/home/views/home_search_bar.dart';
import 'package:recipe_app/app/modules/home/views/preview_quick_fast.dart'; // Combine CategoryView and QuickAndFastList
import 'package:recipe_app/app/modules/home/controllers/home_controller.dart';
import 'package:recipe_app/app/widgets/custom_bottom_nav_bar.dart';
import 'package:recipe_app/app/modules/home/controllers/search_recipe_app_controller.dart'; // Import SearchRecipeAppController

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final searchController = Get.put(SearchRecipeAppController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeAppbar(),
                const SizedBox(height: 20),
                const HomeSearchBar(),
                const SizedBox(height: 20),

                // Search logic
                Obx(() {
                  if (searchController.isSearching && searchController.filteredMeals.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Search Results",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CardMenu(meals: searchController.filteredMeals), // Display search results in CardMenu
                      ],
                    );
                  } else if (searchController.isSearching && searchController.filteredMeals.isEmpty) {
                    return const Text(
                      "No results found.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    );
                  } else {
                    // Default view when there's no search
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Image
                        Container(
                          width: double.infinity,
                          height: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage("assets/images/recipefood.jpg"),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Categories and Quick & Fast Section combined in PreviewQuickFast
                        // Pass currentCategory to PreviewQuickFast
                Obx(() => PreviewQuickFast(currentCategory: controller.currentCategory.value)),
                      ],
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(), // Custom Bottom Navigation
    );
  }
}
