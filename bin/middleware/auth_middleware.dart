import 'dart:convert';
import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../utils/config.dart';
import '../utils/constants.dart';

Middleware authenticateToken() {
  Future<Response> handleRequest(Handler innerHandler, Request request) async {
    final token = _extractToken(request);
    if (token == null) {
      return _unauthorizedResponse("Access token is required");
    }

    try {
      final jwt = JWT.verify(token, SecretKey(Config.accessTokenSecret));
      final userId = jwt.payload['id'];
      if(userId == null) throw Exception("Invalid User");
      final updatedRequest = request.change(context: {'userId': userId});
      return innerHandler(updatedRequest);
    } catch (_) {
      return _unauthorizedResponse("Access token is invalid or expired");
    }
  }

  return (innerHandler) => (request) => handleRequest(innerHandler, request);
}

String? _extractToken(Request request) {
  final authHeader = request.headers['authorization'];
  return (authHeader != null && authHeader.startsWith('Bearer '))
      ? authHeader.substring(7)
      : null;
}

Response _unauthorizedResponse(String message) {
  return Response.forbidden(
    jsonEncode({'success': false, 'message': message}),
    headers: myApiHeaders,
  );
}

