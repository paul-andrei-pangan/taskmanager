import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanager/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch tasks from Firestore
  Stream<List<Task>> getTasks() {
    return _firestore.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  // Add a new task to Firestore
  Future<void> addTask(Task task) async {
    await _firestore.collection('tasks').add(task.toFirestore());
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}
