import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/todo_model.dart';
import '../utils/constants.dart';
import '../../bin/server.dart';

/// **Ottieni tutti i todo dell'utente autenticato**
Future<Response> getTodoList(Request request) async {
  try {
    final userId = request.context['userId'] as String;
    final userIdObject = ObjectId.fromHexString(userId);

    final todos = await db.collection('todos')
        .find(where.eq('userId', userIdObject)//.fields(['todoId', 'title', 'description', 'completed', 'createAt'])
        //.excludeFields(['_id', 'userId']))
        ).map((todo){
          return Todo.fromMap(todo).toJsonResponse();
        })
        .toList();

    return Response.ok(jsonEncode(todos), headers: myApiHeaders);
  } catch (e) {
    print(e);
    return Response.internalServerError(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Error getting todos list'}));
  }
}

/// **Ottieni un singolo todo**
Future<Response> getTodoItem(Request request, String id) async {
  try {
    final userId = request.context['userId'] as String;
    final todo = await db.collection('todos').findOne(
      where.eq('todoId', int.parse(id)).eq('userId', ObjectId.fromHexString(userId)),
    );

    if (todo == null) {
      return Response.notFound(jsonEncode({'success': false, 'message': 'Todo item not found'}));
    }
    var todoJson = Todo.fromMap(todo).toJsonResponse();
    return Response.ok(headers: myApiHeaders, jsonEncode(todoJson));
  } catch (e) {
    print(e);
    return Response.internalServerError(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Error getting todo item'}));
  }
}

/// **Crea un nuovo todo**
Future<Response> postTodoItem(Request request) async {
  try {
    final userId = request.context['userId'] as String;
    final body = await request.readAsString();
    final data = jsonDecode(body);

    if (data['title'] == null || data['description'] == null) {
      return Response.badRequest(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Title and description are required'}));
    }

    // Genera il prossimo `todoId`
    final nextTodoId = await Todo.getNextTodoId(db.collection('todos'));

    final newTodo = Todo(
      userId: ObjectId.fromHexString(userId),
      todoId: nextTodoId,
      title: data['title'],
      description: data['description'],
    );

    await db.collection('todos').insertOne(newTodo.toMap());

    return Response(201, headers: myApiHeaders, body: jsonEncode({'success': true, 'message': 'Todo item created successfully'}));
  } catch (e) {
    print(e);
    return Response.internalServerError(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Error creating todo item'}));
  }
}

/// **Elimina un todo**
Future<Response> deleteTodoItem(Request request, String id) async {
  try {
    final userId = request.context['userId'] as String;
    final result = await db.collection('todos').deleteOne(
      where.eq('todoId', int.parse(id)).eq('userId', ObjectId.fromHexString(userId)),
    );

    if (result.nRemoved == 0) {
      return Response.notFound(jsonEncode({'success': false, 'message': 'Todo item not found'}));
    }

    return Response.ok(headers: myApiHeaders, jsonEncode({'success': true, 'message': 'Todo item deleted successfully'}));
  } catch (e) {
    print(e);
    return Response.internalServerError(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Error deleting todo item'}));
  }
}

/// **Aggiorna un todo**
Future<Response> putTodoItem(Request request, String id) async {
  try {
    final userId = request.context['userId'] as String;
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final updateData = <String, dynamic>{};
    if (data['title'] != null) updateData['title'] = data['title'];
    if (data['description'] != null) updateData['description'] = data['description'];
    if (data['completed'] != null) updateData['completed'] = data['completed'];

    if (updateData.isEmpty) {
      return Response.badRequest(body: jsonEncode({'success': false, 'message': 'No fields to update'}));
    }

    // Creazione del ModifierBuilder
    final modify = ModifierBuilder();
    updateData.forEach((key, value) {
      modify.set(key, value); // ✅ Usa set() per ogni campo
    });

    final result = await db.collection('todos').updateOne(
      where.eq('todoId', int.parse(id)).eq('userId', ObjectId.fromHexString(userId)),
      modify, // ✅ Passa il ModifierBuilder con i set()
    );

    if (result.nModified == 0) {
      return Response.notFound(jsonEncode({'success': false, 'message': 'Todo item not found'}));
    }

    return Response.ok(jsonEncode({'success': true, 'message': 'Todo item updated successfully'}));
  } catch (e) {
    print(e);
    return Response.internalServerError(body: jsonEncode({'success': false, 'message': 'Error updating todo item'}));
  }
}

Future<Response> putTodoItem2(Request request, String id) async {
  try {
    final userId = request.context['userId'] as String;
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final updateData = <String, dynamic>{};
    if (data['title'] != null) updateData['title'] = data['title'];
    if (data['description'] != null) updateData['description'] = data['description'];
    if (data['completed'] != null) updateData['completed'] = data['completed'];

    if (updateData.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'message': 'No fields to update'}),
      );
    }

    final updatedTodo = await db.collection('todos').findAndModify(
      query: where.eq('todoId', int.parse(id)).eq('userId', ObjectId.fromHexString(userId)),
      update: updateData,
      returnNew: true, // Restituisce il documento aggiornato
    );

    if (updatedTodo == null) {
      return Response.notFound(
        jsonEncode({'success': false, 'message': 'Todo item not found'}),
      );
    }

    return Response.ok(jsonEncode({
      'success': true,
      'message': 'Todo item updated successfully',
      'todo': updatedTodo, // ✅ Invia il documento aggiornato
    }));
  } catch (e) {
    print(e);
    return Response.internalServerError(
      body: jsonEncode({'success': false, 'message': 'Error updating todo item'}),
    );
  }
}

