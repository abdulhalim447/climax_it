import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  List<String> _imageUrls = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStoredImages();
    _fetchImages();
  }

  Future<void> _saveImages(List<String> imageUrls) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('imageUrls', imageUrls);
  }

  Future<void> _loadStoredImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _imageUrls = prefs.getStringList('imageUrls') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _fetchImages() async {
    try {
      final response = await http.get(
        Uri.parse('https://climaxitbd.com/php/sliders/sliders.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> newImageUrls = (data['sliders'] as List)
            .map((image) => image as String)
            .toList();

        // Save to SharedPreferences
        await _saveImages(newImageUrls);

        setState(() {
          _imageUrls = newImageUrls;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load images. Error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    if (_imageUrls.isEmpty) {
      return const Center(child: Text("No images available."));
    }

    return Column(
      children: [
        CarouselSlider.builder(
          options: CarouselOptions(
            height: 150.0,
            autoPlay: true,
            aspectRatio: 16 / 9,
            enlargeFactor: 0.3,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              _selectedIndex.value = index;
            },
          ),
          itemCount: _imageUrls.length,
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                width: double.maxFinite,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Image.network(
                  _imageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Image failed to load',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }
}
