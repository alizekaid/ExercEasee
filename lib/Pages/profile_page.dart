import 'package:first_app/Pages/ui_view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/Pages/LoginPage.dart';
import 'package:first_app/Pages/fitness_app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.animationController});
  final AnimationController? animationController;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  String? userName;
  String phoneNumber = "";
  String email = "";
  String age = "";
  String displayName = "";
  String? userPhoto;

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

    fetchUserData().then((_) {
    addAllListData();
    setState(() {}); // Trigger a rebuild
  });
  
    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 && scrollController.offset >= 0) {
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
    
  }

  void addAllListData() {
    const int count = 9;
    
    // Clear existing items first
    listViews.clear();

    listViews.add(
      ProfileView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: const Interval((1 / count) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
        displayName: displayName,
        email: email,
        userPhoto: userPhoto ?? '',
      ),
    );

    listViews.add(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileButton(
              title: "Edit Profile",
              icon: Icons.edit,
              color: Colors.green,
              onTap: () => _editProfile(context),
            ),
            const SizedBox(height: 16),
            _buildProfileButton(
              title: "Settings",
              icon: Icons.settings,
              color: Colors.blue,
              onTap: settings,
            ),
            const SizedBox(height: 16),
            _buildProfileButton(
              title: "Sign Out",
              icon: Icons.logout,
              color: Colors.red,
              onTap: signOut,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool isGoogleUser = user.providerData
            .any((provider) => provider.providerId == 'google.com');

        if (isGoogleUser) {
          setState(() {
            displayName = user.displayName!;
            //print(displayName);
            email = user.email!;
            userPhoto = user.photoURL!;
          });
        } else {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get();
          if (userDoc.exists) {
            setState(() {
              displayName = userDoc['name_surname'];
              email = userDoc['email'];
              age = userDoc['age'].toString();
              phoneNumber = userDoc['phone_number'];
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> signOut() async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Cancel denilirse diyalog kapanıyor
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // Çıkış yapılmadan önce diyalog kapatılıyor
            try {
              await auth.signOut(); // user Signoutlanıyor
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            } catch (e) {
              print("Error signing out: $e");
            }
          },
          child: const Text("Log out"),
        ),
      ],
    ),
  );
}

  Future<void> settings()async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Under Constructions"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(
      {required String title,
      required IconData icon,
      Color color = Colors.blue,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: displayName);
    TextEditingController phoneNumberController = TextEditingController(text: phoneNumber);
  
    // ---------------------------------------- THIS PART OF THE CODE IS SPECIALIZED FOR IMAGE UPDATION AMA FIREBASE STORAGE YOK --------------------------------------
/*
    // Function to pick an image from the gallery
    Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        // Upload image to Firebase Storage
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child(user.uid);
          await storageRef.putFile(File(pickedFile.path));
          String downloadUrl = await storageRef.getDownloadURL();
          // Update Firestore with the new profile picture URL
          await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
            'profile_picture': downloadUrl,
          }, SetOptions(merge: true));
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated successfully")),
          );
        }
      } catch (e) {
        print("Error uploading profile picture: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload profile picture")),
        );
      }
    }
  }
  */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --------------------------------- FOR IMAGE UPDATION --------------------------------
          /* 
            // Display current profile picture
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(userPhoto?? ""),
            child: Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _pickImage,
              ),
            ),
          ),
          */
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Enter your name",
              ),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                hintText: "Enter your phone number",
              ),
            ),
            const SizedBox(height: 20),  // Add some space before the button
          ElevatedButton(
            onPressed: () async {
              try {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Send password reset email to current user's email
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset email sent")),
                  );
                  // Navigate to the login screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
              } catch (e) {
                print("Error sending password reset email: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to send password reset email")),
                );
              }
            },
            child: const Text("Reset Password"),
          ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  bool isGoogleUser = user.providerData
                      .any((provider) => provider.providerId == 'google.com');

                  // Update Firebase Auth display name for all users
                  await user.updateDisplayName(nameController.text);

                  // Update Firestore for all users (both Google and regular)
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(user.uid)
                      .set({
                    'name_surname': nameController.text,
                    'email': user.email,
                    // Add any other fields you want to persist
                    'isGoogleUser': isGoogleUser,
                    'phone_number': phoneNumberController.text,
                  }, SetOptions(merge: true));
                  
                  // Update state and UI
                  setState(() {
                    displayName = nameController.text;
                    phoneNumber = phoneNumberController.text;
                  });
                  addAllListData();
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated successfully")),
                  );
                }
              } catch (e) {
                print("Error updating profile: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to update profile")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
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
                                  'Profile',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 25 + 3 - 3 * topBarOpacity,
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