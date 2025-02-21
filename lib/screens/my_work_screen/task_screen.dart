import 'package:flutter/material.dart';
import 'instruction_screen.dart';
import 'task_service.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskService _taskService = TaskService();
  late Future<List<dynamic>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = _taskService.fetchTasks(); // API থেকে ডেটা ফেচ করা
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("টাস্ক লিস্ট"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  id: task["id"] ?? "N/A".toString(),
                  title: task["title"] ?? "N/A",
                  thumbnail: task["thumbnail"] ?? "",
                  subtitle: task["subtitle"] ?? "",
                  taskData: task,
                );
              },
            );
          } else {
            return const Center(child: Text("No tasks found"));
          }
        },
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final int id;
  final String title;
  final String thumbnail;
  final String subtitle;
  final Map<String, dynamic> taskData;

  const TaskCard({
    Key? key,
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
    required this.taskData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstructionScreen(task: taskData),
            ),
          );
        },
        child: Card(
          color: Colors.blue[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Image.network(
                    thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 100);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
