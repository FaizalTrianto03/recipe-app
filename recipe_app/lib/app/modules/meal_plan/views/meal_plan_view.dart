import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/meal_plan_controller.dart';

class MealPlanView extends StatefulWidget {
  const MealPlanView({Key? key}) : super(key: key);

  @override
  State<MealPlanView> createState() => _MealPlanViewState();
}

class _MealPlanViewState extends State<MealPlanView> {
  final controller = Get.put(MealPlanController());

  Map<String, dynamic>? selectedMealData;

  @override
  void initState() {
    super.initState();
    controller.fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: selectedMealData != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedMealData = null;
                  });
                },
              )
            : null,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.mealsByDay.isEmpty) {
          return const Center(child: Text('No meals available.'));
        }

        if (selectedMealData != null) {
          return _buildMealDetailView();
        }

        return _buildMealRecommendationsView();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewMeal(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMealRecommendationsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: controller.mealsByDay.entries.map((entry) {
          String day = entry.key;
          List<Map<String, dynamic>> meals = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  var meal = meals[index];
                  return GestureDetector(
                    onTap: () async {
                      var mealDetail =
                          await controller.fetchMealDetail(meal['idMeal']);
                      setState(() {
                        selectedMealData = mealDetail;
                      });
                    },
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: Image.network(
                                  meal['strMealThumb'],
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: _buildThreeDotMenu(day, meal),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              meal['strMeal'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThreeDotMenu(String day, Map<String, dynamic> meal) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (String result) {
        switch (result) {
          case 'edit':
            _editMeal(day, meal);
            break;
          case 'delete':
            _deleteMeal(day, meal);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    );
  }

  void _editMeal(String day, Map<String, dynamic> meal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Map<String, dynamic> selectedMeal = Map.from(meal);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Meal'),
              content: DropdownButton<String>(
                value: selectedMeal['idMeal'],
                items:
                    controller.availableMeals.map((Map<String, dynamic> meal) {
                  return DropdownMenuItem<String>(
                    value: meal['idMeal'],
                    child: Text(meal['strMeal']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedMeal = controller.availableMeals
                          .firstWhere((meal) => meal['idMeal'] == newValue);
                    });
                  }
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    controller.updateMeal(
                        day,
                        controller.mealsByDay[day]!.indexOf(meal),
                        selectedMeal);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Meal updated successfully')),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteMeal(String day, Map<String, dynamic> meal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Meal'),
          content: Text('Are you sure you want to delete ${meal['strMeal']}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                controller.deleteMeal(day, meal['idMeal']);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meal deleted successfully')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewMeal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedDay = controller.mealsByDay.keys.first;
        Map<String, dynamic>? selectedMeal;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Meal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedDay,
                    items: controller.mealsByDay.keys.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedDay = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedMeal?['idMeal'],
                    hint: const Text('Select a meal'),
                    items: controller.availableMeals
                        .map((Map<String, dynamic> meal) {
                      return DropdownMenuItem<String>(
                        value: meal['idMeal'],
                        child: Text(meal['strMeal']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedMeal = controller.availableMeals
                              .firstWhere((meal) => meal['idMeal'] == newValue);
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (selectedMeal != null) {
                      controller.addMeal(selectedDay, selectedMeal!);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Meal added successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a meal')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMealDetailView() {
    List<String> instructions =
        selectedMealData?['strInstructions']?.split('\n') ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              selectedMealData?['strMealThumb'] ?? '',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            selectedMealData?['strMeal'] ?? 'Meal Detail',
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingredients:',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          _buildIngredientsList(),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 10),
          _buildInstructionsList(instructions),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = selectedMealData?['strIngredient$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(ingredient);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients.map((ingredient) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '• $ingredient',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructionsList(List<String> instructions) {
    return Column(
      children: List.generate(instructions.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade300, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6.0,
                spreadRadius: 2.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Expanded(
                  child: Text(
                    instructions[index],
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
