import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/session/data/models/session_model.dart';

class LocalStorageService {
  static const String _sessionsKey = 'sessions_list';

  Future<void> saveSession(SessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    List<SessionModel> sessions = await getSessions();
    
    // Check if session already exists, update if so, else add
    int index = sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }

    final String encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, encoded);
  }

  Future<List<SessionModel>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_sessionsKey);
    
    if (encoded == null) return [];

    final List decoded = jsonDecode(encoded);
    return decoded.map((s) => SessionModel.fromJson(s)).toList();
  }

  Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    List<SessionModel> sessions = await getSessions();
    
    sessions.removeWhere((s) => s.id == sessionId);
    
    final String encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, encoded);
  }
}
