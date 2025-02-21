import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';

import '../../auth/saved_login/user_session.dart';

class AppGridScreen extends StatefulWidget {
  @override
  _AppGridScreenState createState() => _AppGridScreenState();
}

class _AppGridScreenState extends State<AppGridScreen> {
  List<dynamic> apps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApps();
  }

  Future<void> fetchApps() async {
    try {
      final response = await http.get(Uri.parse('https://climaxitbd.com/php/apps/get_apps.php'));

      if (response.statusCode == 200) {
        setState(() {
          apps = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load apps');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching apps: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App List'),
      ),
      body: isLoading
          ? Center(child: Transform.scale(
          scale: 0.2, child: const CircularProgressIndicator(value: 0.5)))
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1 / 1.4,
        ),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          return AppGridItem(app: apps[index]);
        },
      ),
    );
  }
}

class AppGridItem extends StatefulWidget {
  final dynamic app;

  const AppGridItem({super.key, required this.app});

  @override
  State<AppGridItem> createState() => _AppGridItemState();
}

class _AppGridItemState extends State<AppGridItem> {
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkIfPremium();
  }

  void _checkIfPremium() {
    setState(() {
      _isPremium = widget.app['type'] == '1';
    });
  }

  Future<void> _downloadFileWithDio() async {
    try {
      Directory? customDirectory = Directory('/storage/emulated/0/Download/');
      if (!await customDirectory.exists()) {
        await customDirectory.create(recursive: true);
      }
      String savePath = '${customDirectory.path}/downloaded_file.zip';

      Dio dio = Dio();
      await dio.download(
        widget.app['zip_link'],
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print((received / total * 100).toStringAsFixed(0) + "%");
          }
        },
      );
      print("Download completed at: $savePath");

      _showOpenFileDialog(savePath); // Show Open dialog
    } catch (e) {
      print("Download failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  void _showOpenFileDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Download Complete"),
          content: Text("Do you want to open the file?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openFile(filePath); // Open the file
              },
              child: Text("Open"),
            ),
          ],
        );
      },
    );
  }

  void _openFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      OpenFile.open(filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Navigating to ${widget.app['app_name']} detail screen.");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: widget.app['app_logo'],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Transform.scale(
                            scale: 0.2, child: const CircularProgressIndicator(value: 0.5)),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  ),
                ),
                if (_isPremium)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "৳" + widget.app['amount'].toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.app['app_name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_isPremium) {
                      _showPremiumDialog();
                    } else {
                      if (await Permission.storage.request().isGranted) {
                        _downloadFileWithDio(); // Call the download function
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission Denied')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Download',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            if (_isPremium)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/icons/premium.png', // Ensure you have this asset
                      height: 18,
                      width: 18,
                      color: Colors.white,
                    )),
              ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("প্রিমিয়াম অ্যাপ"),
          content: Text("অ্যাপটি পেইড। আপনার শপিং ব্যালেন্স থেকে টাকা কেটে নেওয়া হবে। আপনি কি অ্যাপটি ক্রয় করতে ইচ্ছুক? "),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("না"),
            ),
            TextButton(
              onPressed: () async{

                if (await Permission.storage.request().isGranted) {
                 // Call the download function
                  _deductBalance();
                } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission Denied')));
                }
                Navigator.of(context).pop();
                // Add logic for premium action here
              },
              child: Text("হ্যাঁ"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deductBalance() async {
    final String?  userID = await UserSession.getUserID();
    double amount = double.tryParse(widget.app['amount']) ?? 0.0;
    try {
      var response = await http.post(

        Uri.parse("https://climaxitbd.com/php/wallet/decrease-shop-balance.php"),
        headers: {"Content-Type": "application/json"},


        body: jsonEncode({
          "user_id": userID,
          "action": "deduct_balance",
          "amount": amount,
        }),
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == "success") {
        setState(() {
          _downloadFileWithDio();
        });
        //print(responseData['message']);
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage("অ্যাপ কেনা সম্ভব হয়নি!");
    }
  }

  // মেসেজ দেখানোর ফাংশন
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


}

