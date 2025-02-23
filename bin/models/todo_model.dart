import 'package:mongo_dart/mongo_dart.dart';

class Todo {
  ObjectId? id;
  ObjectId userId;
  int todoId;
  String title;
  String description;
  bool completed;
  DateTime createAt;

  Todo({
    this.id,
    required this.userId,
    required this.todoId,
    required this.title,
    required this.description,
    this.completed = false,
    DateTime? createAt,
  }) : createAt = createAt ?? DateTime.now();

  /// **Converti da MongoDB (Map) a Oggetto Dart**
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['_id'] as ObjectId?,
      userId: map['userId'] as ObjectId,
      todoId: map['todoId'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      completed: map['completed'] as bool? ?? false,
      createAt: (map['createAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  /// **Converti da Oggetto Dart a MongoDB (Map)**
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'todoId': todoId,
      'title': title,
      'description': description,
      'completed': completed,
      'createAt': createAt,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'todoId': todoId,
      'title': title,
      'description': description,
      'completed': completed,
      'createAt': createAt.toIso8601String(), // Formato leggibile
    };
  }

  Map<String, dynamic> toJsonResponse() {
    return {
      'todoId': todoId,
      'title': title,
      'description': description,
      'completed': completed,
      'createAt': createAt.toIso8601String(), // Formato leggibile
    };
  }

  /// **Genera un nuovo `todoId` incrementale come in Mongoose**
  static Future<int> getNextTodoId(DbCollection collection) async {
    final lastTodo = await collection.findOne(
      where.sortBy('todoId', descending: true),
    );

    return (lastTodo?['todoId'] as int? ?? 0) + 1;
  }
}
