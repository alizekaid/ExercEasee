import 'package:first_app/main.dart';
import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Pages/recent_injury_gifs.dart';

class WorkoutView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const WorkoutView({
    Key? key,
    this.animationController,
    this.animation,
  }) : super(key: key);

  Stream<String> getLastSelectedBodyPartStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Injuries')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final data = snapshot.docs.first.data();
              //print('Latest document data: $data');
              //print('Timestamp: ${data['timestamp']}');
              String muscleName = data['muscleName'] ?? 'No';
              //return muscleName[0].toUpperCase() + muscleName.substring(1);
              return muscleName;
            }
            return 'No';
          });
    }
    return Stream.value('No');
  }

  Future<List<String>> fetchGifUrls(String muscleName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Injuries')
          .doc(muscleName)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['gifUrls'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching GIF URLs: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.06,
                vertical: screenSize.height * 0.02,
              ),
              child: InkWell(
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final snapshot = await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .collection('Injuries')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .get();

                    if (snapshot.docs.isNotEmpty) {
                      final muscleName = snapshot.docs.first.id;
                      final gifUrls = await fetchGifUrls(muscleName);
                      
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecentInjuries(
                              muscleName: muscleName,
                              gifUrls: gifUrls,
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FitnessAppTheme.nearlyDarkBlue,
                        HexColor("#6F56E8")
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(screenSize.width * 0.02),
                      bottomLeft: Radius.circular(screenSize.width * 0.02),
                      bottomRight: Radius.circular(screenSize.width * 0.02),
                      topRight: Radius.circular(screenSize.width * 0.12),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(0.6),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.width * 0.04),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Last exercise',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.normal,
                            fontSize: screenSize.width * 0.035,
                            letterSpacing: 0.0,
                            color: FitnessAppTheme.white,
                          ),
                        ),
                        StreamBuilder<String>(
                          stream: getLastSelectedBodyPartStream(),
                          builder: (context, snapshot) {
                            final bodyPart = snapshot.data ?? 'No';
                            return Padding(
                              padding: EdgeInsets.only(top: screenSize.height * 0.01),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Continue $bodyPart exercise',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.normal,
                                        fontSize: screenSize.width * 0.05,
                                        letterSpacing: 0.0,
                                        color: FitnessAppTheme.white,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: FitnessAppTheme.white,
                                    size: screenSize.width * 0.06,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
