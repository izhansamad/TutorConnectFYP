import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/Teacher.dart';

class AvailabilityDialog extends StatefulWidget {
  final String teacherId;
  final TimeOfDay initialFromTime;
  final TimeOfDay initialToTime;

  const AvailabilityDialog({
    Key? key,
    required this.teacherId,
    required this.initialFromTime,
    required this.initialToTime,
  }) : super(key: key);

  @override
  _AvailabilityDialogState createState() => _AvailabilityDialogState();
}

class _AvailabilityDialogState extends State<AvailabilityDialog> {
  late TimeOfDay selectedFromTime;
  late TimeOfDay selectedToTime;

  @override
  void initState() {
    super.initState();
    selectedFromTime = widget.initialFromTime;
    selectedToTime = widget.initialToTime;
  }

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFromTime ? selectedFromTime : selectedToTime,
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          selectedFromTime = picked;
        } else {
          selectedToTime = picked;
        }
      });
    }
  }

  Future<void> _updateAvailability() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final DocumentReference teacherRef =
        _firestore.collection('teacher').doc(widget.teacherId);

    try {
      await teacherRef.update({
        'availabilityFrom': selectedFromTime.toString(),
        'availabilityTo': selectedToTime.toString(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Availability updated successfully"),
        ),
      );
      final teacherDataProvider = context.read<TeacherDataProvider>();
      teacherDataProvider.refreshTeacherData();
      setState(() {});
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update availability: $error"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Availability Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('From: ${selectedFromTime.format(context)}'),
            onTap: () => _selectTime(context, true),
          ),
          ListTile(
            title: Text('To: ${selectedToTime.format(context)}'),
            onTap: () => _selectTime(context, false),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _updateAvailability,
          child: Text('Set'),
        ),
      ],
    );
  }
}
