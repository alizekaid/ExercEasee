import 'package:flutter/material.dart';
import 'fitness_app_theme.dart';
import 'gif_display_page.dart';

class DiagnoseInjuries extends StatelessWidget {
  final List<String> injuries = [
    'Cervical Herniated Disc',
    'Neck Stiffness',
    'Shoulder Impingement',
    "Tennis Elbow",
    "Golfer's Elbow",
    'Carpal Tunnel Syndrome',
    'Extensor Tendon Injury',
    'Weakness in Muscles Around the Scapula',
    'Scoliosis',
    'Lumbar Herniated Disc',
    'Sacroiliac Joint Degeneration',
    'Osteoarthritis of The Hip',
    'Meniscus Tear In the Knee',
    'Anterior Cruciate Ligament Injury',
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("Diagnosed Injuries"),
        ),
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
                            String formattedName = injuries[index].replaceAll(' ', '_');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GifDisplayPage(
                                  muscleName: formattedName,
                                  painLevel: 0,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            injuries[index],
                            style: (FitnessAppTheme.textTheme.bodyLarge ??
                                    const TextStyle(
                                        fontSize: 16, color: Colors.white))
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
    await Future.delayed(const Duration(seconds: 2));
    return true; 
  }
}
