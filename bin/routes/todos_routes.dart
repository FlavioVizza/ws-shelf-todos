import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import '../controllers/todo_controller.dart';
import '../middleware/auth_middleware.dart'; 

/// Returns the router for Todo-related routes.
///
/// This function sets up routes for CRUD operations on Todo items. Additionally, 
/// it adds an authentication middleware for protecting the routes. All routes 
/// under `/api/todos` will require a valid access token in the request header.
Router getTodosRoutes() {
  final router = Router();

  // sub routes
  router.get(   '/',      getTodoList);    // Route to get all Todo items
  router.post(  '/',      postTodoItem);   // Route to create a new Todo item
  router.get(   '/<id>',  getTodoItem);    // Route to get a specific Todo item by ID
  router.put(   '/<id>',  putTodoItem);    // Route to update a specific Todo item by ID
  router.delete('/<id>',  deleteTodoItem); // Route to delete a specific Todo item by ID

  // return protected routes
  return Router()
    ..mount('/', Pipeline()
    .addMiddleware(authenticateToken()) // Apply authentication middleware to all routes
    .addHandler(router.call));
}
