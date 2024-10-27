import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipe_app/app/routes/app_pages.dart';
import 'package:recipe_app/app/modules/favorite/controllers/favorite_controller.dart'; // Import FavoriteController

class RecipeView extends StatefulWidget {
  final Map<String, dynamic> food;

  RecipeView({Key? key, required this.food}) : super(key: key);

  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  final FavoriteController favoriteController = Get.find<FavoriteController>();
  int servings = 1; // Initial serving size
  final primaryColor = Get.theme.primaryColor;

  @override
  Widget build(BuildContext context) {
    // Extract ingredients and measures
    List<Map<String, String>> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = widget.food['strIngredient$i'];
      final measure = widget.food['strMeasure$i'];

      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add({
          'ingredient': ingredient,
          'measure': measure ?? '',
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
                bottom: 80), // Add bottom padding to allow room for button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image with Back and Favorite Buttons
                Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(widget.food['strMealThumb']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.7),
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: Icon(CupertinoIcons.chevron_back,
                                  color: primaryColor),
                            ),
                          ),
                          // Favorite Button
                          Obx(() {
                            final isFavorite = favoriteController
                                .isFavorite(widget.food['idMeal']);
                            return CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.7),
                              child: IconButton(
                                onPressed: () {
                                  favoriteController
                                      .toggleFavorite(widget.food);
                                },
                                icon: Icon(
                                  isFavorite ? Iconsax.heart5 : Iconsax.heart,
                                  color: primaryColor,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Meal Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.food['strMeal'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Calories and Time
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Iconsax.flash_1,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            widget.food['calories'] != null
                                ? "${widget.food['calories']} Cal"
                                : "Calories info not available",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Iconsax.clock,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            widget.food['time'] != null
                                ? "${widget.food['time']} Min"
                                : "Time info not available",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Rating Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(
                            5,
                            (index) => Icon(Iconsax.star1,
                                color: Colors.yellow.shade700, size: 25)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "123 Ratings",
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // How many servings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "How many servings?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (servings > 1) servings--;
                              });
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            "$servings",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                servings++;
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Ingredients Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Ingredients",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Display ingredients as cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(ingredients.length, (index) {
                      final ingredient = ingredients[index]['ingredient'];
                      final measure = ingredients[index]['measure'];
                      final scaledMeasure = _scaleMeasure(measure, servings);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              // Ingredient image
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        "https://www.themealdb.com/images/ingredients/${ingredient}-Small.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ingredient ?? "Unknown",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                scaledMeasure,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Start Cooking Button (floating at bottom with transparent background)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman Start Cooking, dan kirim data 'food'
                  Get.toNamed(Routes.START_COOKING, arguments: widget.food);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  shadowColor: Colors
                      .transparent, // Remove shadow for transparency effect
                ),
                child: const Text(
                  "Start Cooking",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to scale the measure according to servings
  String _scaleMeasure(String? measure, int servings) {
    if (measure == null || measure.isEmpty) return "";
    return "$measure x $servings";
  }
}
