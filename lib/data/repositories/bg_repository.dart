import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/bg_model.dart';
import '../datasources/hive_service.dart';
import '../../core/services/supabase_service.dart';

class BgRepository {
  final _uuid = const Uuid();

  // ========== CRUD Operations ==========

  Future<List<BgModel>> getAllBgs() async {
    // Always get local Hive data first (instant, never empty after add)
    final localBgs = HiveService.getAllBgs();

    try {
      // If logged in, try to sync with Supabase in background
      if (SupabaseService.isLoggedIn) {
        final cloudBgs = await SupabaseService.fetchAllBgs();

        // Only sync if Supabase actually returned data or local is empty
        // This prevents wiping local data if Supabase tables are empty/missing
        if (cloudBgs.isNotEmpty || localBgs.isEmpty) {
          // Merge: upsert cloud BGs into Hive (don't clear first!)
          for (final bg in cloudBgs) {
            await HiveService.updateBg(bg);
          }
          return HiveService.getAllBgs(); // Return merged local+cloud data
        }
      }
    } catch (e) {
      // Supabase unavailable - silently use local cache
      debugPrint('Supabase fetch failed, using local cache: $e');
    }

    // Return local Hive data (always has freshly added BGs)
    return localBgs;
  }

  Future<BgModel?> getBgById(String id) async {
    return HiveService.getBg(id);
  }

  Future<void> addBg(BgModel bg) async {
    // Save locally first (fast)
    await HiveService.addBg(bg);

    // Then sync to Supabase cloud
    if (SupabaseService.isLoggedIn) {
      try {
        await SupabaseService.upsertBg(bg);
      } catch (e) {
        print('Failed to sync BG to Supabase: $e');
        // Data is still saved locally, will sync later
      }
    }
  }

  Future<void> updateBg(BgModel bg) async {
    final updatedBg = bg.copyWith(updatedAt: DateTime.now());

    // Update locally
    await HiveService.updateBg(updatedBg);

    // Sync to Supabase
    if (SupabaseService.isLoggedIn) {
      try {
        await SupabaseService.upsertBg(updatedBg);
      } catch (e) {
        print('Failed to update BG in Supabase: $e');
      }
    }
  }

  Future<void> deleteBg(String id) async {
    // Delete locally
    await HiveService.deleteBg(id);

    // Delete from Supabase
    if (SupabaseService.isLoggedIn) {
      try {
        await SupabaseService.deleteBg(id);
      } catch (e) {
        print('Failed to delete BG from Supabase: $e');
      }
    }
  }

  // ========== Filtering ==========

  Future<List<BgModel>> getActiveBgs() async {
    return HiveService.getActiveBgs();
  }

  Future<List<BgModel>> getExpiredBgs() async {
    return HiveService.getExpiredBgs();
  }

  Future<List<BgModel>> getReleasedBgs() async {
    return HiveService.getReleasedBgs();
  }

  Future<List<BgModel>> getBgsExpiringWithinDays(int days) async {
    return HiveService.getBgsExpiringWithinDays(days);
  }

  Future<List<BgModel>> searchBgs(String query) async {
    return HiveService.searchBgs(query);
  }

  Future<List<BgModel>> filterByBank(String bankName) async {
    return HiveService.filterBgsByBank(bankName);
  }

  Future<List<BgModel>> filterByDiscom(String discom) async {
    return HiveService.filterBgsByDiscom(discom);
  }

  // ========== BG Extension ==========

  Future<void> extendBg(String bgId, ExtensionModel extension) async {
    final bg = HiveService.getBg(bgId);
    if (bg != null) {
      final updatedExtensions = [...bg.extensionHistory, extension];
      final updatedBg = bg.copyWith(
        extensionHistory: updatedExtensions,
        expiryDate: extension.newBgExpiryDate,
        claimExpiryDate: extension.newClaimExpiryDate,
        updatedAt: DateTime.now(),
      );
      await HiveService.updateBg(updatedBg);

      if (SupabaseService.isLoggedIn) {
        try {
          await SupabaseService.upsertBg(updatedBg);
        } catch (e) {
          print('Failed to sync extension to Supabase: $e');
        }
      }
    }
  }

  // ========== BG Release ==========

  Future<void> releaseBg(String bgId) async {
    final bg = HiveService.getBg(bgId);
    if (bg != null) {
      final updatedBg = bg.copyWith(
        status: BgStatus.released,
        updatedAt: DateTime.now(),
      );
      await HiveService.updateBg(updatedBg);

      if (SupabaseService.isLoggedIn) {
        try {
          await SupabaseService.upsertBg(updatedBg);
        } catch (e) {
          print('Failed to sync release to Supabase: $e');
        }
      }
    }
  }

  // ========== Document Operations ==========

  Future<void> addDocument(String bgId, DocumentModel document) async {
    final bg = HiveService.getBg(bgId);
    if (bg != null) {
      final updatedDocuments = [...bg.documents, document];
      final updatedBg = bg.copyWith(
        documents: updatedDocuments,
        updatedAt: DateTime.now(),
      );
      await HiveService.updateBg(updatedBg);

      if (SupabaseService.isLoggedIn) {
        try {
          await SupabaseService.upsertBg(updatedBg);
        } catch (e) {
          print('Failed to sync document to Supabase: $e');
        }
      }
    }
  }

  Future<void> removeDocument(String bgId, String documentId) async {
    final bg = HiveService.getBg(bgId);
    if (bg != null) {
      final updatedDocuments = bg.documents
          .where((d) => d.id != documentId)
          .toList();
      final updatedBg = bg.copyWith(
        documents: updatedDocuments,
        updatedAt: DateTime.now(),
      );
      await HiveService.updateBg(updatedBg);

      if (SupabaseService.isLoggedIn) {
        try {
          await SupabaseService.upsertBg(updatedBg);
        } catch (e) {
          print('Failed to sync to Supabase: $e');
        }
      }
    }
  }

  // ========== Statistics ==========

  Future<double> getTotalBgAmount() async {
    return HiveService.getTotalBgAmount();
  }

  Future<double> getTotalFdrAmount() async {
    return HiveService.getTotalFdrAmount();
  }

  Future<int> getActiveBgCount() async {
    return HiveService.getActiveBgCount();
  }

  Future<int> getExpiringBgCount(int days) async {
    return HiveService.getExpiringBgCount(days);
  }

  Future<int> getReleasedBgCount() async {
    return HiveService.getReleasedBgCount();
  }

  Future<Set<String>> getAllBankNames() async {
    return HiveService.getAllBankNames();
  }

  Future<Set<String>> getAllDiscoms() async {
    return HiveService.getAllDiscoms();
  }

  // ========== Factory Methods ==========

  BgModel createBg({
    required String bgNumber,
    required DateTime issueDate,
    required double amount,
    required DateTime expiryDate,
    required DateTime claimExpiryDate,
    required String bankName,
    required String discom,
    required String tenderNumber,
    String firmName = 'DoonInfra',
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
