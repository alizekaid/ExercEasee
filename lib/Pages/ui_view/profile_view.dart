import 'package:first_app/Pages/fitness_app_theme.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String titleTxt;
  final String userPhoto;
  final String displayName; // New field for the user's name
  final String email; // New field for the user's email
  final String? phoneNumber; // Add new property

  const ProfileView({
    super.key,
    this.animationController,
    this.animation,
    this.titleTxt = '',
    required this.userPhoto,
    required this.displayName, // Required parameter for displayName
    required this.email, // Required parameter for email
    this.phoneNumber, // Add optional phone number parameter
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                      topRight: Radius.circular(10.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(0.2),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    displayName, // Display the user's name
                                    style: const TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25,
                                      letterSpacing: -0.1,
                                      color: FitnessAppTheme.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email, // Display the user's email
                                    style: const TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                      letterSpacing: -0.1,
                                      color: Color.fromARGB(255, 40, 44, 47),
                                    ),
                                    maxLines: 1, // Ensure a single line
                                    overflow: TextOverflow.ellipsis, // Add ellipsis if it overflows
                                  ),
                                  if (phoneNumber != null && phoneNumber!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      phoneNumber!,
                                      style: const TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        letterSpacing: -0.1,
                                        color: Color.fromARGB(255, 40, 44, 47),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: FitnessAppTheme.white,
                            ),
                            child: userPhoto.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    userPhoto,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:(context, error, stackTrace) {
                                      return const Icon(
                                        Icons.account_circle,
                                        size: 60,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                )
                                : const Icon(
                                      Icons.account_circle,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24, right: 24, top: 8, bottom: 8),
                        child: Container(
                          height: 2,
                          decoration: const BoxDecoration(
                            color: FitnessAppTheme.background,
                            borderRadius:
                              BorderRadius.all(Radius.circular(4.0)),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
