import 'package:flutter/material.dart';
import 'package:app/consts/assets.dart' as consts;
import 'package:app/ui/commons/nav_bar/NavBar.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return NavBar(
      bodyContent: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Stack(
              children: [
                Container(
                  height: isSmallScreen ? 200 : 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(consts.img),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 16,
                  child: Text(
                    'How to Use the AI Teaching Assistant',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black54,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Help Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question 1
                  _buildQuestionAnswer(
                    'How do I ask a question?',
                    'Simply type your question in the chat box and press the send button. The AI assistant will respond with an answer.',
                  ),
                  const SizedBox(height: 24),

                  // Question 2
                  _buildQuestionAnswer(
                    'Can I upload images for analysis?',
                    'Yes, you can upload images by clicking the camera or gallery icon. The AI assistant will analyze the image and provide a response.',
                  ),
                  const SizedBox(height: 24),

                  // Question 3
                  _buildQuestionAnswer(
                    'What kind of questions can I ask?',
                    'You can ask any questions related to your studies, homework, or general knowledge. The AI assistant is designed to help with educational topics.',
                  ),
                  const SizedBox(height: 24),

                  // Navigation to Chat Page
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the Chat Page
                        Navigator.pushNamed(
                          context,
                          '/', // Use the named route
                        );
                      },
                      child: const Text('Start Chatting'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a question and answer
  Widget _buildQuestionAnswer(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF404A3D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}