import 'package:flutter/material.dart';

class RecentInjuries extends StatelessWidget {
  final String muscleName;
  final List<String> gifUrls;

  const RecentInjuries({
    Key? key,
    required this.muscleName,
    required this.gifUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(muscleName),
      ),
      body: gifUrls.isEmpty
          ? Center(child: Text('No GIFs available'))
          : ListView.builder(
              itemCount: gifUrls.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      Image.network(gifUrls[index]),
                      SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
