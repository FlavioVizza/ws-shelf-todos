import 'dart:convert';
import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../utils/config.dart';
import '../utils/constants.dart';

/// Middleware to authenticate API requests using a JWT access token.
///
/// This middleware:
/// - Extracts the token from the `Authorization` header.
/// - Verifies the token using the configured secret key.
/// - Attaches the user ID from the token to the request context.
/// - Returns a `403 Forbidden` response if the token is missing, invalid, or expired.
Middleware authenticateToken() {

  /// Handles incoming requests by verifying the JWT access token.
  ///
  /// - If the token is valid, it adds `userId` to the request context and forwards the request.
  /// - If the token is missing or invalid, it returns an unauthorized response.
  Future<Response> handleRequest(Handler innerHandler, Request request) async {
    final token = _extractToken(request);
    if (token == null) {
      return _unauthorizedResponse("Access token is required");
    }

    try {
      final jwt = JWT.verify(token, SecretKey(Config.accessTokenSecret));
      final userId = jwt.payload['id'];
      if(userId == null) throw Exception("Invalid User");

      // Attach userId to the request context and forward it
      final updatedRequest = request.change(context: {'userId': userId});
      return innerHandler(updatedRequest);
    } catch (_) {
      return _unauthorizedResponse("Access token is invalid or expired");
    }
  }

  return (innerHandler) => (request) => handleRequest(innerHandler, request);
}

/// Extracts the JWT token from the request's `Authorization` header.
///
/// - The token must be in the format: `Bearer <token>`.
/// - Returns `null` if the token is missing or incorrectly formatted.
String? _extractToken(Request request) {
  final authHeader = request.headers['authorization'];
  return (authHeader != null && authHeader.startsWith('Bearer '))
      ? authHeader.substring(7)
      : null;
}

/// Returns a `403 Forbidden` response with a JSON error message.
///
/// This function is used when:
/// - The token is missing.
/// - The token is invalid or expired.
/// - The user is unauthorized to access the resource.
Response _unauthorizedResponse(String message) {
  return Response.forbidden(
    jsonEncode({'success': false, 'message': message}),
    headers: myApiHeaders,
  );
}