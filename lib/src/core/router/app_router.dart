import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router_factory.dart';
import 'app_routes.dart';
import 'modules/home_route_module.dart';
import 'modules/system_route_module.dart';

class AppRouter {
  static final navigationKey = GlobalKey<NavigatorState>();
  static final GoRouter config = AppRouterFactory(
    navigatorKey: navigationKey,
    fallbackInitialLocation: AppRoutes.root,
    modules: const [HomeRouteModule(), SystemRouteModule()],
  ).create();
}
