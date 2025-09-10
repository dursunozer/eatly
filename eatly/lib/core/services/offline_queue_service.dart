import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/queued_photo.dart';

class OfflineQueueService {
  static const String _prefsKey = 'photo_queue_v1';

  Future<List<QueuedPhoto>> loadQueue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return <QueuedPhoto>[];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => QueuedPhoto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveQueue(List<QueuedPhoto> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<QueuedPhoto> enqueueFromBytes(List<int> bytes) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    final String path = '${dir.path}/meal_$id.jpg';
    final File f = File(path);
    await f.writeAsBytes(bytes, flush: true);

    final QueuedPhoto item = QueuedPhoto(
      id: id,
      localPath: path,
      takenAt: DateTime.now(),
      isSynced: false,
    );

    final List<QueuedPhoto> q = await loadQueue();
    q.add(item);
    await saveQueue(q);
    return item;
  }

  Future<void> markSynced(String id, {required String remotePath}) async {
    final List<QueuedPhoto> q = await loadQueue();
    final int idx = q.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    q[idx] = QueuedPhoto(
      id: q[idx].id,
      localPath: q[idx].localPath,
      takenAt: q[idx].takenAt,
      isSynced: true,
      remotePath: remotePath,
    );
    await saveQueue(q);
  }

  Future<void> remove(String id) async {
    final List<QueuedPhoto> q = await loadQueue();
    q.removeWhere((e) => e.id == id);
    await saveQueue(q);
  }
}


