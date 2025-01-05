import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'dart:convert'; // Import for JSON handling
import 'package:app/ui/commons/nav_bar/NavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return NavBar(
      bodyContent: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Updated to support images
  late String apiUrl;
  File? _image; // To store the selected image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  String _selectedLang = '1';

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host') ?? "";
    setState(() {
      apiUrl = '$host';
    });
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Function to send a text-only message
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': text});
    });

    _textController.clear();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/question'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final botMessage = responseData['answer'];

        setState(() {
          _messages.add({'sender': 'bot', 'message': botMessage});
        });
      } else {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'message': 'Failed to fetch response. Please try again later.',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'message': 'Error connecting to the server. Please try again later.',
        });
      });
    }
  }

  // Function to send a message with an image
  void _sendMessageWithImage(String text) async {
    if (text.trim().isEmpty && _image == null) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': text,
        'image': _image,
      });
    });

    _textController.clear();

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/withimage'));

      // Add text field
      request.fields['question'] = text;

      // Add image file if selected
      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _image!.path,
          ),
        );
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final botMessage = jsonDecode(responseData)['answer'];

        setState(() {
          _messages.add({'sender': 'bot', 'message': botMessage});
        });
      } else {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'message': 'Failed to fetch response. Please try again later.',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'message': 'Error connecting to the server. Please try again later.',
        });
      });
    } finally {
      setState(() {
        _image = null; // Clear the selected image after sending
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: _selectedLang,
          onChanged: (String? newValue) {
            setState(() {
              _selectedLang = newValue!;
            });
          },
          items: const [
            DropdownMenuItem(value: '1', child: Text('English')),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUserMessage = message['sender'] == 'user';

              return Align(
                alignment: isUserMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: isUserMessage
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (message['message'] != null &&
                        message['message'].toString().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUserMessage ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                            color: isUserMessage ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    if (message['image'] != null)
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Image.file(
                          message['image'],
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_image != null) {
                    _sendMessageWithImage(_textController.text);
                  } else {
                    _sendMessage(_textController.text);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}