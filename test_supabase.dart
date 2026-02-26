import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const supabaseUrl = 'https://qjotmdeebfwwcubapogd.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqb3RtZGVlYmZ3d2N1YmFwb2dkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwNDQzMjksImV4cCI6MjA4NzYyMDMyOX0.UGgYyQyVwIzxYtFRW_mfc8kBW9Smy9wGJkPevMxMuAE';

  const userId = 'cffa5da0-94e8-4539-a52e-5ef2555a2441';

  // Test 1: Read with anon key only (no user auth)
  print('Test 1: Read with anon key (no auth)...');
  var res = await http.get(
    Uri.parse(
      '$supabaseUrl/rest/v1/bank_guarantees?select=id,bg_number,user_id',
    ),
    headers: {
      'apikey': supabaseAnonKey,
      'Authorization': 'Bearer $supabaseAnonKey',
    },
  );
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');

  // Test 2: Read with user_id filter
  print('\nTest 2: Read with user_id filter...');
  res = await http.get(
    Uri.parse(
      '$supabaseUrl/rest/v1/bank_guarantees?select=id,bg_number,user_id&user_id=eq.$userId',
    ),
    headers: {
      'apikey': supabaseAnonKey,
      'Authorization': 'Bearer $supabaseAnonKey',
    },
  );
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');

  // Test 3: Sign in as the ACTUAL user and try to read
  print('\nTest 3: Checking if we can get session...');
  // We need to know the email/password to get a proper token
  // Let's check what user_id is in the inserted row
  print('Looking for rows with user_id = $userId...');

  // Test 4: Try with service role key? No, we only have anon key.
  // Let's just check if the row exists at all
  print('\nTest 4: Read ALL rows (no filter)...');
  res = await http.get(
    Uri.parse(
      '$supabaseUrl/rest/v1/bank_guarantees?select=id,bg_number,user_id',
    ),
    headers: {
      'apikey': supabaseAnonKey,
      'Authorization': 'Bearer $supabaseAnonKey',
    },
  );
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');

  // Now clean up
  print('\nCleanup: Deleting test row...');
  res = await http.delete(
    Uri.parse(
      '$supabaseUrl/rest/v1/bank_guarantees?id=eq.b2c3d4e5-f6a7-8901-bcde-f12345678901',
    ),
    headers: {
      'apikey': supabaseAnonKey,
      'Authorization': 'Bearer $supabaseAnonKey',
    },
  );
  print('Delete status: ${res.statusCode}');
}
