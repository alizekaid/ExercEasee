import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Pages/fitness_app_theme.dart';
import 'package:first_app/Pages/ui_view/notification_view.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, this.animationController});

  final AnimationController? animationController;
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

String message="";

FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


@override
void initState() {
  super.initState();
  
  topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: widget.animationController!,
      curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
    ),
  );

  // Initialize topBarOpacity
  topBarOpacity = 0.0;

  // Add scroll listener for opacity changes
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

  // Start the animation
  widget.animationController?.forward();
  
  fetchNotificationsForCurrentUser();
}

@override
void dispose() {
  scrollController.dispose();
  super.dispose();
}

Future<void> fetchNotificationsForCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('No user is logged in.');
        return;
      }

      final userId = currentUser.uid;

      // Fetch data from Firestore for the logged-in user
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('notifications')
          .get();

      // Map data to listViews
      final List<Widget> notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationView(
          title: data['title'] ?? 'No Title',
          message: data['message'] ?? 'No Message',
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: widget.animationController!,
              curve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
            ),
          ),
          animationController: widget.animationController!,
        );
      }).toList();

      setState(() {
        listViews = notifications;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
    }
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
            getAppBarUI(),
            Padding(
              padding: EdgeInsets.only(
                top: AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top + 24,
              ),
              child: listViews.isEmpty
                  ? const Center(
                      child: Text(
                        'No notifications available',
                        style: TextStyle(
                          fontSize: 16,
                          color: FitnessAppTheme.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: listViews.length,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + MediaQuery.of(context).size.height * 0.12, // Add padding here
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        widget.animationController?.forward();
                        return listViews[index];
                      },
                    ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
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
                              .withOpacity(0.4 *topBarOpacity),
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
                                  'Notifications',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
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
}