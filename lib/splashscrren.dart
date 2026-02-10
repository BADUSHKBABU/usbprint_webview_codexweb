import 'package:flutter/material.dart';
import 'package:untitled/webviewpage.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  TextEditingController text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter URL'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: text,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Validate that URL is not empty
                if (text.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a URL')),
                  );
                  return;
                }

                // Pass the URL to WebViewPrintPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return WebViewPrintPage(
                        config: WebViewPrintConfig(
                          initialUrl: text.text.trim(),
                        ),
                      );
                    },
                  ),
                );
              },
              child: const Text("NEXT"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }
}