import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'fitness_app_theme.dart';
import 'gif_display_page.dart';
import 'package:http/http.dart' as http;

class DiagnoseInjuries extends StatelessWidget {
  final List<String> injuries = [
    'Cervical Herniated Disc',
    'Neck Stiffness',
    'Shoulder Impingement',
    "Tennis Elbow",
    "Golfer's Elbow",
    'Carpal Tunnel Syndrome',
    'Extensor Tendon Injury',
    'Weakness in Muscles Around the Scapula',
    'Scoliosis',
    'Lumbar Herniated Disc',
    'Sacroiliac Joint Degeneration',
    'Osteoarthritis of The Hip',
    'Meniscus Tear In the Knee',
    'Anterior Cruciate Ligament Injury',
    'Ligament Injuries',
    'Ankle Sprain',
    'Heel Spur',
  ];


// Firebase instance to interact with Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Function to fetch GIF URLs based on muscle name and pain level
  Future<List<String>> _fetchGifUrls({
    required String muscleName,
    required int painLevel,
  }) async {
    try {
      final response = await http.get(Uri.parse(
          'http://13.60.40.160:3000/get-gif/$muscleName/$painLevel'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Return the list of GIF URLs
        return List<String>.from(data['gifs']);
      } else {
        throw Exception('Failed to fetch GIF URLs');
      }
    } catch (e) {
      print("Error fetching GIFs: $e");
      return []; // Return an empty list in case of an error
    }
  }

  // Method to send injury info to Firestore
  Future<void> sendInjuryInfo({
    required String userId,
    required String muscleName, 
    required int painLevel,
  }) async {
    try {
       String formattedMuscleName = muscleName.replaceAll(' ', '_');
        List<String> gifUrls = await _fetchGifUrls(muscleName: formattedMuscleName, painLevel: painLevel);

       final injuriesCollection = _firestore
          .collection('Users')
          .doc(userId)
          .collection('Injuries');

      // Directly reference the injury document by formattedMuscleName as the document ID
      final injuryDocRef = injuriesCollection.doc(formattedMuscleName);

      // Fetch the document to check if it exists
      final injuryDocSnapshot = await injuryDocRef.get();

      if (injuryDocSnapshot.exists) {
        // Document exists, don't overwrite
        print("Injury information already exists, not overwriting.");
      } else {
        // Document does not exist, create a new one with formattedMuscleName as document ID
        final injuryData = {
          'muscleName': muscleName,
          'painLevel': painLevel,
          'gifUrls': gifUrls,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await injuryDocRef.set(injuryData); // Create the document with set()

        print("Injury information added successfully");
      }
    } catch (e) {
      print("Error handling injury information: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("Diagnosed Injuries"),
        ),
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: injuries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: FitnessAppTheme.white, backgroundColor: FitnessAppTheme.nearlyBlue.withOpacity(0.8), // Button text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          onPressed: () async {
                            String formattedName = injuries[index].replaceAll(' ', '_');
                            
                            User? user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              // Send injury info to Firestore
                              await sendInjuryInfo(
                                userId: user.uid,
                                muscleName: formattedName,
                                painLevel: 0, // Replace with actual pain level if needed
                              );
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GifDisplayPage(
                                  muscleName: formattedName,
                                  painLevel: 0,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            injuries[index],
                            style: (FitnessAppTheme.textTheme.bodyLarge ??
                                    const TextStyle(
                                        fontSize: 16, color: Colors.white))
                                .copyWith(color: FitnessAppTheme.white),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future.delayed(const Duration(seconds: 2));
    return true; 
  }
}
