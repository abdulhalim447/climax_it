import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import '../support/support_screen.dart';

class DigitalServiceScreen extends StatefulWidget {
  @override
  State<DigitalServiceScreen> createState() => _DigitalServiceScreenState();
}

class _DigitalServiceScreenState extends State<DigitalServiceScreen> {
  List<dynamic> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApps();
  }

  Future<void> fetchApps() async {
    try {
      final response = await http.get(Uri.parse(
          'https://climaxitbd.com/php/digital_services/get_digital_srvice.php'));

      if (response.statusCode == 200) {
        setState(() {
          services = json.decode(response.body);
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching apps: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Services'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1 / 1.2,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return AppGridItem(services: services[index]);
        },
      ),
    );
  }
}

class AppGridItem extends StatelessWidget {
  final dynamic services;

  const AppGridItem({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SupportScreen()), // Navigate to the support screen
        );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: services['logo'],
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Transform.scale(
                    scale: 0.2, child: const CircularProgressIndicator(value: 0.5)),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                services['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "৳" + services['amount'].toString(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
