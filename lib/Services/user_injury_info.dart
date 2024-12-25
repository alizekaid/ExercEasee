import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInjuryInformation {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendInjuryInfo({
  required String userId,
  required String muscleName,
  required int painLevel,
}) async {
  try {
    // Fetch GIF URLs from the API
    List<String> gifUrls = await _fetchGifUrls(muscleName: muscleName, painLevel: painLevel);

    // Reference to the user's injuries collection
    final injuriesCollection = _firestore
        .collection('Users')
        .doc(userId)
        .collection('Injuries');

    // Directly reference the injury document by muscleName as the document ID
    final injuryDocRef = injuriesCollection.doc(muscleName); // Use muscleName as document ID

    // Fetch the document to check if it exists
    final injuryDocSnapshot = await injuryDocRef.get();

    if (injuryDocSnapshot.exists) {
      // Document exists, update the painLevel and gifUrls
      await injuryDocRef.update({
        'painLevel': painLevel, // Update painLevel
        'gifUrls': gifUrls,     // Update GIF URLs
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Injury information updated successfully");
    } else {
      // Document does not exist, create a new one with muscleName as document ID
      final injuryData = {
        'muscleName': muscleName,
        'painLevel': painLevel,
        'gifUrls': gifUrls, // Add the GIF URLs to the injury data
        'timestamp': FieldValue.serverTimestamp(),
      };

      await injuryDocRef.set(injuryData); // Create the document with set()

      print("Injury information added successfully");
    }
  } catch (e) {
    print("Error handling injury information: $e");
  }
}


  // Function to make an API call to fetch GIFs
  Future<List<String>> _fetchGifUrls({
    required String muscleName,
    required int painLevel,
  }) async {
    try {
      final response = await http.get(Uri.parse(
          'http://13.49.238.112:3000/get-gif/$muscleName/$painLevel'));

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
}
