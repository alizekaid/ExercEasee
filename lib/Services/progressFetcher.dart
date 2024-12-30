import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressFetcher {
  // Static method to fetch the user's progress
  static Future<double> fetchUserProgress() async {
    List<double> progressValues = [];
    
    try {
      // Get the current user from Firebase Authentication
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        print('No user is logged in.');
        return 0.0;
      }

      // Get the current user's UID
      String userId = currentUser.uid;

      // Fetch the user's document from the 'Users' collection
      final userDocRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Injuries');

      // Get all injury documents
      final injurySnapshot = await userDocRef.get();

      if (injurySnapshot.docs.isNotEmpty) {
        for (var injuryDoc in injurySnapshot.docs) {
           // Check if the "progress" field exists in the injury document
          if (injuryDoc.exists && injuryDoc.data().containsKey('progress')) {
            // Get the progress for each injury, default to 0.0 if not found
            var progress = injuryDoc['progress'] ?? 0.0;
            progressValues.add(progress.toDouble());
            print("-------------------------------------------------");
            print('Fetched progress for ${injuryDoc.id}: $progress');
            print("-------------------------------------------------");
          } else {
            // If no progress field, print a message and continue
            print("No 'progress' field found for ${injuryDoc.id}. Skipping...");
          }
        }
        // Print the number of fetched progress values
        print('Total fetched progress values: ${progressValues.length}');
        double totalProgress = progressValues.fold(0.0, (sum, progress) => sum + progress);
        print("----------------------------------------------");
        print("Sum of the progress values: ${totalProgress}");
        double avgProgress = totalProgress/progressValues.length;
        print("Average of the progress values: ${avgProgress}");
        return avgProgress;
      } else {
        print('No injuries found for user.');
        return 0.0;
      }
    } catch (e) {
      print('Error fetching user progress: $e');
      return 0.0;
    }

    //return progressValues;
  }
}
