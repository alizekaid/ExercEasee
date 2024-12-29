import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore integration
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'dart:async'; // For timing functionality

class RecentInjuries extends StatefulWidget {
  final String muscleName;
  final List<String> gifUrls;

  const RecentInjuries({
    Key? key,
    required this.muscleName,
    required this.gifUrls,
  }) : super(key: key);

  @override
  _RecentInjuriesState createState() => _RecentInjuriesState();
}

class _RecentInjuriesState extends State<RecentInjuries> {
  double? _currentProgress; // Current progress value, now nullable
  int _totalTimeSpent = 0; // Total time spent on this page (in seconds)
  Timer? _timer; // Timer to track time spent

  // Firestore references
  final User? _user = FirebaseAuth.instance.currentUser; // Current user
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchProgress(); // Fetch the user's progress from Firestore when the page is opened
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when exiting the page
    super.dispose();
  }

  // Function to fetch progress from Firestore
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

      // Start the timer only after the progress has been fetched
      _startTimer();
    } catch (e) {
      debugPrint('Error fetching progress from Firestore: $e');
    }
  }

  // Function to start tracking time after progress is fetched
  void _startTimer() {
    if (_currentProgress != null) {
      _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
        setState(() {
          _totalTimeSpent += 30; // Increment time spent by 1 second
        });
        _updateProgressInFirestore(); // Update progress in Firestore every 30 second
      });
    }
  }

  // Function to update progress in Firestore
 Future<void> _updateProgressInFirestore() async {
  if (_user == null || _currentProgress == null) {
    debugPrint('User not logged in or progress not available');
    return;
  }

  // Calculate progress increment (7% for every 26 minutes or 1560 seconds)
  double progressIncrement = (_totalTimeSpent / 1560 * 7); // Calculate progress increment

  // Cap the increment to 7% max
  if (progressIncrement > 7) {
    progressIncrement = 7;
  }

  // Accumulate progress (add the progress increment to the existing value)
  double newProgress = (_currentProgress ?? 0) + progressIncrement;
  if (newProgress > 7) {
    newProgress = 7; // Ensure it doesn't exceed 100% progress
  }

  setState(() {
    _currentProgress = newProgress; // Update current progress
  });

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.muscleName),
      ),
      body: widget.gifUrls.isEmpty
          ? Center(child: Text('No GIFs available'))
          : Column(
              children: [
                // Progress display
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _currentProgress == null
                      ? CircularProgressIndicator() // Show loading indicator while progress is being fetched
                      : Text(
                          "Progress: ${_currentProgress!.toStringAsFixed(2)}%",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                ),

                // Displaying the GIFs
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.gifUrls.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Image.network(widget.gifUrls[index]),
                            SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
