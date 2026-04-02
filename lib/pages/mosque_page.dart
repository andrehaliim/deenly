import 'package:flutter/material.dart';

class MosquePage extends StatefulWidget {
  const MosquePage({super.key});

  @override
  State<MosquePage> createState() => _MosquePageState();
}

class _MosquePageState extends State<MosquePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Mosque'),
    );
  }
}