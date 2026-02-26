// ================================================================
// SUPABASE CONFIGURATION
// ================================================================
// Yahan apna Supabase project URL aur anon key daalna hai.
// Supabase dashboard -> Settings -> API se milega
// ================================================================

class SupabaseConstants {
  // 🔴 IMPORTANT: Apna Supabase URL aur Anon Key yahan daalo
  // Example: 'https://xyzcompany.supabase.co'
  static const String supabaseUrl = 'https://qjotmdeebfwwcubapogd.supabase.co';

  // Example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqb3RtZGVlYmZ3d2N1YmFwb2dkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwNDQzMjksImV4cCI6MjA4NzYyMDMyOX0.UGgYyQyVwIzxYtFRW_mfc8kBW9Smy9wGJkPevMxMuAE';

  // Table names
  static const String bgTable = 'bank_guarantees';
  static const String extensionsTable = 'bg_extensions';
  static const String documentsTable = 'bg_documents';
  static const String fdrTable = 'fdr_details';
}
