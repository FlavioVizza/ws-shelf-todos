import 'package:shelf_router/shelf_router.dart';
import '../controllers/hello_controller.dart';

/// Returns the router for the Hello route.
///
/// This function sets up a simple route that returns a "hello" message from the
/// `helloMsg` function in the `hello_controller.dart` file. It is mainly used for testing.
Router getHelloRoutes() {
  final router = Router();
  router.get('/hello', helloMsg);
  return router;
}