import 'package:uuid/uuid.dart';
import '../models/bg_model.dart';
import '../../core/services/supabase_service.dart';

class BgRepository {
  final _uuid = const Uuid();


  Future<List<BgModel>> getAllBgs() async {
    return await SupabaseService.fetchAllBgs();
  }

  Future<BgModel?> getBgById(String id) async {
    final allBgs = await SupabaseService.fetchAllBgs();
    try {
      return allBgs.firstWhere((bg) => bg.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addBg(BgModel bg) async {
    await SupabaseService.upsertBg(bg);
  }

  Future<void> updateBg(BgModel bg) async {
    final updatedBg = bg.copyWith(updatedAt: DateTime.now());
    await SupabaseService.upsertBg(updatedBg);
  }

  Future<void> deleteBg(String id) async {
    await SupabaseService.deleteBg(id);
  }


  Future<List<BgModel>> getActiveBgs() async {
    final allBgs = await getAllBgs();
    return allBgs
        .where((bg) => bg.status == BgStatus.active && !bg.isExpired)
        .toList();
  }

  Future<List<BgModel>> getExpiredBgs() async {
    final allBgs = await getAllBgs();
    return allBgs
        .where((bg) => bg.isExpired || bg.status == BgStatus.expired)
        .toList();
  }

  Future<List<BgModel>> getReleasedBgs() async {
    final allBgs = await getAllBgs();
    return allBgs.where((bg) => bg.status == BgStatus.released).toList();
  }

  Future<List<BgModel>> getBgsExpiringWithinDays(int days) async {
    final allBgs = await getAllBgs();
    return allBgs.where((bg) => bg.isExpiringWithinDays(days)).toList();
  }

  Future<List<BgModel>> searchBgs(String query) async {
    final allBgs = await getAllBgs();
    final q = query.toLowerCase();
    return allBgs.where((bg) {
      return bg.bgNumber.toLowerCase().contains(q) ||
          bg.bankName.toLowerCase().contains(q) ||
          bg.discom.toLowerCase().contains(q) ||
          bg.tenderNumber.toLowerCase().contains(q) ||
          bg.firmName.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<BgModel>> filterByBank(String bankName) async {
    final allBgs = await getAllBgs();
    return allBgs.where((bg) => bg.bankName == bankName).toList();
  }

  Future<List<BgModel>> filterByDiscom(String discom) async {
    final allBgs = await getAllBgs();
    return allBgs.where((bg) => bg.discom == discom).toList();
  }


  Future<void> extendBg(String bgId, ExtensionModel extension) async {
    final bg = await getBgById(bgId);
    if (bg != null) {
      final updatedExtensions = [...bg.extensionHistory, extension];
      final updatedBg = bg.copyWith(
        extensionHistory: updatedExtensions,
        expiryDate: extension.newBgExpiryDate,
        claimExpiryDate: extension.newClaimExpiryDate,
        updatedAt: DateTime.now(),
      );
      await SupabaseService.upsertBg(updatedBg);
    }
  }


  Future<void> releaseBg(String bgId) async {
    final bg = await getBgById(bgId);
    if (bg != null) {
      final updatedBg = bg.copyWith(
        status: BgStatus.released,
        updatedAt: DateTime.now(),
      );
      await SupabaseService.upsertBg(updatedBg);
    }
  }


  Future<void> addDocument(String bgId, DocumentModel document) async {
    final bg = await getBgById(bgId);
    if (bg != null) {
      final updatedDocuments = [...bg.documents, document];
      final updatedBg = bg.copyWith(
        documents: updatedDocuments,
        updatedAt: DateTime.now(),
      );
      await SupabaseService.upsertBg(updatedBg);
    }
  }

  Future<void> removeDocument(String bgId, String documentId) async {
    final bg = await getBgById(bgId);
    if (bg != null) {
      final updatedDocuments = bg.documents
          .where((d) => d.id != documentId)
          .toList();
      final updatedBg = bg.copyWith(
        documents: updatedDocuments,
        updatedAt: DateTime.now(),
      );
      await SupabaseService.upsertBg(updatedBg);
    }
  }


  Future<double> getTotalBgAmount() async {
    final allBgs = await getActiveBgs();
    return allBgs.fold<double>(0, (sum, bg) => sum + bg.amount);
  }

  Future<double> getTotalFdrAmount() async {
    final allBgs = await getAllBgs();
    return allBgs
        .where((bg) => bg.fdrDetails != null)
        .fold<double>(0, (sum, bg) => sum + (bg.fdrDetails?.fdrAmount ?? 0));
  }

  Future<int> getActiveBgCount() async {
    return (await getActiveBgs()).length;
  }

  Future<int> getExpiringBgCount(int days) async {
    return (await getBgsExpiringWithinDays(days)).length;
  }

  Future<int> getReleasedBgCount() async {
    return (await getReleasedBgs()).length;
  }

  Future<Set<String>> getAllBankNames() async {
    final allBgs = await getAllBgs();
    return allBgs
        .map((bg) => bg.bankName)
        .where((name) => name.isNotEmpty)
        .toSet();
  }

  Future<Set<String>> getAllDiscoms() async {
    final allBgs = await getAllBgs();
    return allBgs.map((bg) => bg.discom).where((d) => d.isNotEmpty).toSet();
  }


  BgModel createBg({
    required String bgNumber,
    required DateTime issueDate,
    required double amount,
    required DateTime expiryDate,
    required DateTime claimExpiryDate,
    required String bankName,
    required String discom,
    required String tenderNumber,
    String firmName = 'Doon Infrapower Projects Pvt Ltd',
    FdrModel? fdrDetails,
    List<DocumentModel>? documents,
  }) {
    final now = DateTime.now();
    return BgModel(
      id: _uuid.v4(),
      bgNumber: bgNumber,
      issueDate: issueDate,
      amount: amount,
      expiryDate: expiryDate,
      claimExpiryDate: claimExpiryDate,
      bankName: bankName,
      discom: discom,
      tenderNumber: tenderNumber,
      status: BgStatus.active,
      extensionHistory: [],
      documents: documents ?? [],
      fdrDetails: fdrDetails,
      createdAt: now,
      updatedAt: now,
      firmName: firmName,
    );
  }

  ExtensionModel createExtension({
    required DateTime extensionDate,
    required DateTime newBgExpiryDate,
    required DateTime newClaimExpiryDate,
    String? remarks,
    String? documentId,
  }) {
    return ExtensionModel(
      id: _uuid.v4(),
      extensionDate: extensionDate,
      newBgExpiryDate: newBgExpiryDate,
      newClaimExpiryDate: newClaimExpiryDate,
      remarks: remarks,
      documentId: documentId,
    );
  }

  FdrModel createFdr({
    required String fdrNumber,
    required DateTime fdrDate,
    required double fdrAmount,
    required double roi,
    String? bankName,
    DateTime? maturityDate,
  }) {
    return FdrModel(
      id: _uuid.v4(),
      fdrNumber: fdrNumber,
      fdrDate: fdrDate,
      fdrAmount: fdrAmount,
      roi: roi,
      bankName: bankName,
      maturityDate: maturityDate,
    );
  }

  DocumentModel createDocument({
    required DocumentType type,
    int version = 1,
    required String filePath,
    required String fileName,
    String? description,
    int? fileSizeBytes,
  }) {
    return DocumentModel(
      id: _uuid.v4(),
      type: type,
      version: version,
      uploadDate: DateTime.now(),
      filePath: filePath,
      fileName: fileName,
      description: description,
      fileSizeBytes: fileSizeBytes,
    );
  }
}
