import 'package:flutter/material.dart';
import 'package:taskmanager/services/task_service.dart';
import 'package:taskmanager/models/task_model.dart';
import 'package:taskmanager/screens/add_task_screen.dart';
import 'package:taskmanager/screens/settings_screen.dart';
import 'package:taskmanager/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  String _selectedCategory = "All";
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTasks = {}; // 🔹 For multiple delete selection

  @override
  void initState() {
    super.initState();
    refreshTasks();
  }

  Future<void> refreshTasks() async {
    _taskService.getTasks().listen((tasks) {
      setState(() {
        _tasks = tasks;
        _filteredTasks = tasks; // Default: Show all tasks
      });
    });
  }

  void _searchTasks(String query) {
    setState(() {
      _filteredTasks = _tasks
          .where((task) =>
      task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToAddTask() async {
    final bool? taskAdded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    if (taskAdded == true) {
      await refreshTasks();
      await NotificationService.showNotification("New Task Added!");

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task added successfully!')),
          );
        }
      });
    }
  }

  void _toggleTaskCompletion(Task task) async {
    await _taskService.toggleTaskCompletion(task);

    if (!task.isCompleted) {
      // ✅ DELETE TASK FROM FIREBASE ONCE COMPLETED
      await Future.delayed(const Duration(milliseconds: 500));
      await _taskService.deleteTask(task.id);
    }

    await refreshTasks();
  }

  void _deleteSelectedTasks() async {
    if (_selectedTasks.isEmpty) return;

    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      for (String taskId in _selectedTasks) {
        await _taskService.deleteTask(taskId);
      }
      _selectedTasks.clear();
      await refreshTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected tasks deleted successfully!')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasks'),
        content: const Text('Are you sure you want to delete the selected tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.orange;
      case 'Personal':
        return Colors.blue;
      case 'Urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteSelectedTasks, // 🔹 Multiple delete
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchTasks,
              decoration: InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // 🔹 Category Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: ["All", "Work", "Personal", "Urgent"]
                  .map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "Filter by Category",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // 🔹 Task List
          Expanded(
            child: _filteredTasks.isEmpty
                ? const Center(child: Text("No tasks available."))
                : ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Checkbox(
                      value: _selectedTasks.contains(task.id),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedTasks.add(task.id);
                          } else {
                            _selectedTasks.remove(task.id);
                          }
                        });
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.description),
                        Text(
                          "Category: ${task.category}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getCategoryColor(task.category),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            color: task.isCompleted ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => _toggleTaskCompletion(task),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 🔹 Floating Button to Add Task
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
