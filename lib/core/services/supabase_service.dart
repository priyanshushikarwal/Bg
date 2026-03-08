import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/supabase_constants.dart';
import '../../data/models/bg_model.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    final cleanUrl = SupabaseConstants.supabaseUrl.endsWith('/')
        ? SupabaseConstants.supabaseUrl.substring(
            0,
            SupabaseConstants.supabaseUrl.length - 1,
          )
        : SupabaseConstants.supabaseUrl;

    await Supabase.initialize(
      url: cleanUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
    );
  }

  static Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        final errorString = e.toString().toLowerCase();

        if (errorString.contains('failed to fetch') ||
            errorString.contains('xmlhttprequest') ||
            errorString.contains('cors') ||
            errorString.contains('525') ||
            errorString.contains('handshake') ||
            errorString.contains('socket') ||
            errorString.contains('timeout')) {
          if (attempts >= maxAttempts) rethrow;

          await Future.delayed(Duration(seconds: 1 << (attempts - 1)));
          debugPrint(
            '🔄 Retrying Supabase query (Attempt $attempts) due to Network/CORS drop...',
          );
        } else {
          rethrow;
        }
      }
    }
    throw Exception('Max retries reached');
  }

  static User? get currentUser => client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _withRetry(
      () => client.auth.signInWithPassword(email: email, password: password),
    );
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _withRetry(
      () => client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      ),
    );
  }

  static Future<void> signOut() async {
    await _withRetry(() => client.auth.signOut());
  }

  static Future<void> resetPassword(String email) async {
    await _withRetry(() => client.auth.resetPasswordForEmail(email));
  }

  static Future<void> upsertBg(BgModel bg) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    debugPrint('=== SUPABASE UPSERT START ===');
    debugPrint('User ID: $userId');
    debugPrint('BG ID: ${bg.id}');
    debugPrint('BG Number: ${bg.bgNumber}');

    final data = _bgToMap(bg, userId);
    debugPrint('Data map: $data');

    try {
      await _withRetry(
        () => client.from(SupabaseConstants.bgTable).upsert(data),
      );
      debugPrint('✅ BG upserted successfully!');
    } catch (e) {
      debugPrint('❌ BG upsert FAILED: $e');
      rethrow;
    }

    if (bg.extensionHistory.isNotEmpty) {
      try {
        await _withRetry(
          () => client
              .from(SupabaseConstants.extensionsTable)
              .delete()
              .eq('bg_id', bg.id),
        );

        final extensions = bg.extensionHistory
            .map(
              (ext) => {
                'id': ext.id,
                'bg_id': bg.id,
                'user_id': userId,
                'extension_date': ext.extensionDate.toIso8601String(),
                'new_bg_expiry_date': ext.newBgExpiryDate.toIso8601String(),
                'new_claim_expiry_date': ext.newClaimExpiryDate
                    .toIso8601String(),
                'remarks': ext.remarks,
                'document_id': ext.documentId,
              },
            )
            .toList();

        if (extensions.isNotEmpty) {
          await _withRetry(
            () => client
                .from(SupabaseConstants.extensionsTable)
                .upsert(extensions),
          );
          debugPrint('✅ ${extensions.length} extensions synced!');
        }
      } catch (e) {
        debugPrint('❌ Extensions sync FAILED: $e');
      }
    }

    if (bg.fdrDetails != null) {
      try {
        await _withRetry(
          () => client.from(SupabaseConstants.fdrTable).upsert({
            'id': bg.fdrDetails!.id,
            'bg_id': bg.id,
            'user_id': userId,
            'fdr_number': bg.fdrDetails!.fdrNumber,
            'fdr_date': bg.fdrDetails!.fdrDate.toIso8601String(),
            'fdr_amount': bg.fdrDetails!.fdrAmount,
            'roi': bg.fdrDetails!.roi,
            'bank_name': bg.fdrDetails!.bankName ?? '',
            'maturity_date': bg.fdrDetails!.maturityDate?.toIso8601String(),
          }),
        );
        debugPrint('✅ FDR synced!');
      } catch (e) {
        debugPrint('❌ FDR sync FAILED: $e');
        rethrow;
      }
    }

    if (bg.documents.isNotEmpty) {
      try {
        await _withRetry(
          () => client
              .from(SupabaseConstants.documentsTable)
              .delete()
              .eq('bg_id', bg.id),
        );

        final docs = bg.documents
            .map(
              (doc) => {
                'id': doc.id,
                'bg_id': bg.id,
                'user_id': userId,
                'type': doc.type.index,
                'version': doc.version,
                'upload_date': doc.uploadDate.toIso8601String(),
                'file_path': doc.filePath,
                'file_name': doc.fileName,
                'description': doc.description,
                'file_size_bytes': doc.fileSizeBytes,
                'storage_path': doc.storagePath,
              },
            )
            .toList();

        if (docs.isNotEmpty) {
          await _withRetry(
            () => client.from(SupabaseConstants.documentsTable).upsert(docs),
          );
          debugPrint('✅ ${docs.length} documents synced!');
        }
      } catch (e) {
        debugPrint('❌ Documents sync FAILED: $e');
        rethrow;
      }
    }

    debugPrint('=== SUPABASE UPSERT END ===');
  }

  static Future<List<BgModel>> fetchAllBgs() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    debugPrint('=== SUPABASE FETCH START ===');
    debugPrint('Fetching BGs for user: $userId');

    final bgsData = await _withRetry(
      () => client
          .from(SupabaseConstants.bgTable)
          .select()
          .order('created_at', ascending: false),
    );

    debugPrint('Fetched ${bgsData.length} BGs from Supabase');

    if (bgsData.isEmpty) return [];

    final bgIds = bgsData.map((b) => b['id'] as String).toList();

    final extensionsData = await _withRetry(
      () => client
          .from(SupabaseConstants.extensionsTable)
          .select()
          .inFilter('bg_id', bgIds),
    );

    final fdrData = await _withRetry(
      () => client
          .from(SupabaseConstants.fdrTable)
          .select()
          .inFilter('bg_id', bgIds),
    );

    List<Map<String, dynamic>> docsData = [];
    try {
      docsData = await _withRetry(
        () => client
            .from(SupabaseConstants.documentsTable)
            .select()
            .inFilter('bg_id', bgIds),
      );
      debugPrint('Fetched ${docsData.length} documents from Supabase');
    } catch (e) {
      debugPrint('⚠️ Documents fetch failed (table may not exist): $e');
    }

    final docsByBgId = <String, List<Map<String, dynamic>>>{};
    for (var docStr in docsData) {
      final String idStr = docStr['bg_id'] as String;
      docsByBgId.putIfAbsent(idStr, () => []).add(docStr);
    }

    return bgsData.map((bgMap) {
      final bgId = bgMap['id'] as String;

      final bgExtensions = extensionsData
          .where((e) => e['bg_id'] == bgId)
          .map(
            (e) => ExtensionModel(
              id: e['id'],
              extensionDate: DateTime.parse(e['extension_date']),
              newBgExpiryDate: DateTime.parse(e['new_bg_expiry_date']),
              newClaimExpiryDate: DateTime.parse(e['new_claim_expiry_date']),
              remarks: e['remarks'],
              documentId: e['document_id'],
            ),
          )
          .toList();

      final fdrMap = fdrData.where((f) => f['bg_id'] == bgId).firstOrNull;
      FdrModel? fdrModel;
      if (fdrMap != null) {
        fdrModel = FdrModel(
          id: fdrMap['id'],
          fdrNumber: fdrMap['fdr_number'],
          fdrDate: DateTime.parse(fdrMap['fdr_date']),
          fdrAmount: (fdrMap['fdr_amount'] as num).toDouble(),
          roi: (fdrMap['roi'] as num).toDouble(),
          bankName: fdrMap['bank_name'],
          maturityDate: fdrMap['maturity_date'] != null
              ? DateTime.parse(fdrMap['maturity_date'])
              : null,
        );
      }

      final bgDocsRaw = docsData.where((d) => d['bg_id'] == bgId).toList();
      final List<DocumentModel> bgDocs = [];
      for (final d in bgDocsRaw) {
        try {
          bgDocs.add(
            DocumentModel(
              id: d['id'],
              type: DocumentType.values[d['type'] as int],
              version: d['version'] ?? 1,
              uploadDate: DateTime.parse(d['upload_date']),
              filePath: d['file_path'] ?? '',
              fileName: d['file_name'] ?? 'document',
              description: d['description'],
              fileSizeBytes: d['file_size_bytes'],
              storagePath: d['storage_path'],
            ),
          );
        } catch (e) {
          debugPrint('⚠️ Skipping bad document record: $e');
        }
      }

      return BgModel(
        id: bgId,
        bgNumber: bgMap['bg_number'],
        issueDate: DateTime.parse(bgMap['issue_date']),
        amount: (bgMap['amount'] as num).toDouble(),
        expiryDate: DateTime.parse(bgMap['expiry_date']),
        claimExpiryDate: DateTime.parse(bgMap['claim_expiry_date']),
        bankName: bgMap['bank_name'],
        discom: bgMap['discom'],
        tenderNumber: bgMap['tender_number'],
        status: BgStatus.values[bgMap['status'] as int],
        extensionHistory: bgExtensions,
        documents: bgDocs,
        fdrDetails: fdrModel,
        createdAt: DateTime.parse(bgMap['created_at']),
        updatedAt: DateTime.parse(bgMap['updated_at']),
        firmName: _mapLegacyFirmName(bgMap['firm_name'] ?? 'Doon Infrapower Projects Pvt Ltd'),
      );
    }).toList();
  }

  static String _mapLegacyFirmName(String name) {
    switch (name) {
      case 'DoonInfra':
        return 'Doon Infrapower Projects Pvt Ltd';
      case 'BI High Power Tech':
        return 'B Hi Tech Power Transformer';
      case 'BI':
        return 'Doon Electrical Industries';
      default:
        return name;
    }
  }

  static Future<void> deleteBg(String bgId) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _withRetry(
      () => client
          .from(SupabaseConstants.documentsTable)
          .delete()
          .eq('bg_id', bgId),
    );

    await _withRetry(
      () => client
          .from(SupabaseConstants.extensionsTable)
          .delete()
          .eq('bg_id', bgId),
    );

    await _withRetry(
      () => client.from(SupabaseConstants.fdrTable).delete().eq('bg_id', bgId),
    );

    await _withRetry(
      () => client.from(SupabaseConstants.bgTable).delete().eq('id', bgId),
    );
  }

  static Map<String, dynamic> _bgToMap(BgModel bg, String userId) {
    return {
      'id': bg.id,
      'user_id': userId,
      'bg_number': bg.bgNumber,
      'issue_date': bg.issueDate.toIso8601String(),
      'amount': bg.amount,
      'expiry_date': bg.expiryDate.toIso8601String(),
      'claim_expiry_date': bg.claimExpiryDate.toIso8601String(),
      'bank_name': bg.bankName,
      'discom': bg.discom,
      'tender_number': bg.tenderNumber,
      'status': bg.status.index,
      'firm_name': bg.firmName,
      'created_at': bg.createdAt.toIso8601String(),
      'updated_at': bg.updatedAt.toIso8601String(),
    };
  }

  // ─── Firms Sync ───

  /// Fetch all firms from Supabase for the current user.
  static Future<List<Map<String, dynamic>>> fetchFirms() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await _withRetry(
        () => client
            .from(SupabaseConstants.firmsTable)
            .select()
            .eq('user_id', userId)
            .order('created_at'),
      );
      debugPrint('Fetched ${data.length} firms from Supabase');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Firms fetch failed: $e');
      return [];
    }
  }

  /// Upsert (add or update) a firm in Supabase.
  static Future<void> upsertFirm({
    required String name,
    String address = '',
    String email = '',
    String mobile = '',
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    try {
      await _withRetry(
        () => client.from(SupabaseConstants.firmsTable).upsert(
          {
            'user_id': userId,
            'name': name,
            'address': address,
            'email': email,
            'mobile': mobile,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'user_id,name',
        ),
      );
      debugPrint('✅ Firm "$name" upserted to Supabase');
    } catch (e) {
      debugPrint('⚠️ Firm upsert failed: $e');
    }
  }

  /// Delete a firm from Supabase.
  static Future<void> deleteFirm(String name) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    try {
      await _withRetry(
        () => client
            .from(SupabaseConstants.firmsTable)
            .delete()
            .eq('user_id', userId)
            .eq('name', name),
      );
      debugPrint('✅ Firm "$name" deleted from Supabase');
    } catch (e) {
      debugPrint('⚠️ Firm delete from Supabase failed: $e');
    }
  }

  /// Push all local firms to Supabase (bulk sync).
  static Future<void> syncFirmsToSupabase(
      List<Map<String, String>> firms) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    for (final firm in firms) {
      await upsertFirm(
        name: firm['name'] ?? '',
        address: firm['address'] ?? '',
        email: firm['email'] ?? '',
        mobile: firm['mobile'] ?? '',
      );
    }
    debugPrint('✅ All ${firms.length} firms synced to Supabase');
  }

  // ─── Document Storage ───

  static const String _storageBucket = 'bg-documents';

  /// Upload a document file to Supabase Storage.
  /// Returns the storage path on success, null on failure.
  static Future<String?> uploadDocumentFile({
    required String bgId,
    required String docId,
    required String localFilePath,
    required String fileName,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    try {
      final file = File(localFilePath);
      if (!await file.exists()) {
        debugPrint('⚠️ File does not exist: $localFilePath');
        return null;
      }

      final ext = fileName.split('.').last.toLowerCase();
      final storagePath = '$userId/$bgId/$docId.$ext';
      final bytes = await file.readAsBytes();

      await client.storage.from(_storageBucket).uploadBinary(
        storagePath,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: _getContentType(ext),
        ),
      );

      debugPrint('✅ Document uploaded to storage: $storagePath');
      return storagePath;
    } catch (e) {
      debugPrint('⚠️ Document upload to storage failed: $e');
      throw Exception('Failed to upload document to cloud storage: $e');
    }
  }

  /// Download a document from Supabase Storage to local temp.
  /// Returns the local file path on success, null on failure.
  static Future<String?> downloadDocumentFile({
    required String storagePath,
    required String fileName,
  }) async {
    try {
      final bytes = await client.storage
          .from(_storageBucket)
          .download(storagePath);

      final docsDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${docsDir.path}${Platform.pathSeparator}BgManagerDocs');
      if (!downloadDir.existsSync()) {
        downloadDir.createSync(recursive: true);
      }

      final localPath = '${downloadDir.path}${Platform.pathSeparator}$fileName';
      final file = File(localPath);
      await file.writeAsBytes(bytes);

      debugPrint('✅ Document downloaded to: $localPath');
      return localPath;
    } catch (e) {
      debugPrint('⚠️ Document download failed: $e');
      return null;
    }
  }

  static String _getContentType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
