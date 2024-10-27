// lib/app/modules/upload/views/my_recipe_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/app/routes/app_pages.dart'; // Import Routes
import '../controllers/upload_controller.dart';

class MyRecipeView extends StatefulWidget {
  final Map<String, dynamic> meal;

  const MyRecipeView({Key? key, required this.meal}) : super(key: key);

  @override
  _MyRecipeViewState createState() => _MyRecipeViewState();
}

class _MyRecipeViewState extends State<MyRecipeView> {
  final UploadController uploadController = Get.find<UploadController>();
  int servings = 1; // Initial serving size

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Ekstrak bahan-bahan
    final ingredients = widget.meal['ingredients'] as List<dynamic>? ?? [];

    // Ekstrak instruksi
    final instructions = (widget.meal['strInstructions'] as String?)?.split('\n') ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80), // Tambahkan padding bawah untuk tombol
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **Header Image dengan Tombol Kembali dan Hapus**
                Stack(
                  children: [
                    // **Gambar Makanan**
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        image: DecorationImage(
                          image: widget.meal['strMealThumb'] != null &&
                                  File(widget.meal['strMealThumb']).existsSync()
                              ? FileImage(File(widget.meal['strMealThumb']))
                              : const AssetImage('assets/placeholder.png') as ImageProvider,
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
                          // **Tombol Kembali**
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.7),
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: Icon(Icons.arrow_back, color: primaryColor),
                            ),
                          ),
                          // **Tombol Hapus**
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.7),
                            child: IconButton(
                              onPressed: () {
                                // Konfirmasi penghapusan dengan pengguna
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text(
                                      'Delete Recipe',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this recipe?',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: primaryColor),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Hapus resep
                                          uploadController.deleteMeal(widget.meal['idMeal']);
                                          Get.back(); // Tutup dialog
                                          Get.back(); // Kembali ke layar sebelumnya
                                        },
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(Icons.delete, color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // **Nama Makanan**
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.meal['strMeal'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // **Kalori dan Waktu**
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.meal['strCalories'] != null &&
                          widget.meal['strCalories'].isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                              "${widget.meal['strCalories']} Cal",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      if (widget.meal['strTime'] != null &&
                          widget.meal['strTime'].isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                              "${widget.meal['strTime']} Min",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // **Jumlah Porsi**
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

                // **Bagian Bahan**
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

                // **Tampilkan bahan sebagai kartu**
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(ingredients.length, (index) {
                      final ingredient = ingredients[index]['ingredient'] ?? '';
                      final measure = ingredients[index]['measure'] ?? '';
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
                              // **Gambar Bahan**
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: ingredients[index]['image'] != null
                                        ? NetworkImage(ingredients[index]['image'])
                                        : const AssetImage('assets/placeholder.png') as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ingredient,
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

                // **Bagian Instruksi**
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Instructions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(instructions.length, (index) {
                      final instruction = instructions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${index + 1}. $instruction',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 80), // Ruang untuk tombol
              ],
            ),
          ),

          // **Tombol Start Cooking**
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman Start Cooking
                  Get.toNamed(Routes.MY_START_COOKING, arguments: widget.meal);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  shadowColor: Colors.transparent,
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

  // **Fungsi untuk mengukur skala porsi**
  String _scaleMeasure(String measure, int servings) {
    // Fungsi ini dapat diperluas untuk menangani skala kuantitas secara akurat
    return "$measure x $servings";
  }
}
