part of 'app_pages.dart';

abstract class Routes {
  static const HOME = _Paths.HOME;
  static const VIEW_ALL = _Paths.VIEW_ALL; // Route untuk View All
  static const FAVORITE = _Paths.FAVORITE; // Route untuk Favorite
  static const START_COOKING = _Paths.START_COOKING; // Route untuk Start Cooking
  static const MY_START_COOKING = _Paths.MY_START_COOKING; // Route untuk My Start Cooking
  static const MY_RECIPE_VIEW = _Paths.MY_RECIPE_VIEW; // Route untuk My Recipe View
  static const UPLOAD = _Paths.UPLOAD; // Route untuk Upload Recipe
  static const MY_RECIPE_LIST_VIEW = _Paths.MY_RECIPE_LIST_VIEW; // Route untuk My Recipe List View
}

abstract class _Paths {
  static const HOME = '/home';
  static const VIEW_ALL = '/view-all'; // Path untuk View All
  static const FAVORITE = '/favorite'; // Path untuk Favorite
  static const START_COOKING = '/start-cooking'; // Path untuk Start Cooking
  static const MY_START_COOKING = '/my-start-cooking'; // Path untuk My Start Cooking
  static const MY_RECIPE_VIEW = '/my-recipe-view'; // Path untuk My Recipe View
  static const UPLOAD = '/upload'; // Path untuk Upload Recipe
  static const MY_RECIPE_LIST_VIEW = '/my-recipe-list-view'; // Path untuk My Recipe List View
}
