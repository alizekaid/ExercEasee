import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Pages/calendar_popup_view.dart';
import 'package:first_app/Pages/fitness_app_theme.dart';
import 'package:first_app/Pages/my_diary/meals_list_view.dart';
import 'package:first_app/Pages/ui_view/body_measurement.dart';
import 'package:first_app/Pages/ui_view/glass_view.dart';
import 'package:first_app/Pages/ui_view/mediterranean_diet_view.dart';
import 'package:first_app/Pages/ui_view/title_view.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({super.key, this.animationController});

  final AnimationController? animationController;
  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  String? userName;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 5));
  

// Fetch user name from Firestore
  Future<void> fetchUserName() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if the user signed in with Google
      bool isGoogleUser = user.providerData
          .any((provider) => provider.providerId == 'google.com');

      if (isGoogleUser) {
        setState(() {
          userName = user.displayName; // Use Google account name
        });
      } else {
        // Fetch from Firestore for standard login
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name_surname'];
          });
        } else {
          print("User document does not exist.");
        }
      }
    } else {
      print("User is not logged in.");
    }
  } catch (e) {
    print("Error fetching user name: $e");
  }
}


Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      print("Google sign-in aborted.");
      return null; // User aborted sign-in
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;
  } catch (e) {
    print("Error during Google sign-in: $e");
    return null;
  }
}


@override
void initState() {
  super.initState();
  topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: widget.animationController!,
      curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
    ),
  );
  addAllListData();
  scrollController.addListener(() {
    if (scrollController.offset >= 24) {
      if (topBarOpacity != 1.0) {
        setState(() {
          topBarOpacity = 1.0;
        });
      }
    } else if (scrollController.offset <= 24 &&
        scrollController.offset >= 0) {
      if (topBarOpacity != scrollController.offset / 24) {
        setState(() {
          topBarOpacity = scrollController.offset / 24;
        });
      }
    } else if (scrollController.offset <= 0) {
      if (topBarOpacity != 0.0) {
        setState(() {
          topBarOpacity = 0.0;
        });
      }
    }
  });

  // Call fetchUserName asynchronously
  fetchUserName();
}


  void addAllListData() {
    const int count = 9;

    listViews.add(
      TitleView(
        titleTxt: 'Progress',
        //subTxt: 'Details',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                const Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      MediterranesnDietView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                const Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      TitleView(
        titleTxt: 'Streching Guide',
        //subTxt: 'More',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                const Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      MealsListView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: const Interval((1 / count) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController,
      ),
    );

    listViews.add(
      TitleView(
        titleTxt: 'Extras',
        //subTxt: 'Today',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                const Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
  
    listViews.add(
      BodyMeasurementView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                const Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    
    listViews.add(
      GlassView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: const Interval((1 / count) * 8, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Welcome $userName',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18 + 3 - 3 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            /*SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(32.0)),
                                onTap: () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  // setState(() {
                                  //   isDatePopupOpen = true;
                                  // });
                                  showDemoDialog(context: context);
                                },
                              ),
                            ),*/
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    height: 38,
                                    width: 38,
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0)),
                                      onTap: () {
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        // setState(() {
                                        //   isDatePopupOpen = true;
                                        // });
                                        showDemoDialog(context: context);
                                      },
                                      child: const Center(
                                        child: Icon(
                                          Icons.calendar_today,
                                          color: FitnessAppTheme.grey,
                                          size:18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat("dd, MMM").format(startDate)} - ${DateFormat("dd, MMM").format(endDate)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w100,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
void showDemoDialog({BuildContext? context}) {
    showDialog<dynamic>(
      context: context!,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        minimumDate: DateTime.now(),
        //  maximumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
        initialEndDate: endDate,
        initialStartDate: startDate,
        onApplyClick: (DateTime startData, DateTime endData) {
          setState(() {
            startDate = startData;
            endDate = endData;
          });
        },
        onCancelClick: () {},
      ),
    );
  }
}

