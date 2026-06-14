import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../route_module.dart';

class HomeRouteModule extends AppRouteModule {
  const HomeRouteModule();

  @override
  RouteModuleOptions get options =>
      RouteModuleOptions(
        initialLocation: AppRoutes.home,
        redirect: (context, state) {
          if (state.uri.path == AppRoutes.root) {
            return AppRoutes.home;
          }
          return null;
        },
        deepLinks: <DeepLinkMatcher>[
          DeepLinkMatcher.pathPrefix('/home'),
          DeepLinkMatcher.path('/'),
        ],
      );

  @override
  List<RouteBase> get routes => <RouteBase>[
  ];
}


