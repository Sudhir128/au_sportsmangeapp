import 'package:flutter_application_1/services/session_service.dart';
import 'package:flutter_application_1/utils/parse_utils.dart';
import 'package:flutter_application_1/widgets/common.dart';

enum RoomRelation { hosted, joined }

class RoomModel {
  final int id;
  final String name;
  final int size;
  final String description;
  final bool isPublic;
  final String sport;
  final String? inTime;
  final String? outTime;
  final String? hostRollnumber;
  final String? hostName;
  final int memberCount;
  final RoomRelation relation;
  final bool isJoinedByMe;

  const RoomModel({
    required this.id,
    required this.name,
    required this.size,
    required this.description,
    required this.isPublic,
    required this.sport,
    this.inTime,
    this.outTime,
    this.hostRollnumber,
    this.hostName,
    this.memberCount = 0,
    this.relation = RoomRelation.joined,
    this.isJoinedByMe = false,
  });

  factory RoomModel.fromMap(
    Map<String, dynamic> map, {
    int memberCount = 0,
    RoomRelation relation = RoomRelation.joined,
    bool isJoinedByMe = false,
    String? hostName,
  }) {
    return RoomModel(
      id: parseId(map['id']),
      name: map['room_name'] as String? ?? '',
      size: parseCount(map['room_size']),
      description: map['room_description'] as String? ?? '',
      isPublic: map['is_public'] as bool? ?? true,
      sport: map['sport'] as String? ?? '',
      inTime: map['in_time']?.toString(),
      outTime: map['out_time']?.toString(),
      hostRollnumber: map['rollnumber'] as String?,
      hostName: hostName ?? map['host_name'] as String?,
      memberCount: memberCount,
      relation: relation,
      isJoinedByMe: isJoinedByMe,
    );
  }

  int get spotsLeft => (size - memberCount).clamp(0, size);
  bool get isFull => memberCount >= size;
}

class RoomService {
  static Future<Set<int>> _myJoinedRoomIds(int userId) async {
    final rows = await supabase
        .from('users_in_rooms')
        .select('room_id')
        .eq('user_id', userId);

    return (rows as List)
        .map((row) => parseId((row as Map<String, dynamic>)['room_id']))
        .where((id) => id > 0)
        .toSet();
  }

  static Future<Map<int, int>> _memberCountsForRooms(List<int> roomIds) async {
    if (roomIds.isEmpty) return {};

    final rows = await supabase
        .from('users_in_rooms')
        .select('room_id')
        .inFilter('room_id', roomIds);

    final counts = <int, int>{};
    for (final row in rows as List) {
      final roomId = parseId((row as Map<String, dynamic>)['room_id']);
      counts[roomId] = (counts[roomId] ?? 0) + 1;
    }
    return counts;
  }

  static Future<List<RoomModel>> fetchOpenRooms({String? sport}) async {
    final user = SessionService.currentUser;
    final joinedIds = user == null ? <int>{} : await _myJoinedRoomIds(user.id);

    var query = supabase.from('room').select().eq('is_public', true);
    if (sport != null && sport.isNotEmpty) {
      query = query.eq('sport', sport);
    }

    final rooms = await query.order('created_at', ascending: false);
    final roomMaps = (rooms as List).cast<Map<String, dynamic>>();
    final roomIds = roomMaps.map((room) => parseId(room['id'])).toList();
    final counts = await _memberCountsForRooms(roomIds);

    return roomMaps
        .map(
          (room) => RoomModel.fromMap(
            room,
            memberCount: counts[parseId(room['id'])] ?? 0,
            isJoinedByMe: joinedIds.contains(parseId(room['id'])),
          ),
        )
        .where((room) => !room.isFull)
        .toList();
  }

  static Future<List<RoomModel>> fetchHostedRooms() async {
    final user = SessionService.currentUser;
    if (user == null) return [];

    final rooms = await supabase
        .from('room')
        .select()
        .eq('rollnumber', user.rollnumber)
        .order('created_at', ascending: false);

    final roomMaps = (rooms as List).cast<Map<String, dynamic>>();
    final roomIds = roomMaps.map((room) => parseId(room['id'])).toList();
    final counts = await _memberCountsForRooms(roomIds);

    return roomMaps
        .map(
          (room) => RoomModel.fromMap(
            room,
            memberCount: counts[parseId(room['id'])] ?? 0,
            relation: RoomRelation.hosted,
            isJoinedByMe: true,
            hostName: user.name,
          ),
        )
        .toList();
  }

  static Future<List<RoomModel>> fetchJoinedRooms() async {
    final user = SessionService.currentUser;
    if (user == null) return [];

    final memberships = await supabase
        .from('users_in_rooms')
        .select('room_id')
        .eq('user_id', user.id);

    final joinedIds = (memberships as List)
        .map((row) => parseId((row as Map<String, dynamic>)['room_id']))
        .where((id) => id > 0)
        .toList();

    if (joinedIds.isEmpty) return [];

    final rooms = await supabase.from('room').select().inFilter('id', joinedIds);
    final roomMaps = (rooms as List).cast<Map<String, dynamic>>();
    final counts = await _memberCountsForRooms(joinedIds);

    final hostedRoll = user.rollnumber;
    return roomMaps.map((room) {
      final isHosted = room['rollnumber']?.toString() == hostedRoll;
      return RoomModel.fromMap(
        room,
        memberCount: counts[parseId(room['id'])] ?? 0,
        relation: isHosted ? RoomRelation.hosted : RoomRelation.joined,
        isJoinedByMe: true,
      );
    }).toList();
  }

  static Future<RoomModel> createRoom({
    required String name,
    required int size,
    required String description,
    required bool isPublic,
    required String sport,
    required String inTime,
    required String outTime,
  }) async {
    final user = SessionService.currentUser;
    if (user == null) {
      throw Exception('Please log in to create a room.');
    }

    final created = await supabase
        .from('room')
        .insert({
          'room_name': name,
          'room_size': size,
          'room_description': description,
          'is_public': isPublic,
          'sport': sport,
          'in_time': inTime,
          'out_time': outTime,
          'rollnumber': user.rollnumber,
          'host_user_id': user.id,
        })
        .select()
        .single();

    final roomId = parseId(created['id']);

    await supabase.from('users_in_rooms').upsert({
      'user_id': user.id,
      'room_id': roomId,
    }, onConflict: 'user_id,room_id');

    return RoomModel.fromMap(
      Map<String, dynamic>.from(created),
      memberCount: 1,
      relation: RoomRelation.hosted,
      isJoinedByMe: true,
      hostName: user.name,
    );
  }

  static Future<void> updateRoom({
    required int roomId,
    required String name,
    required int size,
    required String description,
    required bool isPublic,
    required String sport,
    required String inTime,
    required String outTime,
  }) async {
    final user = SessionService.currentUser;
    if (user == null) {
      throw Exception('Please log in to edit a room.');
    }

    await supabase.from('room').update({
      'room_name': name,
      'room_size': size,
      'room_description': description,
      'is_public': isPublic,
      'sport': sport,
      'in_time': inTime,
      'out_time': outTime,
    }).eq('id', roomId);
  }

  static Future<void> joinRoom(RoomModel room) async {
    final user = SessionService.currentUser;
    if (user == null) {
      throw Exception('Please log in to join a room.');
    }

    if (room.isFull) {
      throw Exception('This room is already full.');
    }

    final existing = await supabase
        .from('users_in_rooms')
        .select('id')
        .eq('room_id', room.id)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      throw Exception('You have already joined this room.');
    }

    await supabase.from('users_in_rooms').insert({
      'user_id': user.id,
      'room_id': room.id,
    });
  }

  static Future<void> leaveRoom(int roomId) async {
    final user = SessionService.currentUser;
    if (user == null) return;

    await supabase
        .from('users_in_rooms')
        .delete()
        .eq('room_id', roomId)
        .eq('user_id', user.id);
  }

  static Future<List<Map<String, dynamic>>> fetchRoomMembers(int roomId) async {
    final memberships = await supabase
        .from('users_in_rooms')
        .select('user_id')
        .eq('room_id', roomId);

    final userIds = (memberships as List)
        .map((entry) => parseId((entry as Map<String, dynamic>)['user_id']))
        .where((id) => id > 0)
        .toList();

    if (userIds.isEmpty) return [];

    final users = await supabase
        .from('user')
        .select('id, name, rollnumber')
        .inFilter('id', userIds);

    return (users as List).cast<Map<String, dynamic>>();
  }
}
