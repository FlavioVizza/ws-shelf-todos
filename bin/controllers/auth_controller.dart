import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import '../models/user_model.dart';
import '../utils/config.dart';
import '../utils/constants.dart';

String _generateAccessToken(Map<String, dynamic> payload){
  final jwt = JWT(payload);
  return jwt.sign(
    SecretKey(Config.accessTokenSecret),
    expiresIn: Duration(minutes: Config.accessTokenDuration)
  );
}

String _generateRefreshToken(Map<String, dynamic> payload){
  final jwt = JWT(payload);
  return jwt.sign(
    SecretKey(Config.refreshTokenSecret),
    expiresIn: Duration(days: Config.refreshTokenDuration)
  );
}

Future<Response> register(Request request) async {
  try {
    final payload = jsonDecode(await request.readAsString());
    final user = User(username: payload['username'], email: payload['email']);
    user.setPassword(payload['password']);
    await user.save();
    
    return Response(
      201, 
      headers: myApiHeaders,
      body: jsonEncode({'success': true, 'message': 'User registered successfully'})
    );

  } catch (e) {
    return Response(
      500, 
      headers: myApiHeaders,
      body: jsonEncode({'success': false, 'message': e.toString()})
    );
  }
  
}

Future<Response> login(Request request) async {
  final payload = jsonDecode(await request.readAsString());
  final email = payload['email'];
  final password = payload['password'];

  final user = await User.findByEmail(email);
  if(user == null || !user.authenticate(password)){
    return Response(401, 
      headers: myApiHeaders,
      body: jsonEncode({
        'success' : false, 
        'message': 'Invalid credentials'
      })
    );
  }

  final accessToken = _generateAccessToken({ 'id': user.id });
  final refreshToken = _generateRefreshToken({ 'id': user.id });

  return Response.ok(
    headers: myApiHeaders,
    jsonEncode({
      'accessToken': accessToken,
      'refreshToken': refreshToken
    })
  );
}

Future<Response> refreshToken(Request request) async {
  
  var statusCode = 100;
  var body = jsonEncode({});

  final payload = jsonDecode(await request.readAsString());
  final token = payload['refreshToken'];
  if(token == null) {
    return Response(401, 
      headers: myApiHeaders,
      body: jsonEncode({
        'success' : false, 
        'message': 'Refresh token required'
      })
    );
  }

  try {
    final jwt = JWT.verify(token, SecretKey(Config.refreshTokenSecret));
    final accessToken = _generateAccessToken({'id': jwt.payload['id']});
    final newRefreshToken = _generateRefreshToken({'id': jwt.payload['id']});

    statusCode = 200;
    body = jsonEncode({
      'accessToken' : accessToken, 
      'refreshToken': newRefreshToken
    });
    
  } 
  on JWTExpiredException {
    statusCode = 500;
    body = jsonEncode({
      'success' : false, 
      'message': 'Refresh token expired'
    });
  }
  on JWTException {
    statusCode = 500;
    body = jsonEncode({
      'success' : false, 
      'message': 'Invalid refresh token'
    });
  }
  catch (e) {
    statusCode = 500;
    body = jsonEncode({
      'success' : false, 
      'message': 'Error refreshing token'
    });
  }

  return Response(
    statusCode, 
    headers: myApiHeaders, 
    body: body
  );
}