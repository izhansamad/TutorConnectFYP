import 'package:flutter/material.dart';

class AddModulesScreen extends StatefulWidget {
  const AddModulesScreen({super.key});

  @override
  State<AddModulesScreen> createState() => _AddModulesScreenState();
}

class _AddModulesScreenState extends State<AddModulesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Modules"),
      ),
    );
  }
}
