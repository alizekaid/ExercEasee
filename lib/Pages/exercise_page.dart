import 'package:flutter/material.dart';
import '../Services/api_service.dart';


class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final ApiService apiService = ApiService('https://your-api-url.com');
  String selectedBodyPart = 'shoulder';
  int selectedPainLevel = 1;
  List<Map<String, String>> gifData = [];

  void fetchGifs() async {
    final gifs = await apiService.fetchGifs(selectedBodyPart, selectedPainLevel);
    setState(() {
      gifData = gifs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise GIFs')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedBodyPart,
            items: ['shoulder', 'leg', 'back', 'arm']
                .map((part) => DropdownMenuItem(value: part, child: Text(part)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedBodyPart = value!;
              });
            },
          ),
          DropdownButton<int>(
            value: selectedPainLevel,
            items: [1, 2, 3, 4, 5]
                .map((level) => DropdownMenuItem(value: level, child: Text('Pain Level $level')))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedPainLevel = value!;
              });
            },
          ),
          ElevatedButton(
            onPressed: fetchGifs,
            child: const Text('Show Exercises'),
          ),
          Expanded(
            child: gifData.isNotEmpty ? buildGifGrid() : const Center(child: Text('No GIFs available')),
          ),
        ],
      ),
    );
  }

  Widget buildGifGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: gifData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(gifData[index]['name'] ?? 'Exercise', style: const TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: Image.network(gifData[index]['path'] ?? ''),
              ),
            ],
          ),
        );
      },
    );
  }
}
