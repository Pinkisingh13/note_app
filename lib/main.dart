import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController workNameController = TextEditingController();

  final list = [];

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    List<String> notes = await ReadAndWrite.readFile();
    setState(() {
      list.addAll(notes);
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom +
                20, // Adjust for keyboard
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents overflowing the screen
            children: [
              TextField(
                controller: workNameController,
                decoration: const InputDecoration(
                  hintText: "Write your work",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String workName = workNameController.text;
                  if (workName.isNotEmpty) {
                    await ReadAndWrite.writeFile(workName);
                    workNameController.clear();

                    setState(() {
                      list.add(workName); // Add directly to the list
                    });

                    Navigator.pop(context); // Close the bottom sheet
                  } else {
                    print("Work name cannot be empty!");
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }

  final colors = [
    const Color.fromARGB(255, 255, 213, 227),
    const Color.fromARGB(255, 255, 242, 196),
    const Color.fromARGB(255, 221, 240, 255),
    Color(0xFF91F48F),
    Color(0xFFFF9E9E),
    Color(0xFF9EFFFF),
    Color(0xFFB69CFF),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 216, 216, 216),
        title: Text(
          "Notes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            list.isEmpty
                ? Text("Please Start Adding Your Work!!")
                : Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: colors[math.Random().nextInt(colors.length)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    list[index],
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    String noteToDelete = list[index];
                                    await ReadAndWrite.deleteNote(noteToDelete);
                                    setState(() {
                                      list.removeAt(index);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ))
                            ],
                          ),
                        );
                      },
                    ),
                  )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet();
        },
        backgroundColor: Color(0xFF252525),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ReadAndWrite {
  static Future<File> getlocalPathAndFile() async {
    final getDocumentPath = await getApplicationDocumentsDirectory();
    final path = getDocumentPath.path;
    return File("$path/myNotes.txt");
  }

  static writeFile(String value) async {
    File file = await getlocalPathAndFile();
    await file.writeAsString('$value\n', mode: FileMode.append);
  }
 
  static Future<List<String>> readFile() async {
    try {
      final file = await getlocalPathAndFile();

      final String content = await file.readAsString();
      return content.split('\n').where((line) => line.isNotEmpty).toList();
    } catch (e) {
      // print(e);
      return [];
    }
  }

  static Future<void> deleteNote(String noteToDelete) async {
    List<String> notes = await readFile();
    notes.remove(noteToDelete);
    final file = await getlocalPathAndFile();
    await file.writeAsString(notes.join('\n'));
  }
}
