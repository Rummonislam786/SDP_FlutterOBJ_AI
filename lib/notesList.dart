import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models.dart';
import '../auth.dart';
import '../databasehelper.dart';
import '../AppConst.dart';
import '../login.dart';
import '../notedetails.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _notes = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final notes = await DatabaseHelper.instance.getNotesByUser(
          authProvider.currentUser!.id!,
          category: _selectedCategory);
      setState(() {
        _notes = notes;
      });
    }
  }

  void _deleteNote(Note note) async {
    await DatabaseHelper.instance.deleteNote(note.id!);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Category Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: const Text('Filter by Category'),
              value: _selectedCategory,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...AppConstants.noteCategories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        )),
              ],
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                _loadNotes();
              },
            ),
          ),

          // Notes List
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text('No notes found'))
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return ListTile(
                        title: Text(note.title),
                        subtitle: Text(
                          '${note.category} - ${note.createdAt.toLocal()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => NoteDetailScreen(
                                  note: note, onNoteUpdated: _loadNotes)));
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(note),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => NoteDetailScreen(
                    onNoteUpdated: _loadNotes,
                    userId: authProvider.currentUser!.id!,
                  )));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
