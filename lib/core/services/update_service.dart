import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  Future<String?> getMinRequiredVersion() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version')
          .get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return data['min_version'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String> getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '0.0.0';
    }
  }

  bool isUpdateRequired(String current, String minRequired) {
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final minParts = minRequired.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final c = i < currentParts.length ? currentParts[i] : 0;
      final m = i < minParts.length ? minParts[i] : 0;
      if (c < m) return true;
      if (c > m) return false;
    }
    return false;
  }
}
