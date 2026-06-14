import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A module that defines a set of routes and their associated options,
/// such as an initial location, a redirect function, and deep link matchers.
typedef ModuleRedirect = FutureOr<String?> Function(
  BuildContext context,
  GoRouterState state,
);

/// An abstract class that represents a route module, which can be used to
/// organize routes into logical groups and provide additional configuration options for the routing system.
/// Each module can specify an initial location, a redirect function,
/// and a list of deep link matchers to determine if the module should handle a given URI.
abstract class AppRouteModule {
  const AppRouteModule();

  RouteModuleOptions get options;
  List<RouteBase> get routes;
}

/// A class that encapsulates the options for a route module,
/// including an initial location, a redirect function, and a list of deep link matchers.
/// The initial location specifies the default route to navigate to when the module is loaded,
/// while the redirect function allows for dynamic redirection based on the current state and context.
class RouteModuleOptions {
  const RouteModuleOptions({
    this.initialLocation,
    this.redirect,
    this.deepLinks = const <DeepLinkMatcher>[],
  });

  final String? initialLocation;
  final ModuleRedirect? redirect;
  final List<DeepLinkMatcher> deepLinks;

  bool supportsDeepLink(Uri uri) {
    if (deepLinks.isEmpty) {
      return false;
    }
    return deepLinks.any((matcher) => matcher.matches(uri));
  }
}

class DeepLinkMatcher {
  const DeepLinkMatcher._(this._matcher);

  factory DeepLinkMatcher.pathPrefix(String prefix) {
    return DeepLinkMatcher._((uri) => uri.path.startsWith(prefix));
  }

  factory DeepLinkMatcher.path(String value) {
    return DeepLinkMatcher._((uri) => uri.path == value);
  }

  factory DeepLinkMatcher.regex(RegExp expression) {
    return DeepLinkMatcher._((uri) => expression.hasMatch(uri.path));
  }

  final bool Function(Uri uri) _matcher;

  bool matches(Uri uri) => _matcher(uri);
}

