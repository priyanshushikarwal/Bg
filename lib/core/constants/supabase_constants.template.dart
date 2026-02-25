// ================================================================
// SUPABASE CONFIGURATION TEMPLATE
// ================================================================
// 1. Copy this file and rename it to: supabase_constants.dart
// 2. Fill in your Supabase project URL and anon key
// 3. Get these from: Supabase Dashboard -> Settings -> API
// ================================================================

class SupabaseConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  // Example: 'https://xyzcompany.supabase.co'

  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  // Example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'

  // Table names
  static const String bgTable = 'bank_guarantees';
  static const String extensionsTable = 'bg_extensions';
  static const String documentsTable = 'bg_documents';
  static const String fdrTable = 'fdr_details';
}
