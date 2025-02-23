import 'package:shelf_router/shelf_router.dart';
import '../controllers/auth_controller.dart';

/// Returns the router for authentication-related routes.
///
/// This function sets up the authentication routes for user registration, login, 
/// and token refresh. These routes will be handled by the corresponding 
/// functions in the `auth_controller.dart`.
Router getAuthRoutes() {
  final router = Router();
  router.post('/register',  register);
  router.post('/login',     login);
  router.post('/refresh',   refreshToken);
  return router;
}