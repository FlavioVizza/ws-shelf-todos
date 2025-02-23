import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import '../models/user_model.dart';
import '../utils/config.dart';
import '../utils/constants.dart';

/// **Generate an access token**
///
/// This function generates a JWT (JSON Web Token) for the given payload. 
/// The token is signed using the access token secret and is set to expire 
/// based on the configured duration.
///
/// **Parameters**:
/// - `payload`: A `Map<String, dynamic>` containing the data to be included 
/// in the token's payload.
///
/// **Returns**: A `String` representing the signed access token.
String _generateAccessToken(Map<String, dynamic> payload){
  final jwt = JWT(payload);
  return jwt.sign(
    SecretKey(Config.accessTokenSecret),
    expiresIn: Duration(minutes: Config.accessTokenDuration)
  );
}

/// **Generate a refresh token**
///
/// This function generates a JWT (JSON Web Token) for the given payload. 
/// The token is signed using the refresh token secret and is set to expire 
/// based on the configured duration.
///
/// **Parameters**:
/// - `payload`: A `Map<String, dynamic>` containing the data to be included 
/// in the token's payload.
///
/// **Returns**: A `String` representing the signed refresh token.
String _generateRefreshToken(Map<String, dynamic> payload){
  final jwt = JWT(payload);
  return jwt.sign(
    SecretKey(Config.refreshTokenSecret),
    expiresIn: Duration(days: Config.refreshTokenDuration)
  );
}

/// **Register a new user**
///
/// This function registers a new user by accepting a JSON payload containing
/// the `username`, `email`, and `password`. The password is hashed before 
/// saving the user data. If the registration is successful, a `201 Created` 
/// response is returned, otherwise, a `500 Internal Server Error` response 
/// with the error message is returned.
///
/// **Returns**: A `201 Created` response with a success message or a `500 Internal Server Error` 
/// if the registration fails.
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

/// **Login a user**
///
/// This function authenticates the user by verifying the provided `email` 
/// and `password`. If authentication is successful, it generates an `accessToken` 
/// and a `refreshToken`. If the credentials are invalid, it returns a `401 Unauthorized` 
/// response.
///
/// **Returns**: A `200 OK` response with the access and refresh tokens if login is successful, 
/// or a `401 Unauthorized` response if credentials are invalid.
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

/// **Refresh access token using a refresh token**
///
/// This function allows the user to refresh their access token by using a valid 
/// refresh token. If the refresh token is expired or invalid, it returns a `500` 
/// response with an appropriate error message. If the refresh is successful, 
/// a new `accessToken` and `refreshToken` are generated and returned.
///
/// **Returns**: A `200 OK` response with new access and refresh tokens if the refresh is successful, 
/// or a `500 Internal Server Error` response if there is an issue refreshing the token.
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