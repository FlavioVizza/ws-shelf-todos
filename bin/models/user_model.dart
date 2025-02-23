import 'package:bcrypt/bcrypt.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../bin/server.dart';

class User {
  ObjectId? id;
  String username;
  String email;
  String hasedPassword;
  String salt;
  DateTime created;

  User({
    this.id,
    required this.username,
    required this.email,
    this.hasedPassword = '',
    this.salt = '',
    DateTime? created,
  }) : created = created ?? DateTime.now();

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['_id'],
    username: map['username'],
    email: map['email'],
    hasedPassword: map['hasedPassword'],
    salt: map['salt'],
    created: map['created'],
  );

  Map<String, dynamic> toMap() => {
    'username': username,
    'email': email,
    'hasedPassword': hasedPassword,
    'salt': salt,
    'created': created,
  };

  void setPassword(String password) {
    salt = _generateSalt();
    hasedPassword = _encryptedPassword(password, salt);
    return;
  }

  bool authenticate(String password) =>
      _encryptedPassword(password, salt) == hasedPassword;

  String _encryptedPassword(String password, String salt) =>
      BCrypt.hashpw(password, salt).toString();

  String _generateSalt() =>
    BCrypt.gensalt(logRounds: 10);
  
  Future<void> save() async {
    final collection = db.collection('users');
    final userData = await collection.findOne({'email': email});

    if (userData != null) {
      throw Exception('User already exists');
    }

    var result = await collection.insertOne({
      'username': username,
      'email': email,
      'hashed_password': hasedPassword,
      'salt': salt,
      'created': created,
    });

    if(!result.isSuccess){
      throw Exception('Generic Error registering user');
    }

    return;
  }

  static Future<User?> findByEmail(String email) async {
    final collection = db.collection('users');
    final userData = await collection.findOne({'email': email});
    if (userData == null) return null;

    return User(
      id:  userData['_id'],
      username: userData['username'],
      email: userData['email'],
      hasedPassword: userData['hashed_password'],
      salt: userData['salt'],
      created: userData['created']
    );
  }
  
}
