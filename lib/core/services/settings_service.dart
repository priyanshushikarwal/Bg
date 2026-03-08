import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class FirmDetails {
  final String name;
  final String address;
  final String email;
  final String mobile;

  const FirmDetails({
    required this.name,
    this.address = '',
    this.email = '',
    this.mobile = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'email': email,
    'mobile': mobile,
  };

  factory FirmDetails.fromJson(Map<String, dynamic> json) => FirmDetails(
    name: json['name'] as String? ?? '',
    address: json['address'] as String? ?? '',
    email: json['email'] as String? ?? '',
    mobile: json['mobile'] as String? ?? '',
  );

  FirmDetails copyWith({
    String? name,
    String? address,
    String? email,
    String? mobile,
  }) {
    return FirmDetails(
      name: name ?? this.name,
      address: address ?? this.address,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
    );
  }
}

class SettingsService {
  static const String _boxName = 'app_settings';
  static const String _releaseLetterDirKey = 'release_letter_dir';
  static const String _firmsKey = 'firms_list';
  static const String _firmDetailsKey = 'firm_details';

  static const List<String> _defaultFirms = [
    'Doon Infrapower Projects Pvt Ltd',
    'Doon Electrical Industries',
    'B Hi Tech Power Transformer',
  ];

  static const Map<String, FirmDetails> _defaultFirmDetails = {
    'Doon Infrapower Projects Pvt Ltd': FirmDetails(
      name: 'Doon Infrapower Projects Pvt Ltd',
      address: '16A, JAMANA COLONY, VIDHYADHAR NAGAR, JAIPUR 302039',
      email: 'bhitech2021@gmail.com',
      mobile: '6376270060',
    ),
    'Doon Electrical Industries': FirmDetails(
      name: 'Doon Electrical Industries',
      address: '',
      email: '',
      mobile: '',
    ),
    'B Hi Tech Power Transformer': FirmDetails(
      name: 'B Hi Tech Power Transformer',
      address: '',
      email: '',
      mobile: '',
    ),
  };

  static late Box _settingsBox;

  static Future<void> init() async {
    _settingsBox = await Hive.openBox(_boxName);
    // No forced overwrite — the firms getter handles defaults safely
  }

  /// Get the custom directory for saving release letters.
  /// Returns null if no custom directory has been set (defaults to Desktop).
  static String? get releaseLetterDir {
    return _settingsBox.get(_releaseLetterDirKey) as String?;
  }

  /// Set the custom directory for saving release letters.
  static Future<void> setReleaseLetterDir(String? path) async {
    if (path == null) {
      await _settingsBox.delete(_releaseLetterDirKey);
    } else {
      await _settingsBox.put(_releaseLetterDirKey, path);
    }
  }

  // --- Firm Management ---

  /// Get the list of firms. Returns default firms if none saved.
  static List<String> get firms {
    final saved = _settingsBox.get(_firmsKey);
    if (saved == null) return List<String>.from(_defaultFirms);
    return List<String>.from(saved as List);
  }

  /// Add a new firm name.
  static Future<void> addFirm(String name) async {
    final current = firms;
    if (!current.contains(name)) {
      current.add(name);
      await _settingsBox.put(_firmsKey, current);
    }
  }

  /// Remove a firm by name.
  static Future<void> removeFirm(String name) async {
    final current = firms;
    current.remove(name);
    await _settingsBox.put(_firmsKey, current);
    // Also remove firm details
    await _removeFirmDetails(name);
  }

  // --- Firm Details Management ---

  /// Get details for a specific firm.
  static FirmDetails getFirmDetails(String firmName) {
    final allDetailsJson = _settingsBox.get(_firmDetailsKey);
    if (allDetailsJson != null) {
      try {
        final Map<String, dynamic> allDetails = Map<String, dynamic>.from(
          jsonDecode(allDetailsJson as String),
        );
        if (allDetails.containsKey(firmName)) {
          return FirmDetails.fromJson(
            Map<String, dynamic>.from(allDetails[firmName] as Map),
          );
        }
      } catch (_) {}
    }
    // Return default if available, otherwise empty
    return _defaultFirmDetails[firmName] ??
        FirmDetails(name: firmName);
  }

  /// Save details for a specific firm.
  static Future<void> saveFirmDetails(FirmDetails details) async {
    Map<String, dynamic> allDetails = {};
    final existing = _settingsBox.get(_firmDetailsKey);
    if (existing != null) {
      try {
        allDetails = Map<String, dynamic>.from(
          jsonDecode(existing as String),
        );
      } catch (_) {}
    }
    allDetails[details.name] = details.toJson();
    await _settingsBox.put(_firmDetailsKey, jsonEncode(allDetails));
  }

  /// Remove details for a specific firm.
  static Future<void> _removeFirmDetails(String firmName) async {
    final existing = _settingsBox.get(_firmDetailsKey);
    if (existing != null) {
      try {
        final allDetails = Map<String, dynamic>.from(
          jsonDecode(existing as String),
        );
        allDetails.remove(firmName);
        await _settingsBox.put(_firmDetailsKey, jsonEncode(allDetails));
      } catch (_) {}
    }
  }
}
