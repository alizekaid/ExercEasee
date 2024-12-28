import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Pages/fitness_app_theme.dart';
import 'package:first_app/Pages/gif_display_page.dart';
import 'package:flutter/material.dart';
import 'package:muscle_selector/muscle_selector.dart';
import 'package:first_app/Services/user_injury_info.dart';

class BodyPartsPage extends StatefulWidget {
  const BodyPartsPage({super.key});

  @override
  _BodyPartsPageState createState() => _BodyPartsPageState();
}

class _BodyPartsPageState extends State<BodyPartsPage> {
  Set<Muscle>? selectedMuscles;
  final GlobalKey<MusclePickerMapState> _mapKey = GlobalKey();
  int? painLevel;

final UserInjuryInformation _injuryInfo = UserInjuryInformation(); // Instance of the injury handler

  Widget _buildPainLevelSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPainLevelOption(Icons.sentiment_satisfied, "Low", Colors.green, 1),
          _buildPainLevelOption(Icons.sentiment_neutral, "Medium", Colors.orange, 2),
          _buildPainLevelOption(Icons.sentiment_dissatisfied, "High", Colors.red, 3),
        ],
      ),
    );
  }

  Widget _buildPainLevelOption(IconData icon, String label, Color color, int level) {
    return GestureDetector(
      onTap: () {
        setState(() {
          painLevel = level;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: painLevel == level ? color : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: painLevel == level ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveSelection() async {
    if (selectedMuscles != null && selectedMuscles!.isNotEmpty) {
      if (painLevel == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a pain level')));
      } else {
        String muscleName = selectedMuscles!.first.title.replaceAll(RegExp(r'\d+'), '');
        try {
          // Get the current user's UID from Firebase Auth
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            // Send injury info to Firestore
            await _injuryInfo.sendInjuryInfo(
              userId: user.uid,
              muscleName: muscleName,
              painLevel: painLevel!,
            );
            
        print('Selected muscle: $muscleName');
        print('Pain level: $painLevel');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GifDisplayPage(
              muscleName: muscleName,
              painLevel: painLevel!,
            ),
          ),
        );
      }
      else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not logged in. Please log in to proceed.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sending data: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a muscle first')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 0, 68, 255)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 0, 68, 255),Color.fromARGB(255, 114, 133, 255), Color.fromARGB(255, 165, 176, 247)],
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
                      "Select a Muscle",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: FitnessAppTheme.nearlyWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap on the body to select a muscle.",
                      style: TextStyle(fontSize: 16, color: FitnessAppTheme.nearlyWhite.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),

              // Figür Kartı
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: InteractiveViewer(
                      scaleEnabled: true,
                      panEnabled: true,
                      constrained: true,
                      child: MusclePickerMap(
                        key: _mapKey,
                        map: Maps.BODY,
                        isEditing: false,
                        onChanged: (muscles) {
                          setState(() {
                            selectedMuscles = muscles.isEmpty ? null : {muscles.first};
                          });
                        },
                        actAsToggle: true,
                        dotColor: Colors.grey,
                        selectedColor: FitnessAppTheme.nearlyBlue,
                        strokeColor: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              // Pain Level Seçici
              _buildPainLevelSelector(),

              // Onay Butonu
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: ElevatedButton(
                  onPressed: _approveSelection,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color.fromARGB(255, 57, 206, 114),
                    shadowColor: Colors.grey.withOpacity(0.3),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Approve",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:  Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
