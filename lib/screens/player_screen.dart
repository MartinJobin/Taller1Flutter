import 'package:flutter/material.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  const PlayerScreen({super.key, required this.title});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.red, Colors.black]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.white),
                      onPressed: () => setState(() => isPlaying = !isPlaying),
                    ),
                    Text(isPlaying ? "REPRODUCIENDO..." : "PAUSADO", style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.replay_10, size: 40), onPressed: () {}, color: Colors.white),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.play_arrow, size: 50), onPressed: () {}, color: Colors.red),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.forward_10, size: 40), onPressed: () {}, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}