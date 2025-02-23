import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

/// Returns a Shelf handler that serves the Swagger UI and the `swagger.json` file.
///
/// This handler is responsible for:
/// - Serving the `swagger.json` file at `/swagger.json`
/// - Rendering the Swagger UI for API documentation.
///
/// The `swagger.json` file should be located in the `doc/` directory.
Handler getSwaggerHandler() {
  /// Path to the Swagger JSON file.
  const String swaggerFilePath = 'doc/swagger.json';

  /// Headers for JSON responses.
  const headers = {'Content-Type': 'application/json'};

  /// Handles requests for the `swagger.json` file.
  ///
  /// - If the file exists, it returns its content with an HTTP 200 status.
  /// - If the file is missing, it returns a 404 error with a JSON response.
  Future<Response> swaggerJsonHandler(Request request) async {
    final file = File(swaggerFilePath);
    return await file.exists()
        ? Response.ok(headers: headers, await file.readAsString())
        : Response.notFound(headers: headers, jsonEncode({'error': 'Swagger file not found'}));
  }

  return Cascade()
      // Serve the swagger.json file when requested
      .add((request) => request.url.path == 'swagger.json' ? swaggerJsonHandler(request) : Response.notFound('Not Found'))
      // Serve the Swagger UI
      .add(SwaggerUI(swaggerFilePath, title: 'Todos API').call)
      .handler;
}