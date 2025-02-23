import 'dart:convert';
import 'package:shelf/shelf.dart';

Response helloMsg(Request request){
  final response = {
    'message': 'Hello from todos API',
  };

  return Response.ok(
    headers: { 'Content-Type': 'application/json' },
    jsonEncode(response),
  );

}