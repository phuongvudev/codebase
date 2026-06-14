import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'route_module.dart';

class AppRouterFactory {
  const AppRouterFactory({
    required this.modules,
    this.fallbackInitialLocation = AppRoutes.root,
    this.errorBuilder,
    this.refreshListenable,
    this.extraCodec,
    this.navigatorKey,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final Listenable? refreshListenable;

  final Codec<Object?, Object?>? extraCodec;

  final List<AppRouteModule> modules;
  final String fallbackInitialLocation;
  final Widget Function(BuildContext context, GoRouterState state)? errorBuilder;

  GoRouter create() {
    return GoRouter(
      navigatorKey: navigatorKey,
      refreshListenable: refreshListenable,
      extraCodec: extraCodec,
      initialLocation: _resolveInitialLocation(),
      routes: _collectRoutes(),
      redirect: _redirect,
      errorBuilder:
          errorBuilder ??
          (context, state) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
    );
  }

  String _resolveInitialLocation() {
    for (final module in modules) {
      final initialLocation = module.options.initialLocation;
      if (initialLocation != null && initialLocation.isNotEmpty) {
        return initialLocation;
      }
    }
    return fallbackInitialLocation;
  }

  List<RouteBase> _collectRoutes() {
    return modules.expand((module) => module.routes).toList(growable: false);
  }

  FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
    final uri = state.uri;

    for (final module in modules) {
      final moduleRedirect = module.options.redirect;
      if (moduleRedirect == null) {
        continue;
      }

      final redirectLocation = await moduleRedirect(context, state);
      if (redirectLocation != null && redirectLocation != state.matchedLocation) {
        return redirectLocation;
      }
    }

    final hasModuleForDeepLink = modules.any(
      (module) => module.options.supportsDeepLink(uri),
    );

    if (!hasModuleForDeepLink && uri.path != AppRoutes.root) {
      return AppRoutes.notFound;
    }

    return null;
  }
}

