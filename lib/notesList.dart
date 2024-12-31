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
  List<Tag> _allTags = [];
  List<Tag> _selectedTags = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadNotesAndTags();
  }

  Future<void> _loadNotesAndTags() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      // Load all available tags
      final tags = await DatabaseHelper.instance.getAllTags();

      // Load notes based on selected tags
      final notes = _selectedTags.isEmpty
          ? await DatabaseHelper.instance
              .getNotesByUser(authProvider.currentUser!.id!)
          : await DatabaseHelper.instance.getNotesByTags(
              authProvider.currentUser!.id!,
              _selectedTags.map((t) => t.name).toList(),
            );

      setState(() {
        _allTags = tags;
        _notes = notes;
      });
    }
  }

  void _toggleTag(Tag tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
    _loadNotesAndTags();
  }

  Widget _buildTagsFilter() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.local_offer),
                const SizedBox(width: 8),
                const Text(
                  'Filter by Tags',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_selectedTags.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTags.clear();
                      });
                      _loadNotesAndTags();
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),
          if (_allTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                children: _allTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(tag.name),
                    onSelected: (_) => _toggleTag(tag),
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                    checkmarkColor: Theme.of(context).primaryColor,
                  );
                }).toList(),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No tags available'),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _isSearching = false;
                    });
                    _loadNotesAndTags();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
            _notes = _notes
                .where((note) =>
                    note.title.toLowerCase().contains(value.toLowerCase()) ||
                    note.content.toLowerCase().contains(value.toLowerCase()))
                .toList();
          });
        },
      ),
    );
  }

  Widget _buildNotesList() {
    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _selectedTags.isEmpty
                  ? 'No notes found'
                  : 'No notes found with selected tags',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(
              note.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  note.createdAt.toLocal().toString().split('.')[0],
                  style: const TextStyle(fontSize: 12),
                ),
                if (note.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: note.tags.map((tag) {
                      return Chip(
                        label: Text(
                          tag.name,
                          style: const TextStyle(fontSize: 10),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteDetailScreen(
                    note: note,
                    onNoteUpdated: _loadNotesAndTags,
                  ),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Note'),
                    content: const Text(
                        'Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await DatabaseHelper.instance.deleteNote(note.id!);
                  _loadNotesAndTags();
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _deleteNote(Note note) async {
    await DatabaseHelper.instance.deleteNote(note.id!);
    _loadNotesAndTags();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          _buildSearchBar(),
          _buildTagsFilter(),
          Expanded(child: _buildNotesList()),
          // Notes List
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => NoteDetailScreen(
                    onNoteUpdated: _loadNotesAndTags,
                    userId: authProvider.currentUser!.id!,
                  )));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
