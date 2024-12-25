import 'package:flutter/material.dart';

import 'fitness_app_theme.dart';

class DiagnoseInjuries extends StatelessWidget {
  final List<String> injuries = [
    'Cervical Herniated Disc',
    'Neck Stiffness',
    'Shoulder Tear',
    'Shoulder Impingement',
    "Tennis Elbow (Lateral Epicondylitis)",
    "Golfer's Elbow (Medial Epicondylitis)",
    'Carpal Tunnel Syndrome',
    'Extensor Tendon Injury',
    'Weakness in Muscles Around the Scapula',
    'Scoliosis',
    'Lumbar Herniated Disc',
    'Sacroiliac Joint Degeneration',
    'Osteoarthritis of The Hip',
    'Meniscus Tear In the Knee',
    'Anterior Cruciate Ligament (ACL) Injury',
    'Ligament Injuries',
    'Ankle Sprain',
    'Heel Spur',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: injuries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: FitnessAppTheme.white, backgroundColor: FitnessAppTheme.nearlyBlue.withOpacity(0.8), // Button text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          onPressed: () {
                            print('CLICKED ON ${injuries[index]}');
                          },
                          child: Text(
                            injuries[index],
                            style: (FitnessAppTheme.textTheme.bodyLarge ??
                                    const TextStyle(fontSize: 16, color: Colors.white))
                                .copyWith(color: FitnessAppTheme.white),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    // Simulate data fetching delay
    await Future.delayed(const Duration(seconds: 2));
    return true; // Simulate successful data fetching
  }
}
