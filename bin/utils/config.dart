import 'dart:io';

class Config {
  static final env= Platform.environment['SHELF_ENV'] ?? 'development';
  static final ip= InternetAddress.anyIPv4; // Use any available host
  static final port= int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  static final accessTokenSecret= Platform.environment['ACCESS_TOKEN_SECRET'] ?? 'ACCESS_TOKEN_SECRET';
  static final accessTokenDuration= int.tryParse(Platform.environment['ACCESS_TOKEN_DURATION'] ?? '15') ?? 15; // minutes
  static final refreshTokenSecret= Platform.environment['REFRESH_TOKEN_SECRET'] ?? 'REFRESH_TOKEN_SECRET';
  static final refreshTokenDuration= int.tryParse(Platform.environment['REFRESH_TOKEN_DURATION'] ?? '1') ?? 1; // day
  static final mongodbUri= Platform.environment['TODOS_API_DB_URI'] ?? 'mongodb://localhost/todoapp';  
}