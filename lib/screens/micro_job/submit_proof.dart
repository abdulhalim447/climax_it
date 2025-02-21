import 'dart:io';
import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUploadScreen extends StatefulWidget {
  final String taskID;

  const ImageUploadScreen({super.key, required this.taskID});

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  XFile? _image;
  final TextEditingController _proofMessageController = TextEditingController();
  bool _isUploading = false; // Track upload state

  // Function to pick image
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  // Function to submit data
  Future<void> submitData(XFile image, String proofMessage) async {
    setState(() {
      _isUploading = true; // Show progress indicator
    });

    final String? userID = await UserSession.getUserID();
    final uri = Uri.parse('https://climaxitbd.com/php/micro_job/submit-proof.php');
    var request = http.MultipartRequest('POST', uri);

    // Add fields
    request.fields['task_id'] = widget.taskID;
    request.fields['user_id'] = userID!;
    request.fields['proof_message'] = proofMessage;

    // Add image
    request.files.add(await http.MultipartFile.fromPath('screenshot', image.path));

    // Send request
    var response = await request.send();

    // Hide progress indicator and show message
    setState(() {
      _isUploading = false;
    });

    if (response.statusCode == 200) {
      // Show success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data submitted successfully!'),
        backgroundColor: Colors.green,
      ));
    } else {
      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit data. Please try again!'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  image: _image == null
                      ? null
                      : DecorationImage(
                      image: FileImage(File(_image!.path)),
                      fit: BoxFit.cover),
                ),
                child: _image == null
                    ? Center(child: Text("Tap to select image"))
                    : null,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _proofMessageController,
              decoration: InputDecoration(
                labelText: 'Proof Message',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_image != null && _proofMessageController.text.isNotEmpty) {
                  submitData(_image!, _proofMessageController.text);
                } else {
                  // Show error Snackbar if fields are not filled
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please select an image and enter a proof message.'),
                    backgroundColor: Colors.orange,
                  ));
                }
              },
              child: _isUploading
                  ? CircularProgressIndicator(color: Colors.white) // Show progress bar
                  : Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
