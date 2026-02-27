// ================================================================
// SUPABASE CONFIGURATION
// ================================================================
// Yahan apna Supabase project URL aur anon key daalna hai.
// Supabase dashboard -> Settings -> API se milega
// ================================================================

class SupabaseConstants {
  // 🔴 IMPORTANT: Apna Supabase URL aur Anon Key yahan daalo
  // Example: 'https://xyzcompany.supabase.co'
  static const String supabaseUrl = 'https://qsnlvvzdzuzkqgisnqre.supabase.co';

  // Example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzbmx2dnpkenV6a3FnaXNucXJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMzY0NzMsImV4cCI6MjA4NzcxMjQ3M30.5GEAVrz-TuYROkLZfr8FPcZ_u0AxnJnPsR5Ah0EdZzM';

  // Table names
  static const String bgTable = 'bank_guarantees';
  static const String extensionsTable = 'bg_extensions';
  static const String documentsTable = 'bg_documents';
  static const String fdrTable = 'fdr_details';
}
