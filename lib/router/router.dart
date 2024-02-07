/// Dispatcher for the application actions, features.
abstract class Router {
  Future<void> runSelectedAction(List<String> arguments);
}