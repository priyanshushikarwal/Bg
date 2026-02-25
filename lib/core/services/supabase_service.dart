import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import '../../data/models/bg_model.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // ===== INITIALIZATION =====
  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
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
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Naya account banao
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Password reset email
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // ===== BG DATABASE METHODS =====

  /// Supabase me saara BG data daalo (user ke liye)
  static Future<void> upsertBg(BgModel bg) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final data = _bgToMap(bg, userId);

    await client.from(SupabaseConstants.bgTable).upsert(data);

    // Extensions sync karo
    if (bg.extensionHistory.isNotEmpty) {
      // Pehle purane extensions delete karo
      await client
          .from(SupabaseConstants.extensionsTable)
          .delete()
          .eq('bg_id', bg.id);

      // Naye extensions insert karo
      final extensions = bg.extensionHistory
          .map(
            (ext) => {
              'id': ext.id,
              'bg_id': bg.id,
              'user_id': userId,
              'extension_date': ext.extensionDate.toIso8601String(),
              'new_bg_expiry_date': ext.newBgExpiryDate.toIso8601String(),
              'new_claim_expiry_date': ext.newClaimExpiryDate.toIso8601String(),
              'remarks': ext.remarks,
              'document_id': ext.documentId,
            },
          )
          .toList();

      if (extensions.isNotEmpty) {
        await client.from(SupabaseConstants.extensionsTable).upsert(extensions);
      }
    }

    // FDR details sync karo
    if (bg.fdrDetails != null) {
      await client.from(SupabaseConstants.fdrTable).upsert({
        'id': bg.fdrDetails!.id,
        'bg_id': bg.id,
        'user_id': userId,
        'fdr_number': bg.fdrDetails!.fdrNumber,
        'fdr_date': bg.fdrDetails!.fdrDate.toIso8601String(),
        'fdr_amount': bg.fdrDetails!.fdrAmount,
        'roi': bg.fdrDetails!.roi,
        'bank_name': bg.fdrDetails!.bankName,
        'maturity_date': bg.fdrDetails!.maturityDate?.toIso8601String(),
      });
    }
  }

  /// Supabase se saare BGs fetch karo (current user ke)
  static Future<List<BgModel>> fetchAllBgs() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    // BGs fetch karo
    final bgsData = await client
        .from(SupabaseConstants.bgTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (bgsData.isEmpty) return [];

    final bgIds = bgsData.map((b) => b['id'] as String).toList();

    // Extensions fetch karo
    final extensionsData = await client
        .from(SupabaseConstants.extensionsTable)
        .select()
        .inFilter('bg_id', bgIds);

    // FDR details fetch karo
    final fdrData = await client
        .from(SupabaseConstants.fdrTable)
        .select()
        .inFilter('bg_id', bgIds);

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
        documents: [],
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

    // Extensions delete
    await client
        .from(SupabaseConstants.extensionsTable)
        .delete()
        .eq('bg_id', bgId);

    // FDR delete
    await client.from(SupabaseConstants.fdrTable).delete().eq('bg_id', bgId);

    // BG delete
    await client
        .from(SupabaseConstants.bgTable)
        .delete()
        .eq('id', bgId)
        .eq('user_id', userId);
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
