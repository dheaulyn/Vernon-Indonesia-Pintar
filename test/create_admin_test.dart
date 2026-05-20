import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Create Admin User', () async {
    final client = SupabaseClient(
      'https://bfuflpeftdysoowrridc.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmdWZscGVmdGR5c29vd3JyaWRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwNzMyODEsImV4cCI6MjA5NDY0OTI4MX0.-ejrTKRPSONwmoe4fkdE4Ck5DWmXLa3Tp6sZ5MHEa7Y',
    );

    try {
      final res = await client.auth.signUp(
        email: 'admin@mail.com',
        password: 'admin',
      );
      if (res.user != null) {
        await client.from('profiles').insert({
          'id': res.user!.id,
          'email': 'admin@mail.com',
          'name': 'ADMINISTRATOR VIP',
          'role': 'admin',
          'is_registered': false,
          'current_step': 0,
          'is_revisi': false,
          'catatan_revisi': '',
          'admin_status': 'Aktif',
        });
        print('SUCCESS_ADMIN_CREATED');
      }
    } catch (e) {
      print('FAILED_CREATE_ADMIN: $e');
    }
  });
}
