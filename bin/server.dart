import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'utils/config.dart';
import 'routes/hello_routes.dart';
import 'routes/auth_routes.dart';
import 'routes/todos_routes.dart';
import 'swagger/swagger_handler.dart';

/// Global database instance
late Db db;

/// Router instance to manage API routes.
final app = Router();

/// Entry point of the Shelf server.
///
/// - Connects to the database.
/// - Sets up API routes.
/// - Adds middlewares (logging, CORS).
/// - Starts the HTTP server.
/// - Handles process termination signals.
void main(List<String> args) async {
  // Connect to the database
  await connectDB();

  // Handle termination signal to disconnect DB properly
  ProcessSignal.sigint.watch().listen(disconnectDB);

  // Define API routes
  app.mount('/api',       getHelloRoutes().call);
  app.mount('/api/auth',  getAuthRoutes().call);
  app.mount('/api/todos', getTodosRoutes().call);
  app.mount('/',          getSwaggerHandler()); // Swagger UI

  // Build the request handler pipeline
  final handler = Pipeline()
      .addMiddleware(logRequests()) // Log HTTP requests
      .addMiddleware(corsHeaders()) // Enable CORS
      .addHandler(app.call);

  // Start the server
  final ip = Config.ip;
  final port = Config.port;
  await serve(handler, ip, port);
  
  print('🌈 Server started');
}

/// Establishes a connection to the MongoDB database.
///
/// Loads the connection URI from the configuration and opens the database connection.
Future<void> connectDB() async {
  db = await Db.create(Config.mongodbUri);
  await db.open();
  print('✅ Connected to MongoDB');
}

/// Gracefully shuts down the server and closes the database connection.
///
/// This function is triggered when the process receives a termination signal (e.g., Ctrl+C).
Future<void> disconnectDB(_) async {
  print('🛑 Shutting down server...');
  await db.close();
  exit(0);
}