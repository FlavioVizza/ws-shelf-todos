import 'package:shelf_router/shelf_router.dart';
import '../controllers/hello_controller.dart';

Router getHelloRoutes() {
  final router = Router();
  router.get('/hello', helloMsg);
  return router;
}