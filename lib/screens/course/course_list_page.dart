import 'package:flutter/material.dart';
import 'course_details_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoItem {
  final String imageUrl;
  final String title;
  final String duration;
  final String videoLink;

  VideoItem({
    required this.imageUrl,
    required this.title,
    required this.duration,
    required this.videoLink,
  });
}



class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  late Future<List<VideoItem>> videoList;

  @override
  void initState() {
    super.initState();
    videoList = fetchVideos(); // Fetch the videos when the screen loads
  }


  // Replace 'YOUR_API_URL' with the actual URL of your PHP file
  Future<List<VideoItem>> fetchVideos() async {
    final response = await http.get(Uri.parse('https://climaxitbd.com/php/course/get_videos_list.php'));



    if (response.statusCode == 200) {
      List data = json.decode(response.body);

      return data.map((video) => VideoItem(
        imageUrl: video['image_url'],
        title: video['title'],
        duration: video['duration'],
        videoLink: video['video_link'],
      )).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video List'),
      ),
      body: FutureBuilder<List<VideoItem>>(
        future: videoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for the data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if the request fails
            return Center(child: Text('Failed to load videos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if there is no data
            return Center(child: Text('No videos available.'));
          } else {
            // Display the video list when data is available
            final videos = snapshot.data!;
            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to a different page when clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoDetailPage(videoLink: video.videoLink),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Column(
                            children: [
                              // Image Thumbnail with fixed size
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  video.imageUrl,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        // Video Title and Duration
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Duration: " + video.duration,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
