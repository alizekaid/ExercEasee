import 'package:firebase_auth/firebase_auth.dart';
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
  
  // Map to store body part images and their data
  Map<String, Map<String, dynamic>> bodyPartsData = {};

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    fetchBodyPartsData();
  }

  Future<void> fetchBodyPartsData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final injuriesCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Injuries');

      final QuerySnapshot injuries = await injuriesCollection.get();

      Map<String, Map<String, dynamic>> tempData = {};

      // Map of body parts to their image paths
      final Map<String, String> bodyPartImages = {
        'shoulder': 'assets/images/shoulder1.png',
        'forearm': 'assets/images/forearm.png',
        'chest': 'assets/images/chest.png',
        'trapezius': 'assets/images/trapezius.png',
        'abs': 'assets/images/abs.png',
        'quads': 'assets/images/quads.png',
        'harmstrings': 'assets/images/harmstrings.png',
        'calves': 'assets/images/calves.png',
        'biceps': 'assets/images/biceps.png',
        'triceps': 'assets/images/triceps.png',
        'glutes': 'assets/images/glutes.png',
        'adductors': 'assets/images/adductors.png',
        'lats': 'assets/images/lats.png',
        'lower_back': 'assets/images/lower_back.png',
        'neck': 'assets/images/neck.png',
        'obliques': 'assets/images/obliques.png',
      };

      for (var doc in injuries.docs) {
        final String bodyPart = doc.id.toLowerCase();
        if (bodyPartImages.containsKey(bodyPart)) {
          tempData[bodyPart] = {
            'imagePath': bodyPartImages[bodyPart]!,
            'data': doc.data() as Map<String, dynamic>,
          };
        }
      }

      setState(() {
        bodyPartsData = tempData;
      });

    } catch (e) {
      print('Error fetching body parts data: $e');
    }
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
                child: bodyPartsData.isEmpty
                    ? const Center(
                        child: Text(
                          'No injuries recorded yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: FitnessAppTheme.grey,
                          ),
                        ),
                      )
                    : GridView(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 16),
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 24.0,
                          crossAxisSpacing: 35.0,
                          childAspectRatio: 0.5,
                        ),
                        children: bodyPartsData.entries.map((entry) {
                          final int index = bodyPartsData.keys.toList().indexOf(entry.key);
                          final Animation<double> animation =
                              Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animationController!,
                              curve: Interval((1 / bodyPartsData.length) * index, 1.0,
                                  curve: Curves.fastOutSlowIn),
                            ),
                          );
                          animationController?.forward();

                          return AreaView(
                            imagepath: entry.value['imagePath'],
                            animation: animation,
                            animationController: animationController!,
                            onTap: () async {
                              try {
                                final gifUrls = await fetchGifUrlsFromDatabase(entry.key);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecentInjuries(
                                      muscleName: entry.key,
                                      gifUrls: gifUrls,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                _showErrorDialog(context, 'Error loading GIFs: $e');
                              }
                            },
                          );
                        }).toList(),
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