import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

Handler getSwaggerHandler() {
  const String swaggerFilePath = 'doc/swagger.json';
  const headers = {'Content-Type': 'application/json'};

  // Handler per servire il file swagger.json
  swaggerJsonHandler(Request request) async {
    final file = File(swaggerFilePath);
    return await file.exists() ?
      Response.ok(headers: headers, await file.readAsString()):
      Response.notFound(headers: headers, jsonEncode({'error': 'Swagger file not found'}));
  }

  return Cascade()
      .add((request) => request.url.path == 'swagger.json' ? swaggerJsonHandler(request) : Response.notFound('Not Found'))
      .add(SwaggerUI(swaggerFilePath, title: 'Todos API').call)
      .handler;
}