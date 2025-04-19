import 'package:flutter/material.dart';

class FirebaseRestAPI {
  Future<List<Map<String, dynamic>>> get() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        "Object_name": "Clouds",
        "Visual_characteristics":
        "Clouds: Fluffy sky pillows that drift along, silently mocking your earthbound existence.",
        "cultural_trendy_reference":
        "Nature's original social media status - constantly changing yet somehow always worth photographing."
      },
      {
        "Object_name": "Duct Tape",
        "Visual_characteristics":
        "Duct Tape: The sticky savior with a metallic sheen that silently whispers, 'Your repair skills are questionable at best.'",
        "cultural_trendy_reference":
        "The unofficial sponsor of every DIY project that started with 'How hard could it be?' and ended with tears."
      },
      {
        "Object_name": "Jorts",
        "Visual_characteristics":
        "Jorts: Denim shorts that boldly declare, 'I've made a conscious decision to expose my knees to the world.'",
        "cultural_trendy_reference":
        "The fashion statement that proves scissors and old jeans create both tragedy and comedy in equal measure."
      },
    ];
  }
}

class GptDatabase extends StatefulWidget {
  const GptDatabase({super.key});

  @override
  State<GptDatabase> createState() => _GptDatabaseState();
}

class _GptDatabaseState extends State<GptDatabase> {
  final FirebaseRestAPI db = FirebaseRestAPI();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Scanned Objects History")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load data."));
          }

          final scannedObjects = snapshot.data!;

          return ListView.builder(
            itemCount: scannedObjects.length,
            itemBuilder: (context, index) {
              final item = scannedObjects[index];
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            item['Object_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['Visual_characteristics'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['cultural_trendy_reference'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
