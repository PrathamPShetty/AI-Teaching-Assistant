import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;
  File? _image; // To store the captured image
  final TextEditingController _textController = TextEditingController(); // For text input
  late String apiUrl; // Replace with your API URL

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeSharedPreferences();
  }
  Future<void> _initializeSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host') ?? "";
    setState(() {
      apiUrl = '$host';
    });
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0], // Use the first camera (back camera)
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  // Send message with image
  Future<void> _sendMessageWithImage(String text) async {
    if (text.trim().isEmpty && _image == null) return;

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

        // Show the bot's response in a dialog
        _showResponseDialog(botMessage);
      } else {
        _showResponseDialog('Failed to fetch response. Please try again later.');
      }
    } catch (e) {
      _showResponseDialog('Error connecting to the server. Please try again later.');
    } finally {
      setState(() {
        _image = null; // Clear the selected image after sending
      });
    }
  }

  // Capture an image
  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
        _image = File(image.path); // Store the captured image
      });

      // Show the captured image and input dialog
      _showInputDialog(image);
    } catch (e) {
      print('Error capturing image: $e');
    }
  }
  void _showInputDialog(XFile image) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 200, // Set a maximum height for the image
                  maxWidth: MediaQuery.of(context).size.width * 0.8, // Set a maximum width
                ),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover, // Ensure the image fits within the constraints
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _sendMessageWithImage(_textController.text); // Send message with image
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Send'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResponseDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ai Teaching Assiatant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!), // Display the camera preview
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _captureImage, // Capture an image
              child: const Text('Capture Image'),
            ),
          ),
        ],
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: CameraApp(),
  ));
}