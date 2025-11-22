import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class availableRooms extends StatefulWidget {
  final String title;

  availableRooms({required this.title});

  @override
  _AvailableRoomsState createState() => _AvailableRoomsState();
}

class _AvailableRoomsState extends State<availableRooms> {
  final SupabaseClient supabase = SupabaseClient(
    'https://aiadfhpajrtlxjiypkuk.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpYWRmaHBhanJ0bHhqaXlwa3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTkwMTQ2NjcsImV4cCI6MjAxNDU5MDY2N30.7XfE2XuXcueNRp8nbgXN52z3CYvpe7PeVXf4pB_V8t8',
  );

  List<RoomData> rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await supabase.from('room').select().execute();
    if (response.data == null) {
      // Data fetched successfully
      print('Data fetched successfully');
      List<RoomData> fetchedRooms = [];
      for (var entry in response.data as List) {
        fetchedRooms.add(RoomData(
          entry['room_name'],
          entry['room_size'],
          entry['room_description'],
        ));
      }

      // Update the state with the fetched data
      setState(() {
        rooms = fetchedRooms;
      });
    } else {
      // Handle error
      print('Error fetching data: ${response.data}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Rooms - ${widget.title}'),
      ),
      body: RoomList(rooms: rooms),
    );
  }
}

class RoomList extends StatelessWidget {
  final List<RoomData> rooms;

  RoomList({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return RoomCard(room: rooms[index]);
      },
    );
  }
}

class RoomCard extends StatelessWidget {
  final RoomData room;

  RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(room.name),
        subtitle: Text('${room.size} - ${room.description}'),
        onTap: () {
          
        },
      ),
    );
  }
}

class RoomData {
  final String name;
  final int size;
  final String description;

  RoomData(this.name, this.size, this.description);
}

