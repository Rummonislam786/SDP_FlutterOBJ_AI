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
  late quill.QuillController _contentController;
  late String _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _selectedCategory =
        widget.note?.category ?? AppConstants.noteCategories.first;

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
          category: _selectedCategory,
          createdAt: widget.note?.createdAt);

      if (widget.note == null) {
        await DatabaseHelper.instance.insertNote(note);
      } else {
        await DatabaseHelper.instance.updateNote(note);
      }

      widget.onNoteUpdated();
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
      resizeToAvoidBottomInset: true,
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
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
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
                  ],
                ),
              ),
            ),
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
                    ])),
            SizedBox(
              height: 400,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: quill.QuillEditor.basic(
                  controller: _contentController,
                  configurations: const quill.QuillEditorConfigurations(
                      checkBoxReadOnly: false,
                      readOnlyMouseCursor: MouseCursor.defer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
