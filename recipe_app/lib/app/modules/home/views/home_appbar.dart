import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/app/modules/home/controllers/home_controller.dart';

class HomeAppbar extends StatelessWidget {
  const HomeAppbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome ${controller.userName}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Obx(() => Text(
              controller.userName.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
          ],
        ),
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/images/profile.jpg'),
        ),
      ],
    );
  }
}
