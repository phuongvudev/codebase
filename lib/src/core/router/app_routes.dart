class AppRoutes {
  static const String root = '/';
  static const String rootName = 'root';

  static const String home = '/home';
  static const String homeName = 'home';

  static const String notFound = '/not-found';
  static const String notFoundName = 'notFound';

  static String detailsPath(String id) => '/home/details/$id';
}
