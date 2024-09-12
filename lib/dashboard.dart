import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_demo/Models/users.dart';
import 'package:flutter_demo/SqliteFunc/sqlite.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late DatabaseHelper handler;
  late Future<List<Users>> users;

  void initState() {
    handler = DatabaseHelper();
    users = handler.getUsers();

    handler.initDB().whenComplete(() {
      users = handler.getUsers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text("Dashboard")),
      body: SafeArea(
          child: FutureBuilder<List<Users>>(
              future: users,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Users>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Text("No data");
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  final userlist = snapshot.data ?? <Users>[];
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(userlist[index].username),
                      );
                    },
                  );
                }
              })),
    );
  }
}
