import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models.dart';
import '../databasehelper.dart';
import '../AppConst.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;
  final int? userId;
  final Function() onNoteUpdated;

  const NoteDetailScreen(
      {super.key, this.note, this.userId, required this.onNoteUpdated});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  late quill.QuillController _contentController;

  List<Tag> _selectedTags = [];
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize all controllers
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _tagController = TextEditingController();

    // Initialize rich text editor
    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        final decodedContent = jsonDecode(widget.note!.content);
        _contentController = quill.QuillController(
          document: quill.Document.fromJson(decodedContent),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Handle legacy plain text content
        _contentController = quill.QuillController.basic();
        _contentController.document.insert(0, widget.note!.content);
      }
    } else {
      _contentController = quill.QuillController.basic();
    }

    // Load existing tags if editing a note
    if (widget.note != null) {
      _loadExistingTags();
    }
  }

  Future<void> _loadExistingTags() async {
    if (widget.note?.id != null) {
      final tags =
          await DatabaseHelper.instance.getTagsForNote(widget.note!.id!);
      setState(() {
        _selectedTags = tags;
      });
    }
  }

  Future<void> _insertImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Convert image to base64 for storage
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        final imageUrl =
            'data:image/${image.path.split('.').last};base64,$base64Image';

        // Insert image into editor
        final index = _contentController.selection.baseOffset;
        _contentController.document.insert(index, '\n');
        _contentController.document
            .insert(index + 1, quill.BlockEmbed.image(imageUrl));
        _contentController.document.insert(index + 2, '\n');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to insert image: $e')),
      );
    }
  }

  void _toggleCheckbox() {
    final index = _contentController.selection.baseOffset;
    if (index < 0) {
      // No selection in the editor.
      return;
    }

    final line = _contentController.document.queryChild(index);

    final currentLine = line.node;
    final currentStyle = currentLine?.style.attributes;

    if (currentStyle!.containsKey('list') &&
        currentStyle['list']?.value == 'checked') {
      // Remove checkbox style
      _contentController.formatText(
          index, 1, quill.Attribute.clone(quill.Attribute.list, null));
    } else {
      // Add checkbox style
      _contentController.formatText(index, 1, quill.Attribute.checked);
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final contentJson =
          jsonEncode(_contentController.document.toDelta().toJson());

      final note = Note(
        id: widget.note?.id,
        userId: widget.userId ?? widget.note!.userId,
        title: _titleController.text.trim(),
        content: contentJson,
        tags: _selectedTags,
        createdAt: widget.note?.createdAt,
      );

      final db = DatabaseHelper.instance;

      try {
        if (widget.note == null) {
          // For new notes
          final savedNote = await db.insertNote(note);
          // Add tags one by one
          for (var tag in _selectedTags) {
            await db.addTagToNote(savedNote.id!, tag.id!);
          }
        } else {
          // For existing notes
          await db.updateNote(note);
          // Clear existing tag relations
          await db.clearNoteTagsRelations(note.id!);
          // Add new tag relations
          for (var tag in _selectedTags) {
            await db.addTagToNote(note.id!, tag.id!);
          }
        }

        widget.onNoteUpdated();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addTag() async {
    if (_tagController.text.isEmpty) return;

    final tagName = _tagController.text.trim();

    // Check if tag already exists in selected tags
    if (_selectedTags
        .any((tag) => tag.name.toLowerCase() == tagName.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tag already added')),
      );
      return;
    }

    try {
      final tag = Tag(name: tagName);
      final savedTag = await DatabaseHelper.instance.insertTag(tag);

      setState(() {
        _selectedTags.add(savedTag);
        _tagController.clear();
      });
    } catch (e) {
      // Handle case where tag already exists in database
      final existingTags = await DatabaseHelper.instance.getAllTags();
      final existingTag = existingTags.firstWhere(
        (tag) => tag.name.toLowerCase() == tagName.toLowerCase(),
        orElse: () => Tag(name: tagName),
      );

      if (!_selectedTags.contains(existingTag)) {
        setState(() {
          _selectedTags.add(existingTag);
          _tagController.clear();
        });
      }
    }
  }

  void _removeTag(Tag tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Tags Input Section
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              labelText: 'Add Tag',
                              border: OutlineInputBorder(),
                              hintText: 'Enter a tag name',
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                        ),
                      ],
                    ),

                    if (_selectedTags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _selectedTags.map((tag) {
                            return Chip(
                              label: Text(tag.name),
                              onDeleted: () => _removeTag(tag),
                              deleteIcon: const Icon(Icons.close, size: 18),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // QuillToolbar
            quill.QuillToolbar.simple(
              controller: _contentController,
              configurations: quill.QuillSimpleToolbarConfigurations(
                showSearchButton: false,
                showHeaderStyle: false,
                showQuote: false,
                showCodeBlock: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: true,
                showListCheck: true,
                showIndent: true,
                toolbarSize: 20,
                customButtons: [
                  quill.QuillToolbarCustomButtonOptions(
                    onPressed: _insertImage,
                    icon: const Icon(Icons.image),
                  ),
                  quill.QuillToolbarCustomButtonOptions(
                    onPressed: _toggleCheckbox,
                    icon: const Icon(Icons.check_box_outlined),
                  ),
                ],
              ),
            ),

            // QuillEditor
            SizedBox(
              height: 400,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: quill.QuillEditor.basic(
                  controller: _contentController,
                  configurations: const quill.QuillEditorConfigurations(
                    checkBoxReadOnly: false,
                    readOnlyMouseCursor: MouseCursor.defer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
