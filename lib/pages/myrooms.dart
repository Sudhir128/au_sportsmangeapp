import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class myrooms extends StatefulWidget {
  final int roomId; 
  final int userId;

  const myrooms({Key? key, required this.roomId, required this.userId}) : super(key: key);

  @override
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<myrooms> {
  final SupabaseClient supabase = SupabaseClient(
    'https://aiadfhpajrtlxjiypkuk.supabase.co',
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpYWRmaHBhanJ0bHhqaXlwa3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTkwMTQ2NjcsImV4cCI6MjAxNDU5MDY2N30.7XfE2XuXcueNRp8nbgXN52z3CYvpe7PeVXf4pB_V8t8",
  );

  List<Map<String, dynamic>> usersInRoom = [];

  @override
  void initState() {
    super.initState();
    fetchUsersInRoom();
  }

Future<void> fetchUsersInRoom() async {
  try {
    final response = await supabase
        .from('users_in_rooms')
        .select()
        .eq('room_id', widget.roomId)
        .execute();
    print('Response: $response');
    if (response.data != null) {
      setState(() {
        usersInRoom = response.data as List<Map<String, dynamic>>;
      });
    } else if (response.data != null) {
      print('Supabase Error: ${response.data}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

Future<void> leaveRoom() async {
  try {
    final response = await supabase
        .from('users_in_rooms')
        .delete()
        .eq('room_id', widget.roomId)
        .eq('user_id', widget.userId)
        .execute();

    if (response.data == null) {
      Navigator.pop(context);
    } else if (response.data != null) {
      print('Supabase Error: ${response.data}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Users in Room:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: usersInRoom.length,
              itemBuilder: (context, index) {
                final user = usersInRoom[index];
                return ListTile(
                  title: Text(user['user_name'] as String),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: leaveRoom,
            child: Text('Leave Room'),
          ),
        ],
      ),
    );
  }

}
