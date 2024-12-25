import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Pages/gif_display_page.dart';
import 'package:first_app/Pages/recent_injury_gifs.dart';
import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AreaListView extends StatefulWidget {
  const AreaListView(
      {super.key, this.mainScreenAnimationController, this.mainScreenAnimation});

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  @override
  _AreaListViewState createState() => _AreaListViewState();
}

class _AreaListViewState extends State<AreaListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<String> areaListData = <String>[
    'assets/images/shoulder1.png',
    'assets/images/arm.png',
    'assets/images/chest.png',
    'assets/images/back1.png',
  ];

  // Map to store body part and its associated injury data
  Map<String, Map<String, dynamic>> injuryData = {};

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    fetchInjuryData(); // Fetch injury data on initialization
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

Future<List<String>> fetchGifUrlsFromDatabase(String muscleName) async {
  try {
    // Get the current user
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid ?? '';

    if (userId.isEmpty) {
      print('Error: User ID is not available.');
      return [];
    }

    // Access the Injuries collection for the current user
    final injuriesCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Injuries');

    // Fetch the document for the specific body part (muscleName)
    final injuryDoc = await injuriesCollection.doc(muscleName).get();

    if (injuryDoc.exists) {
      final data = injuryDoc.data() as Map<String, dynamic>;
      // Return the list of gifUrls stored in the document
      return List<String>.from(data['gifUrls'] ?? []);
    } else {
      print('No data found for muscle: $muscleName');
      return [];
    }
  } catch (e) {
    print('Error fetching GIF URLs: $e');
    return [];
  }
}


void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


Future<void> fetchInjuryData() async {
  try {
    // Replace this with actual logic to fetch the current user's ID.
    final currentUser = FirebaseAuth.instance.currentUser; // Example with Firebase Auth
    final userId = currentUser?.uid ?? ''; // Ensure a valid user ID is present

    if (userId.isEmpty) {
      print('Error: User ID is not available.');
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      // Now, retrieve the Injuries subcollection for the current user
      final injuriesCollection = userDoc.reference.collection('Injuries');
      
      // We assume the body parts in the Injuries collection are stored as documents with names
      // like 'shoulder', 'arm', 'chest', 'back', etc.
      final shoulderDoc = await injuriesCollection.doc('shoulder').get();
      final armDoc = await injuriesCollection.doc('arm').get();
      final chestDoc = await injuriesCollection.doc('chest').get();
      final backDoc = await injuriesCollection.doc('back').get();

      // Now, create a map with the injury data for each body part
      setState(() {
        injuryData = {
          'shoulder': _getInjuryData(shoulderDoc),
          'arm': _getInjuryData(armDoc),
          'chest': _getInjuryData(chestDoc),
          'back': _getInjuryData(backDoc),
        };
      });
    }
  } catch (e) {
    print('Error fetching injury data: $e');
  }
}

// Helper function to extract injury data (including muscleName and painLevel)
Map<String, dynamic> _getInjuryData(DocumentSnapshot doc) {
  if (doc.exists) {
    final data = doc.data() as Map<String, dynamic>;
    final muscleName = data['muscleName'] ?? 'Unknown';
    final painLevel = data['painLevel'] ?? 0;
    return {
      'muscleName': muscleName,
      'painLevel': painLevel,
    };
  } else {
    return {};
  }
}

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: GridView(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24.0,
                    crossAxisSpacing: 35.0,
                    childAspectRatio: 0.5,//görsellerin bulunduğu kutunun boyutunu buradan değiştirdim
                  ),
                  children: List<Widget>.generate(
                    areaListData.length,
                    (int index) {
                      final int count = areaListData.length;
                      final Animation<double> animation =
                          Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animationController!,
                          curve: Interval((1 / count) * index, 1.0,
                              curve: Curves.fastOutSlowIn),
                        ),
                      );
                      animationController?.forward();

                      // Determine body part name
                      final bodyParts = ['shoulder', 'arm', 'chest', 'back'];
                      final bodyPart = bodyParts[index];

                      return AreaView(
                        imagepath: areaListData[index],
                        animation: animation,
                        animationController: animationController!,
                        onTap: () async {
                          try {
                            // Retrieve injury details for this body part
                            final injury = injuryData[bodyPart] ?? {};
                            final muscleName = injury['muscleName'] ?? bodyPart;

                            // Fetch GIF URLs from the database
                            final gifUrls = await fetchGifUrlsFromDatabase(muscleName);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecentInjuries(
                                  muscleName: muscleName,
                                  gifUrls: gifUrls,
                                ),
                              ),
                            );
                          } catch (e) {
                            _showErrorDialog(context, 'Error loading GIFs: $e');
                          }
                        },                        
                      );
                    },
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

class AreaView extends StatelessWidget {
  const AreaView({
    super.key,
    this.imagepath,
    this.animationController,
    this.animation,
    required this.onTap,
  });

  final String? imagepath;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: FitnessAppTheme.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(8.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.4),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  splashColor: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.2),
                  onTap: onTap,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            imagepath!,
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ],
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