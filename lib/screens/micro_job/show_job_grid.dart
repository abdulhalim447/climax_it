import 'dart:convert';
import 'package:climax_it_user_app/screens/micro_job/work_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowJobGrid extends StatefulWidget {
  @override
  _ShowJobGridState createState() => _ShowJobGridState();
}

class _ShowJobGridState extends State<ShowJobGrid> {
  bool isLoading = true;
  List<dynamic> apiData = [];

  // API থেকে ডেটা ফেচ করার ফাংশন
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://climaxitbd.com/php/micro_job/get_micro_tasks.php'));

    if (response.statusCode == 200) {
      setState(() {
        apiData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // API কল
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('মাইক্রো জব'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // লোডিং বার
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.6,
          ),
          itemCount: apiData.length,
          itemBuilder: (context, index) {
            return ItemCard(index: index, apiData: apiData);
          },
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final int index;
  final List<dynamic> apiData;

  ItemCard({required this.index, required this.apiData});

  @override
  Widget build(BuildContext context) {
    final item = apiData[index];

    return GestureDetector(
      onTap: () {
        // Navigate to MicroWorkScreen and pass data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MicroWorkScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(item['thumbnail'], height: 110, fit: BoxFit.cover),
            Text(
              item['title'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              item['price'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
