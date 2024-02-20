import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddQuizScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;

  AddQuizScreen({required this.courseId, required this.moduleId});

  @override
  _AddQuizScreenState createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final List<Map<String, dynamic>> _questions = [];
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _option1Controller = TextEditingController();
  final TextEditingController _option2Controller = TextEditingController();
  final TextEditingController _option3Controller = TextEditingController();
  final TextEditingController _option4Controller = TextEditingController();
  final TextEditingController _correctAnswerController =
      TextEditingController();

  void _addQuestion() {
    Map<String, dynamic> question = {
      'question': _questionController.text,
      'options': [
        _option1Controller.text,
        _option2Controller.text,
        _option3Controller.text,
        _option4Controller.text,
      ],
      'correctAnswer': _correctAnswerController.text,
    };
    _questions.add(question);

    // Clear text fields after adding a question
    _questionController.clear();
    _option1Controller.clear();
    _option2Controller.clear();
    _option3Controller.clear();
    _option4Controller.clear();
    _correctAnswerController.clear();

    setState(() {});
  }

  void _addQuiz() {
    FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(widget.moduleId)
        .collection('quizzes')
        .add({
      'questions': _questions,
    }).then((_) {
      // Show success message or navigate back
      Navigator.pop(context);
    }).catchError((error) {
      // Handle error
      print("Failed to add quiz: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Quiz'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _questions.length; i++)
                ListTile(
                  title: Text(_questions[i]['question']),
                  subtitle:
                      Text('Correct Answer: ${_questions[i]['correctAnswer']}'),
                ),
              TextField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: _option1Controller,
                decoration: InputDecoration(labelText: 'Option 1'),
              ),
              TextField(
                controller: _option2Controller,
                decoration: InputDecoration(labelText: 'Option 2'),
              ),
              TextField(
                controller: _option3Controller,
                decoration: InputDecoration(labelText: 'Option 3'),
              ),
              TextField(
                controller: _option4Controller,
                decoration: InputDecoration(labelText: 'Option 4'),
              ),
              TextField(
                controller: _correctAnswerController,
                decoration: InputDecoration(labelText: 'Correct Answer'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addQuestion,
                child: Text('Add Question'),
              ),
              ElevatedButton(
                onPressed: _addQuiz,
                child: Text('Add Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
