import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // For timing functionality
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore integration
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication

class GifDisplayPage extends StatefulWidget {
  final String muscleName;
  final int painLevel;

  // Constructor to receive the muscleName and painLevel
  const GifDisplayPage({super.key, required this.muscleName, required this.painLevel});

  @override
  _GifDisplayPageState createState() => _GifDisplayPageState();
}

class _GifDisplayPageState extends State<GifDisplayPage> {
  List<String> gifUrls = []; // List to store URLs for the gifs
  List<Widget> gifs = []; // List to store the actual gif widgets

  late DateTime _startTime; // Record start time when page loads
  int _totalTimeSpent = 0; // Total time spent on this page (in seconds)
  double _currentProgress = 0.0; // Current progress value
  Timer? _timer; // Timer to track time spent

  // Firestore references
  final User? _user = FirebaseAuth.instance.currentUser; // Current user
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // Record the start time
    _fetchProgress();
    fetchGifUrls(); // Fetch the list of GIF URLs on initialization

    // Start tracking time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _totalTimeSpent += 1; // Increment time spent
      });
      //_updateProgressInFirestore(); // Update progress every given second
    });
  }

 // Function to fetch the progress value from Firestore
  Future<void> _fetchProgress() async {
    if (_user == null) {
      debugPrint('User not logged in');
      return;
    }

    try {
      // Reference to the user's specific body part document
      DocumentReference injuryDoc = _firestore
          .collection('Users')
          .doc(_user!.uid)
          .collection('Injuries')
          .doc(widget.muscleName);

      // Get the progress value from Firestore
      DocumentSnapshot snapshot = await injuryDoc.get();

      if (snapshot.exists) {
        setState(() {
          _currentProgress = snapshot['progress'] ?? 0.0; // Set the progress from Firestore
        });
      }
    } catch (e) {
      debugPrint('Error fetching progress from Firestore: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when exiting the page
    _updateProgressInFirestore(); // Save progress in Firestore when th page is closed
    super.dispose();
  }

  // Function to update progress in Firestore
  Future<void> _updateProgressInFirestore() async {
    if (_user == null) {
      debugPrint('User not logged in');
      return;
    }

    // Calculate progress increment (7% for every 26 minutes or 1560 seconds)
    double progressIncrement = (_totalTimeSpent / 1560 * 7);
    _currentProgress += progressIncrement;
    //print(_currentProgress);

    try {
      // Reference to the user's specific body part document
      DocumentReference injuryDoc = _firestore
          .collection('Users')
          .doc(_user!.uid)
          .collection('Injuries')
          .doc(widget.muscleName);

      // Update the progress field in Firestore
      await injuryDoc.set({'progress': _currentProgress}, SetOptions(merge: true));

      debugPrint('Progress updated successfully: $_currentProgress%');
    } catch (e) {
      debugPrint('Error updating progress in Firestore: $e');
    }
  }

  // Function to fetch GIF URLs from the API
  Future<void> fetchGifUrls() async {
    try {
      final response = await http.get(Uri.parse(
          'http://13.60.40.160:3000/get-gif/${widget.muscleName}/${widget.painLevel}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          gifUrls = List<String>.from(data['gifs']); // Store the list of gif URLs
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
    List<Widget> loadedGifs = []; // To store gif widgets

    for (String gifUrl in gifUrls) {
      try {
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

    setState(() {
      gifs = loadedGifs; // Update the UI with the loaded GIFs
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 0, 68, 255)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 68, 255),
              Color.fromARGB(255, 114, 133, 255),
              Color.fromARGB(255, 165, 176, 247)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
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
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),

              // GIF GridView
              Expanded(
                child: gifs.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 columns
                          crossAxisSpacing: 8.0, // Space between columns
                          mainAxisSpacing: 8.0, // Space between rows
                        ),
                        itemCount: gifs.length, // Number of GIFs
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
                            child: gifs[index],
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
