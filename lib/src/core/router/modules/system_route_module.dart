import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../route_module.dart';

class SystemRouteModule extends AppRouteModule {
  const SystemRouteModule();

  @override
  RouteModuleOptions get options =>
      RouteModuleOptions(
        deepLinks: <DeepLinkMatcher>[DeepLinkMatcher.path(AppRoutes.notFound)],
      );

  @override
  List<RouteBase> get routes => <RouteBase>[
    GoRoute(
      path: AppRoutes.notFound,
      name: AppRoutes.notFoundName,
      builder:
          (context, state) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
    ),
  ];
}


