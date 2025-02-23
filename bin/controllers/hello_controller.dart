import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Handles the request and returns a "Hello from todos API" message.
///
/// This function is an HTTP request handler that responds with a JSON message 
/// saying "Hello from todos API". It uses the `shelf` package to create a 
/// response with a status of `200 OK` and includes a `Content-Type` header 
/// of `application/json`. The response body contains the greeting message 
/// in JSON format.
///
/// The `helloMsg` function is typically used as a simple endpoint to test 
/// connectivity or verify that the API is running.
Response helloMsg(Request request){
  final response = {
    'message': 'Hello from todos API',
  };

  return Response.ok(
    headers: { 'Content-Type': 'application/json' },
    jsonEncode(response),
  );

}