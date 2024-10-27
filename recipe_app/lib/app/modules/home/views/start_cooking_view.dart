import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:iconsax/iconsax.dart'; // Untuk icon favorite
import 'package:get/get.dart'; // GetX untuk state management
import 'package:recipe_app/app/modules/favorite/controllers/favorite_controller.dart'; // Import FavoriteController

class StartCookingView extends StatefulWidget {
  final Map<String, dynamic> food;

  const StartCookingView({Key? key, required this.food}) : super(key: key);

  @override
  _StartCookingViewState createState() => _StartCookingViewState();
}

class _StartCookingViewState extends State<StartCookingView> {
  late YoutubePlayerController _youtubeController;
  late WebViewController _webViewController;
  final FavoriteController favoriteController =
      Get.find<FavoriteController>(); // FavoriteController dari GetX

  @override
  void initState() {
    super.initState();

    // Extract video ID from YouTube URL
    final videoId =
        YoutubePlayer.convertUrlToId(widget.food['strYoutube'] ?? '');

    // Initialize YouTube player
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    // Initialize WebViewController for WebView
    _webViewController = WebViewController()
      ..loadRequest(
          Uri.parse(widget.food['strSource'] ?? 'https://www.example.com'));
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.food['strMeal'] ?? 'Meal',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            Obx(() {
              final isFavorite =
                  favoriteController.isFavorite(widget.food['idMeal']);
              return IconButton(
                icon: Icon(isFavorite ? Iconsax.heart5 : Iconsax.heart,
                    color: primaryColor),
                onPressed: () {
                  favoriteController.toggleFavorite(widget.food);
                },
              );
            }),
          ],
        ),
        body: Column(
          children: [
            // TabBar just below the AppBar
            TabBar(
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: primaryColor,
              tabs: const [
                Tab(text: 'Instructions'),
                Tab(text: 'Article'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Instructions with YouTube video fixed
                  Column(
                    children: [
                      // YouTube video (fixed)
                      YoutubePlayer(
                        controller: _youtubeController,
                        showVideoProgressIndicator: true,
                      ),
                      // Instruction list (scrollable)
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildInstructionCards(
                                widget.food['strInstructions'], primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Tab 2: Article (WebView)
                  WebViewWidget(
                    controller: _webViewController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun tampilan card untuk setiap instruksi
  List<Widget> _buildInstructionCards(String instructions, Color primaryColor) {
  if (instructions.contains('STEP')) {
    final steps = instructions.split(RegExp(r'\r\n\r\nSTEP \d+\r\n')); // Memecah instruksi berdasarkan STEP
    List<Widget> stepsWidgets = [];

    for (int i = 1; i < steps.length; i++) {
      stepsWidgets.add(
        Stack(
          clipBehavior: Clip.none, // Allow content to overflow (for the badge)
          children: [
            // Card Container with shadow and gradient
            Container(
              margin: const EdgeInsets.symmetric(vertical: 25, horizontal: 15), // Add more margin
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 5,
                    offset: const Offset(0, 5), // Shadow position
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Step content
                    Text(
                      steps[i].trim(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Step number badge with border and glow effect
            Positioned(
              top: -10, // Move the badge up, but ensure it's not cut off
              left: 10, // Adjust left to center the badge better
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  i.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return stepsWidgets;
  } else {
    // Non-step based instructions, use a larger single card with gradient
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.05), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Text(
            instructions,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
      ),
    ];
  }
}


}
