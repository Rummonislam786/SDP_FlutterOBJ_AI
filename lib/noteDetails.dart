import 'package:flutter/material.dart';
import '../models.dart';
import '../databasehelper.dart';
import '../AppConst.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;
  final int? userId;
  final Function() onNoteUpdated;

  const NoteDetailScreen(
      {super.key, this.note, this.userId, required this.onNoteUpdated});

  @override
  // ignore: library_private_types_in_public_api
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _selectedCategory =
        widget.note?.category ?? AppConstants.noteCategories.first;
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final note = Note(
          id: widget.note?.id,
          userId: widget.userId ?? widget.note!.userId,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          createdAt: widget.note?.createdAt);

      if (widget.note == null) {
        // New note
        await DatabaseHelper.instance.insertNote(note);
      } else {
        // Update existing note
        await DatabaseHelper.instance.updateNote(note);
      }

      // Trigger notes list refresh
      widget.onNoteUpdated();

      // Close the screen
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title Input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppConstants.noteCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Content Input
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Note Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter note content';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Save Button
              ElevatedButton(
                onPressed: _saveNote,
                child:
                    Text(widget.note == null ? 'Create Note' : 'Update Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
