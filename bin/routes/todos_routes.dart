import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import '../controllers/todo_controller.dart';
import '../middleware/auth_middleware.dart'; 

Router getTodosRoutes() {
  final router = Router();

  // sub routes
  router.get(   '/',      getTodoList);
  router.post(  '/',      postTodoItem);
  router.get(   '/<id>',  getTodoItem);
  router.put(   '/<id>',  putTodoItem);
  router.delete('/<id>',  deleteTodoItem);

  // return protected rotes
  return Router()
    ..mount('/', Pipeline()
    .addMiddleware(authenticateToken())
    .addHandler(router.call));
}
