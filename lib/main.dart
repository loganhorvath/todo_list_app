import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.amber),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> todoList = [];
  String singlevalue = "";
  bool showReleaseMessage = false;
  bool showInputBox = false;
  double dragOffset = 0.0;
  final double dragThreshold = 100.0; // Threshold to show "Release" message

  // Importance levels
  final List<String> importanceLevels = [
    "lightwork",
    "kinda important",
    "mad important"
  ];

  String selectedImportance = "lightwork"; // Default importance level

  // Function to update the text and importance of a task
  void updateTask(int index, String updatedTask, String importance) {
    setState(() {
      todoList[index]['value'] = updatedTask;
      todoList[index]['importance'] = importance;
    });
  }

  // Function to add new task
  addList() {
    if (singlevalue.isNotEmpty) {
      setState(() {
        todoList.add({"value": singlevalue, "importance": selectedImportance});
        singlevalue = "";
        selectedImportance = "lightwork"; // Reset after adding
      });
    }
  }

  // Function to delete task
  deleteItem(index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  // Function to show dialog for adding or editing a task
  Future<void> _showTaskDialog({int? index}) async {
    String taskValue = index != null ? todoList[index]['value'] : "";
    String importance =
        index != null ? todoList[index]['importance'] : "lightwork";
    TextEditingController controller = TextEditingController(text: taskValue);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "Add New Task" : "Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: index == null ? 'Enter task...' : 'Edit task...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: importance,
                items: importanceLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  importance = value!;
                },
                decoration: InputDecoration(
                  labelText: "Select importance",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  if (index == null) {
                    setState(() {
                      todoList.add(
                          {"value": controller.text, "importance": importance});
                    });
                  } else {
                    updateTask(index, controller.text, importance);
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text(index == null ? "Add" : "Done"),
            ),
          ],
        );
      },
    );
  }




  // Handle the drag down gesture
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      dragOffset += details.primaryDelta!;
      if (dragOffset > dragThreshold) {
        showReleaseMessage = true;
      } else {
        showReleaseMessage = false;
      }
    });
  }

  // Handle the drag end gesture
  void _onVerticalDragEnd(DragEndDetails details) {
    if (showReleaseMessage) {
      setState(() {
        showInputBox = true;
        dragOffset = dragThreshold; // Max drag limit
      });
    } else {
      setState(() {
        dragOffset = 0.0;
        showInputBox = false;
      });
    }
  }







// build main header w/ drag functionality
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shiity Todo Application",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 75,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        elevation: 0,
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(0, dragOffset),
              child: Column(
                children: [
                  Expanded(
                    flex: 90,
                    child: ListView.builder(
                      itemCount: todoList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _showTaskDialog(index: index);
                          },
                          child: Dismissible(
                            key: Key(todoList[index]['value'].toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              deleteItem(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("hell yeah brother")),
                              );
                            },
                            background: Container(
                              color: Colors.green,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                            ),
                            // creates actual list item card
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white,
                              child: SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 80,
                                        child: Text(
                                          todoList[index]['value'].toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // adds the importance level to the right side of list item card
                                      Text(
                                        todoList[index]['importance'],
                                        style: TextStyle(
                                          color: todoList[index]
                                                      ['importance'] ==
                                                  "lightwork"
                                              ? Colors.green
                                              : todoList[index]['importance'] ==
                                                      "kinda important"
                                                  ? Colors.orange
                                                  : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // drag to add task
            if (dragOffset > 0 && dragOffset < dragThreshold)
              Positioned(
                top: dragOffset - 50,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    "Pull down to add task",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (dragOffset >= dragThreshold && !showInputBox)
              Positioned(
                top: dragOffset - 70,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    "Release!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // creates input box where you can write a new task
            if (showInputBox)
              Positioned(
                top: dragOffset - 100,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    onChanged: (value) {
                      singlevalue = value;
                    },
                    decoration: const InputDecoration(
                      labelText: "new task",
                    ),
                    onFieldSubmitted: (value) {
                      addList();
                      setState(() {
                        showInputBox = false;
                        dragOffset = 0.0;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
