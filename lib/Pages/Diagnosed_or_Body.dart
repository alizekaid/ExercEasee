import 'package:first_app/Pages/DiagnosedInjuriesPage.dart';
import 'package:first_app/Pages/body_parts.dart';
import 'package:first_app/Pages/fitness_app_theme.dart';
import 'package:flutter/material.dart';

// Dummy function to simulate fetching data
Future<bool> getData() async {
  await Future.delayed(Duration(seconds: 2)); // Simulate delay
  return true; // Simulate a successful data fetch
}

class SplitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,  // Background color matching the rest of the app
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,),
        body: FutureBuilder<bool>(
          future: getData(), // Call the getData function here
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(); // Show nothing if data is not loaded
            } else {
              return Stack(
                children: <Widget>[
                  // Main body content (split view)
                  Row(
                    children: [
                      // Left side with prescription PNG image
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            print("Diagnosed Injuries");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DiagnoseInjuries()),
                            );
                          },
                          child: Container(
                            color: Colors.blue.withOpacity(0.1), // Semi-transparent light blue
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/prescription.png', // Path to the prescription image
                                    width: 60,
                                    height: 60,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Diagnosed Injuries',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Right side with human body symbol
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            print("Body Part Exercises");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BodyPartsPage()),
                            );
                          },
                          child: Container(
                            color: Colors.green.withOpacity(0.1), // Semi-transparent light green
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.accessibility_new, // Human body symbol
                                    size: 60,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Body Part Exercises',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
