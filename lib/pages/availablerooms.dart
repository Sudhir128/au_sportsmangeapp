import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/room_service.dart';
import 'package:flutter_application_1/widgets/common.dart';
import 'package:flutter_application_1/widgets/game_card.dart';

class AvailableRoomsPage extends StatefulWidget {
  final String sport;

  const AvailableRoomsPage({super.key, required this.sport});

  @override
  State<AvailableRoomsPage> createState() => _AvailableRoomsPageState();
}

class _AvailableRoomsPageState extends State<AvailableRoomsPage> {
  List<RoomModel> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _loading = true);
    try {
      final rooms = await RoomService.fetchOpenRooms(sport: widget.sport);
      if (!mounted) return;
      setState(() => _rooms = rooms);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, 'Failed to load rooms.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinRoom(RoomModel room) async {
    try {
      await RoomService.joinRoom(room);
      if (!mounted) return;
      showAppSnackBar(context, 'Joined ${room.name}!');
      await _loadRooms();
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.sport} Games')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? EmptyState(
                  icon: Icons.sports,
                  title: 'No open games',
                  subtitle: 'Host the first ${widget.sport} game!',
                )
              : RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return GameCard(room: room, onJoin: () => _joinRoom(room));
                    },
                  ),
                ),
    );
  }
}
