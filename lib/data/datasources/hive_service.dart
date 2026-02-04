import 'package:hive_flutter/hive_flutter.dart';
import '../models/bg_model.dart';

class HiveService {
  static const String bgBoxName = 'bg_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(BgStatusAdapter());
    Hive.registerAdapter(BgModelAdapter());
    Hive.registerAdapter(FdrModelAdapter());
    Hive.registerAdapter(ExtensionModelAdapter());
    Hive.registerAdapter(DocumentTypeAdapter());
    Hive.registerAdapter(DocumentModelAdapter());

    // Open boxes
    await Hive.openBox<BgModel>(bgBoxName);
  }

  static Box<BgModel> get bgBox => Hive.box<BgModel>(bgBoxName);

  // BG CRUD Operations
  static Future<void> addBg(BgModel bg) async {
    await bgBox.put(bg.id, bg);
  }

  static Future<void> updateBg(BgModel bg) async {
    await bgBox.put(bg.id, bg);
  }

  static Future<void> deleteBg(String id) async {
    await bgBox.delete(id);
  }

  static BgModel? getBg(String id) {
    return bgBox.get(id);
  }

  static List<BgModel> getAllBgs() {
    return bgBox.values.toList();
  }

  static List<BgModel> getActiveBgs() {
    return bgBox.values.where((bg) => bg.status == BgStatus.active).toList();
  }

  static List<BgModel> getExpiredBgs() {
    return bgBox.values
        .where((bg) => bg.status == BgStatus.expired || bg.isExpired)
        .toList();
  }

  static List<BgModel> getReleasedBgs() {
    return bgBox.values.where((bg) => bg.status == BgStatus.released).toList();
  }

  static List<BgModel> getBgsExpiringWithinDays(int days) {
    return bgBox.values.where((bg) => bg.isExpiringWithinDays(days)).toList();
  }

  static List<BgModel> searchBgs(String query) {
    final lowerQuery = query.toLowerCase();
    return bgBox.values.where((bg) {
      return bg.bgNumber.toLowerCase().contains(lowerQuery) ||
          bg.bankName.toLowerCase().contains(lowerQuery) ||
          bg.discom.toLowerCase().contains(lowerQuery) ||
          bg.tenderNumber.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<BgModel> filterBgsByBank(String bankName) {
    return bgBox.values.where((bg) => bg.bankName == bankName).toList();
  }

  static List<BgModel> filterBgsByDiscom(String discom) {
    return bgBox.values.where((bg) => bg.discom == discom).toList();
  }

  // Statistics
  static double getTotalBgAmount() {
    return bgBox.values
        .where((bg) => bg.status == BgStatus.active)
        .fold(0, (sum, bg) => sum + bg.amount);
  }

  static double getTotalFdrAmount() {
    return bgBox.values
        .where((bg) => bg.fdrDetails != null)
        .fold(0, (sum, bg) => sum + (bg.fdrDetails?.fdrAmount ?? 0));
  }

  static int getActiveBgCount() {
    return bgBox.values.where((bg) => bg.status == BgStatus.active).length;
  }

  static int getExpiringBgCount(int days) {
    return bgBox.values.where((bg) => bg.isExpiringWithinDays(days)).length;
  }

  static int getReleasedBgCount() {
    return bgBox.values.where((bg) => bg.status == BgStatus.released).length;
  }

  static Set<String> getAllBankNames() {
    return bgBox.values.map((bg) => bg.bankName).toSet();
  }

  static Set<String> getAllDiscoms() {
    return bgBox.values.map((bg) => bg.discom).toSet();
  }

  // Clear all data
  static Future<void> clearAllBgs() async {
    await bgBox.clear();
  }
}
