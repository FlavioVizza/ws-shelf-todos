import 'package:shelf_router/shelf_router.dart';
import '../controllers/auth_controller.dart';

Router getAuthRoutes() {
  final router = Router();
  router.post('/register',  register);
  router.post('/login',     login);
  router.post('/refresh',   refreshToken);
  return router;
}