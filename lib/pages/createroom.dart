

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/pages/myApp_materialPage.dart';
import 'package:supabase/supabase.dart';
import 'package:flutter_application_1/pages/room.dart';

class createRoom extends StatefulWidget {
  @override
  CreateRoomState createState() => CreateRoomState();
}

class CreateRoomState extends State<createRoom> {
  final SupabaseClient supabase = SupabaseClient(
    'https://aiadfhpajrtlxjiypkuk.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpYWRmaHBhanJ0bHhqaXlwa3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTkwMTQ2NjcsImV4cCI6MjAxNDU5MDY2N30.7XfE2XuXcueNRp8nbgXN52z3CYvpe7PeVXf4pB_V8t8',
  );

  TextEditingController roomnameController = TextEditingController();
  TextEditingController roomsizeController = TextEditingController();
  TextEditingController roomdescriptionController = TextEditingController();
  TextEditingController inTimeController = TextEditingController();
  TextEditingController outTimeController = TextEditingController();

  String selectedChoice = 'Public';
  String selectedSport = 'Cricket';

  String roomNameError = '';
  String roomSizeError = '';
  String inTimeError = '';
  String outTimeError = '';

  void validateInputs() {
    setState(() {
      roomNameError =
          roomnameController.text.isEmpty || roomnameController.text.length < 4
              ? 'Room name must be at least 4 characters'
              : '';

      roomSizeError = roomsizeController.text.isEmpty
          ? 'Room size is required'
          : (int.tryParse(roomsizeController.text) ?? 0) <= 0
              ? 'Room size must be greater than 0'
              : '';

      inTimeError = inTimeController.text.isEmpty ? 'In time is required' : '';
      outTimeError =
          outTimeController.text.isEmpty ? 'Out time is required' : '';
    });
  }

  Future<void> _selectInTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        inTimeController.text = picked.format(
            context); 
      });
    }
  }

  Future<void> _selectOutTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        outTimeController.text = picked.format(
            context); 
      });
    }
  }

  Future<void> _submitData() async {
    validateInputs();

    if (roomNameError.isEmpty && roomSizeError.isEmpty) {
      final roomname = roomnameController.text;
      final int roomsize = int.tryParse(roomsizeController.text) ?? 0;
      final roomdescription = roomdescriptionController.text;
      final bool isPublic = selectedChoice == 'Public';
      final inTime = inTimeController.text;
      final outTime = outTimeController.text;
      try {
        final response = await supabase.from('room').upsert([
          {
            'room_name': roomname,
            'room_size': roomsize,
            'room_description': roomdescription,
            'is_public': isPublic,
            'in_time': inTime,
            'out_time': outTime,
            'sport': selectedSport,
          }
        ]);

    
        _showSuccessDialog();
        _navigatehome();
      } catch (e) {

        _showErrorDialog();
        _navigatehome();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Room Created Successfully'),
          content: Text('Your room has been created successfully.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
              'An error occurred while creating the room. Please try again.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigatehome() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Create Room')),
        body: Padding(
            padding: EdgeInsets.all(50.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedSport,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSport = newValue!;
                        });
                      },
                      items: <String>[
                        'Cricket',
                        'Football',
                        'Handball',
                        'Basketball',
                        'Volleyball',
                        'Throwball',
                        'Kabaddi',
                        'Badminton',
                        'Ball Badminton'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: roomnameController,
                      decoration: InputDecoration(
                        fillColor: Colors.transparent.withOpacity(0.10),
                        filled: true,
                        labelText: 'Room name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.blue)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorText: roomNameError,
                      ),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: roomsizeController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        fillColor: Colors.transparent.withOpacity(0.10),
                        filled: true,
                        labelText: 'Room size',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.blue)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorText: roomSizeError,
                      ),
                    ),
                    SizedBox(height: 30),
                    DropdownButton<String>(
                      value: selectedChoice,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedChoice = newValue!;
                        });
                      },
                      items: <String>['Public', 'Private']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: roomdescriptionController,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        fillColor: Colors.transparent.withOpacity(0.10),
                        filled: true,
                        labelText: 'Add room description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextButton(
                      onPressed: _selectInTime,
                      child: Text('Select In Time'),
                    ),
                    TextField(
                      controller: inTimeController,
                      decoration: InputDecoration(
                        fillColor: Colors.transparent.withOpacity(0.10),
                        filled: true,
                        labelText: 'In Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        errorText: inTimeError,
                      ),
                    ),
                    SizedBox(height: 30),
                    TextButton(
                      onPressed: _selectOutTime,
                      child: Text('Select Out Time'),
                    ),
                    TextField(
                      controller: outTimeController,
                      decoration: InputDecoration(
                    
                        fillColor: Colors.transparent.withOpacity(0.10),
                        filled: true,
                        labelText: 'Out Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        errorText: outTimeError,
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitData,
                      child: Text('Create Room'),
                    )
                  ],
                ),
              ),
            )));
  }
}

