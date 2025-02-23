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

// DB ref
late Db db;

// Configure routes.
final app = Router();

void main(List<String> args) async {

  // database
  await connectDB();
  ProcessSignal.sigint.watch().listen(disconnectDB);

  // routes
  app.mount('/',          getSwaggerHandler());
  app.mount('/api',       getHelloRoutes().call);
  app.mount('/api/auth',  getAuthRoutes().call);
  app.mount('/api/todos', getTodosRoutes().call);

  // app pipeline
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(app.call);

  // run server
  final ip = Config.ip;
  final port = Config.port;
  final server = await serve(handler, ip, port);
  
  print('🌈 Server start listening on http://${server.address.host}:${server.port}');

}

Future<void> connectDB() async {
  db = await Db.create(Config.mongodbUri);
  await db.open();
  print('✅ Connected to MongoDB');
}

Future<void> disconnectDB(_) async {
  print('🛑 Server stop');
  await db.close();
  exit(0);
}



