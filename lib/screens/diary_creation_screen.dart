import 'package:flutter/material.dart';

class DiaryCreationScreen extends StatefulWidget {
  const DiaryCreationScreen({super.key});
  @override
  State<DiaryCreationScreen> createState() => _DiaryCreationPageState();
}

class _DiaryCreationPageState extends State<DiaryCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("create"),
      ),
    );
  }
}
