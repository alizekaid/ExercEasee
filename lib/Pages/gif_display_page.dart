import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GifDisplayPage extends StatefulWidget {
  final String muscleName;
  final int painLevel;

  // Constructor to receive the muscleName and painLevel
  const GifDisplayPage({super.key, required this.muscleName, required this.painLevel});

  @override
  _GifDisplayPageState createState() => _GifDisplayPageState();
}

class _GifDisplayPageState extends State<GifDisplayPage> {
  List<String> gifUrls = [];  // List to store URLs for the gifs
  List<Widget> gifs = [];  // List to store the actual gif widgets

  @override
  void initState() {
    super.initState();
    fetchGifUrls();  // Fetch the list of GIF URLs on initialization
  }

  // Function to fetch GIF URLs from the API
  Future<void> fetchGifUrls() async {
    try {
      // Use the muscleName and painLevel passed from the previous page
      final response = await http.get(Uri.parse(
          'http://13.49.238.112:3000/get-gif/${widget.muscleName}/${widget.painLevel}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          gifUrls = List<String>.from(data['gifs']);  // Store the list of gif URLs
        });

        // Now fetch each gif
        fetchGifs();
      } else {
        throw Exception('Failed to load GIF URLs');
      }
    } catch (error) {
      print("Error fetching GIFs: $error");
    }
  }

  // Function to fetch each GIF and create widgets for them
  Future<void> fetchGifs() async {
    List<Widget> loadedGifs = [];  // To store gif widgets

    for (String gifUrl in gifUrls) {
      try {
        // Fetch the actual GIF
        final response = await http.get(Uri.parse(gifUrl));

        if (response.statusCode == 200) {
          loadedGifs.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4.0,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        gifUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Failed to load GIF'));
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          print("Failed to load GIF from: $gifUrl");
        }
      } catch (e) {
        print("Error fetching GIF: $e");
      }
    }

    // Update the UI with the loaded GIFs
    setState(() {
      gifs = loadedGifs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 0, 68, 255), Color.fromARGB(255, 114, 133, 255), Color.fromARGB(255, 165, 176, 247)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst başlık
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Exercise GIFs",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Here are the GIFs for the selected muscle.",
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),

              // GridView - GIF'lerin gösterildiği bölüm
              Expanded(
                child: gifs.isEmpty
                    ? const Center(child: CircularProgressIndicator())  // GIF'ler yüklenene kadar yükleme göstergesi
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,  // 2 kolon
                          crossAxisSpacing: 8.0,  // Kolonlar arası boşluk
                          mainAxisSpacing: 8.0,  // Satırlar arası boşluk
                        ),
                        itemCount: gifs.length,  // GIF sayısına göre dinamik değişir
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: gifs[index],  // GIF widget'ı göster
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
