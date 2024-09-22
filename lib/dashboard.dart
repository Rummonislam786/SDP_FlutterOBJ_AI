import 'package:Attendance_System/FaceDetectionScreen.dart';
import 'package:Attendance_System/about.dart';
import 'package:flutter/material.dart';
import 'package:Attendance_System/Models/users.dart';
import 'package:Attendance_System/SqliteFunc/sqlite.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late DatabaseHelper handler;
  late Future<List<Users>> users;

  var menuItems = [
    // {"title": "Main", "icon": Icons.psychology, "color": Colors.blue},
    // {"title": "Users", "icon": Icons.person, "color": Colors.green},
    // {"title": "Configuration", "icon": Icons.settings, "color": Colors.orange},
    // {"title": "About", "icon": Icons.info, "color": Colors.purple},

    // GridView.builder(
    //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //           crossAxisCount: 2,
    //           crossAxisSpacing: 16.0,
    //           mainAxisSpacing: 16.0,
    //           childAspectRatio: 1.1,
    //         ),
    //         itemCount: menuItems.length,
    //         itemBuilder: (context, index) {
    //           return _buildMenuItem(menuItems[index]);
    //         },
  ];

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    users = handler.getUsers();

    handler.initDB().whenComplete(() {
      setState(() {
        users = handler.getUsers();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151345),
      appBar: AppBar(
        title: const Text("Dashboard"),
        elevation: 0,
        backgroundColor: const Color(0xff2D2E2F),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
              crossAxisSpacing: 1,
              mainAxisSpacing: 2,
              crossAxisCount: 2,
              children: [
                InkWell(
                  child: _buildMenuItem({
                    "title": "Detect Emotion",
                    "icon": Icons.camera,
                    "color": Colors.blue
                  }),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FaceDetectionScreen()));
                  },
                ),
                InkWell(
                  child: _buildMenuItem({
                    "title": "Users",
                    "icon": Icons.person,
                    "color": Colors.green
                  }),
                  onTap: () {},
                ),
                InkWell(
                  child: _buildMenuItem({
                    "title": "Configuration",
                    "icon": Icons.settings,
                    "color": Colors.orange
                  }),
                  onTap: () {},
                ),
                InkWell(
                  child: _buildMenuItem({
                    "title": "About",
                    "icon": Icons.info,
                    "color": Colors.purple
                  }),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutScreen()));
                  },
                ),
              ]),
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [item['color'], item['color'].withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item['icon'],
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              item['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
