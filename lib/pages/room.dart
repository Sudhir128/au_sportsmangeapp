import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/pages/createroom.dart';
import 'package:flutter_application_1/pages/edit_room.dart';
import 'package:flutter_application_1/services/room_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/common.dart';
import 'package:flutter_application_1/widgets/game_card.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const sports = [
    'Cricket',
    'Football',
    'Basketball',
    'Volleyball',
    'Badminton',
    'Ball Badminton',
    'Handball',
    'Kabaddi',
    'Throwball',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppTheme.background.withValues(alpha: 0.8),
        title: const Text('Games'),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            border: const Border(
              bottom: BorderSide(color: AppTheme.primary, width: 3),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primary.withValues(alpha: 0.0),
                AppTheme.primary.withValues(alpha: 0.1),
              ],
            ),
          ),
          tabs: const [
            Tab(text: 'Find Games'),
            Tab(text: 'My Games'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateRoomPage()),
          );
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: Text('Host Game', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
      body: AppBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _FindGamesTab(sports: sports),
            const _MyGamesTab(),
          ],
        ),
      ),
    );
  }
}

class _FindGamesTab extends StatefulWidget {
  final List<String> sports;

  const _FindGamesTab({required this.sports});

  @override
  State<_FindGamesTab> createState() => _FindGamesTabState();
}

class _FindGamesTabState extends State<_FindGamesTab> {
  String? _selectedSport;
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
      final rooms = await RoomService.fetchOpenRooms(sport: _selectedSport);
      if (!mounted) return;
      setState(() => _rooms = rooms);
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Could not load games.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinRoom(RoomModel room) async {
    try {
      await RoomService.joinRoom(room);
      if (!mounted) return;
      showAppSnackBar(context, 'Joined ${room.name}! Check My Games > Joined.');
      await _loadRooms();
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 120),
        SportChipBar(
          sports: widget.sports,
          selected: _selectedSport,
          onSelected: (sport) {
            setState(() => _selectedSport = sport);
            _loadRooms();
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _rooms.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off,
                      title: 'No open games',
                      subtitle: _selectedSport == null
                          ? 'Be the first to host a game using the Host Game button.'
                          : 'No open $_selectedSport games right now. Host one!',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRooms,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: _rooms.length,
                        itemBuilder: (context, index) {
                          final room = _rooms[index];
                          return GameCard(
                            room: room,
                            onJoin: () => _joinRoom(room),
                            onTap: () => _showRoomDetails(room),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Future<void> _showRoomDetails(RoomModel room) async {
    final members = await RoomService.fetchRoomMembers(room.id);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: AppTheme.glassDecoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _RoomDetailsSheet(
          room: room,
          members: members,
          onRefresh: _loadRooms,
        ),
      ),
    );
  }
}

class _MyGamesTab extends StatefulWidget {
  const _MyGamesTab();

  @override
  State<_MyGamesTab> createState() => _MyGamesTabState();
}

class _MyGamesTabState extends State<_MyGamesTab> with SingleTickerProviderStateMixin {
  late final TabController _subTabController;
  List<RoomModel> _hosted = [];
  List<RoomModel> _joined = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _loadRooms();
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() => _loading = true);
    try {
      final hosted = await RoomService.fetchHostedRooms();
      final joined = await RoomService.fetchJoinedRooms();
      final hostedIds = hosted.map((room) => room.id).toSet();
      if (!mounted) return;
      setState(() {
        _hosted = hosted;
        _joined = joined.where((room) => !hostedIds.contains(room.id)).toList();
      });
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, 'Failed to load your games.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leaveRoom(RoomModel room) async {
    await RoomService.leaveRoom(room.id);
    if (!mounted) return;
    showAppSnackBar(context, 'Left ${room.name}.');
    await _loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 110),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: AppTheme.glassCardDecoration,
          child: TabBar(
            controller: _subTabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppTheme.primaryGradient,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(text: 'Hosted (${_hosted.length})'),
              Tab(text: 'Joined (${_joined.length})'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _subTabController,
                  children: [
                    _RoomList(
                      rooms: _hosted,
                      emptyTitle: 'No hosted games',
                      emptySubtitle: 'Tap Host Game to create your first match.',
                      onRefresh: _loadRooms,
                      onLeave: _leaveRoom,
                    ),
                    _RoomList(
                      rooms: _joined,
                      emptyTitle: 'No joined games',
                      emptySubtitle: 'Browse Find Games and join open matches.',
                      onRefresh: _loadRooms,
                      onLeave: _leaveRoom,
                      showLeave: true,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _RoomList extends StatelessWidget {
  final List<RoomModel> rooms;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final Future<void> Function(RoomModel room) onLeave;
  final bool showLeave;

  const _RoomList({
    required this.rooms,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.onLeave,
    this.showLeave = false,
  });

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return EmptyState(
        icon: Icons.sports,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return GameCard(
            room: room,
            showJoinButton: false,
            onTap: () async {
              final members = await RoomService.fetchRoomMembers(room.id);
              if (!context.mounted) return;
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  decoration: AppTheme.glassDecoration.copyWith(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: _RoomDetailsSheet(
                    room: room,
                    members: members,
                    showLeave: showLeave,
                    onLeave: () => onLeave(room),
                    onRefresh: onRefresh,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RoomDetailsSheet extends StatelessWidget {
  final RoomModel room;
  final List<Map<String, dynamic>> members;
  final bool showLeave;
  final VoidCallback? onLeave;
  final VoidCallback? onRefresh;

  const _RoomDetailsSheet({
    required this.room,
    required this.members,
    this.showLeave = false,
    this.onLeave,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  room.name,
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${room.sport} • ${room.memberCount}/${room.size} players',
            style: GoogleFonts.outfit(color: AppTheme.accent, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            room.description.isEmpty ? 'No description provided.' : room.description,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Players in this game'),
          const SizedBox(height: 16),
          if (members.isEmpty)
            Text('No players joined yet.', style: TextStyle(color: AppTheme.textSecondary))
          else
            Container(
              decoration: AppTheme.glassCardDecoration,
              child: Column(
                children: members.map((member) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.surfaceLight,
                    child: Text(
                      (member['name']?.toString() ?? 'P')[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  title: Text(member['name']?.toString() ?? 'Player', style: const TextStyle(color: AppTheme.textPrimary)),
                  subtitle: Text('Roll: ${member['rollnumber'] ?? '-'}', style: TextStyle(color: AppTheme.textSecondary)),
                )).toList(),
              ),
            ),
          const SizedBox(height: 24),
          if (showLeave && onLeave != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onLeave!();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                child: const Text('Leave Game'),
              ),
            ),
          if (room.relation == RoomRelation.hosted)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditRoomPage(room: room)),
                  );
                  if (updated == true && onRefresh != null) {
                    onRefresh!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('Edit Game'),
              ),
            ),
        ],
      ),
    );
  }
}
