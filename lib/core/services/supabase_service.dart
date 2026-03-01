import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import '../../data/models/bg_model.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // ===== INITIALIZATION =====
  static Future<void> init() async {
    // Ensure the URL does NOT have a trailing slash
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

  // ===== HELPER: EXPONENTIAL BACKOFF FOR FLUTTER WEB / CLOUDFLARE 525 =====
  static Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        final errorString = e.toString().toLowerCase();

        // If it's a network, fetch, or generic CORS/SSL failure
        if (errorString.contains('failed to fetch') ||
            errorString.contains('xmlhttprequest') ||
            errorString.contains('cors') ||
            errorString.contains('525') ||
            errorString.contains('handshake') ||
            errorString.contains('socket') ||
            errorString.contains('timeout')) {
          if (attempts >= maxAttempts) rethrow;

          // Exponential backoff: 1s, 2s, 4s...
          await Future.delayed(Duration(seconds: 1 << (attempts - 1)));
          debugPrint(
            '🔄 Retrying Supabase query (Attempt $attempts) due to Network/CORS drop...',
          );
        } else {
          rethrow; // Legitimate error (e.g. RLS validation)
        }
      }
    }
    throw Exception('Max retries reached');
  }

  // ===== AUTH METHODS =====

  static User? get currentUser => client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  /// Email/Password se sign in
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _withRetry(
      () => client.auth.signInWithPassword(email: email, password: password),
    );
  }

  /// Naya account banao
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

  /// Sign out
  static Future<void> signOut() async {
    await _withRetry(() => client.auth.signOut());
  }

  /// Password reset email
  static Future<void> resetPassword(String email) async {
    await _withRetry(() => client.auth.resetPasswordForEmail(email));
  }

  // ===== BG DATABASE METHODS =====

  /// Supabase me saara BG data daalo (user ke liye)
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

    // Extensions sync karo
    if (bg.extensionHistory.isNotEmpty) {
      try {
        // Pehle purane extensions delete karo
        await _withRetry(
          () => client
              .from(SupabaseConstants.extensionsTable)
              .delete()
              .eq('bg_id', bg.id),
        );

        // Naye extensions insert karo
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

    // FDR details sync karo
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

    // Documents sync karo
    if (bg.documents.isNotEmpty) {
      try {
        // Pehle purane documents delete karo
        await _withRetry(
          () => client
              .from(SupabaseConstants.documentsTable)
              .delete()
              .eq('bg_id', bg.id),
        );

        // Naye documents insert karo
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
              },
            )
            .toList();

        if (docs.isNotEmpty) {
          await _withRetry(
            () => client
                .from(SupabaseConstants.documentsTable)
                .upsert(docs),
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

  /// Supabase se saare BGs fetch karo (current user ke)
  static Future<List<BgModel>> fetchAllBgs() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    debugPrint('=== SUPABASE FETCH START ===');
    debugPrint('Fetching BGs for user: $userId');

    // BGs fetch karo
    final bgsData = await _withRetry(
      () => client
          .from(SupabaseConstants.bgTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false),
    );

    debugPrint('Fetched ${bgsData.length} BGs from Supabase');

    if (bgsData.isEmpty) return [];

    final bgIds = bgsData.map((b) => b['id'] as String).toList();

    // Extensions fetch karo
    final extensionsData = await _withRetry(
      () => client
          .from(SupabaseConstants.extensionsTable)
          .select()
          .inFilter('bg_id', bgIds),
    );

    // FDR details fetch karo
    final fdrData = await _withRetry(
      () => client
          .from(SupabaseConstants.fdrTable)
          .select()
          .inFilter('bg_id', bgIds),
    );

    // Documents fetch karo
    final docsData = await _withRetry(
      () => client
          .from(SupabaseConstants.documentsTable)
          .select()
          .inFilter('bg_id', bgIds),
    );

    // Model mein convert karo
    return bgsData.map((bgMap) {
      final bgId = bgMap['id'] as String;

      // Extensions
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

      // FDR
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

      // Documents
      final bgDocs = docsData
          .where((d) => d['bg_id'] == bgId)
          .map(
            (d) => DocumentModel(
              id: d['id'],
              type: DocumentType.values[d['type'] as int],
              version: d['version'] ?? 1,
              uploadDate: DateTime.parse(d['upload_date']),
              filePath: d['file_path'] ?? '',
              fileName: d['file_name'] ?? 'document',
              description: d['description'],
              fileSizeBytes: d['file_size_bytes'],
            ),
          )
          .toList();

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
        firmName: bgMap['firm_name'] ?? 'DoonInfra',
      );
    }).toList();
  }

  /// Supabase se BG delete karo
  static Future<void> deleteBg(String bgId) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    // Documents delete
    await _withRetry(
      () => client
          .from(SupabaseConstants.documentsTable)
          .delete()
          .eq('bg_id', bgId),
    );

    // Extensions delete
    await _withRetry(
      () => client
          .from(SupabaseConstants.extensionsTable)
          .delete()
          .eq('bg_id', bgId),
    );

    // FDR delete
    await _withRetry(
      () => client.from(SupabaseConstants.fdrTable).delete().eq('bg_id', bgId),
    );

    // BG delete
    await _withRetry(
      () => client
          .from(SupabaseConstants.bgTable)
          .delete()
          .eq('id', bgId)
          .eq('user_id', userId),
    );
  }

  // ===== HELPER METHODS =====

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
}
