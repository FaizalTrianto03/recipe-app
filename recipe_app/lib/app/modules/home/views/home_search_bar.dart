import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/app/modules/home/controllers/search_recipe_app_controller.dart'; // Controller pencarian

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchRecipeAppController controller = Get.put(SearchRecipeAppController());
    final primaryColor = Theme.of(context).primaryColor;

    // Memisahkan TextEditingController dari logika onChanged
    final TextEditingController textEditingController = TextEditingController();

    // Set initial value ke TextEditingController saat di-build pertama kali
    textEditingController.text = controller.searchText.value;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor, width: 2), // Border dengan warna primer
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Obx(() {
        // Update TextEditingController saat searchText berubah
        textEditingController.value = textEditingController.value.copyWith(
          text: controller.searchText.value,
          selection: TextSelection.fromPosition(
            TextPosition(offset: controller.searchText.value.length),
          ),
        );

        return Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: textEditingController,
                onChanged: (value) {
                  // Update teks pencarian di controller
                  controller.updateSearchText(value);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search any recipes",
                  hintStyle: const TextStyle(color: Colors.grey),
                  isCollapsed: true, // Mengurangi padding internal TextField
                  contentPadding: const EdgeInsets.symmetric(vertical: 15), // Padding vertikal yang konsisten
                  suffixIcon: controller.searchText.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: primaryColor),
                          onPressed: () {
                            // Bersihkan teks pencarian dan update controller
                            textEditingController.clear();
                            controller.updateSearchText('');
                          },
                        )
                      : null, // Tampilkan tombol X hanya jika ada teks
                ),
                textAlignVertical: TextAlignVertical.center, // Pastikan teks berada di tengah vertikal
              ),
            ),
          ],
        );
      }),
    );
  }
}
