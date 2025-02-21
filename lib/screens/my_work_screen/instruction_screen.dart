import 'dart:convert';

import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;


class InstructionScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  InstructionScreen({required this.task});

  @override
  _InstructionScreenState createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  File? _selectedImage;



  // Image picker function
  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }



  void _submitTask() async {
    final String? userID = await UserSession.getUserID();

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an image before submitting."),
        ),
      );
      return;
    }

    // Prepare the data
    String taskId = widget.task['id'] ?? 'N/A';
    String? userId = userID; // Get user ID from wherever it's stored
    String imageUrl = await _uploadImage(_selectedImage!); // Upload image and get URL

    // Prepare the data to be sent to the server
    var data = {
      'task_id': taskId,
      'user_id': userId,
      'screenshot': imageUrl,
    };

    // Send data to the server (API call)
    var response = await http.post(
      Uri.parse('https://climaxitbd.com/php/my_work_section/admin/submitmywork.php'), // Replace with your actual API endpoint
      body: data,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task submitted successfully!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to submit task."),
        ),
      );
    }
  }



  Future<String> _uploadImage(File image) async {
    final String? userID = await UserSession.getUserID();
    // API URL to upload the image
    final Uri url = Uri.parse('https://climaxitbd.com/php/my_work_section/admin/submitmywork.php');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Attach the image to the request
    var imageFile = await http.MultipartFile.fromPath('screenshot', image.path);
    request.files.add(imageFile);

    // Add any other necessary fields
    request.fields['task_id'] = widget.task['id'] ?? 'N/A';
    request.fields['user_id'] = userID!; // Replace with the actual user ID

    try {
      // Send the request
      var response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        // If the upload was successful, return the image URL
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return data['image_url']; // Adjust this based on your API response
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return an empty string or handle error properly
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("কাজের বিস্তারিত"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task details
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "টাইটেল : ${widget.task['title'] ?? 'N/A'}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "সাবটাইটেল : ${widget.task['subtitle'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "পয়েন্টস : ${widget.task['points'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "কাজের ধরন : ${widget.task['task_type'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "সময় লাগবে : ${widget.task['duration'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Task details
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.lightGreen.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "বিস্তারিত :",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task['details'] ?? "কোনো ডিটেইলস পাওয়া যায়নি।",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Image selection box
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Text("Tap to select an image"),
                        )
                      : Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Submit button
              Center(
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: _submitTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "জমা দিন",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
