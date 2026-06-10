import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://pxflpbigxzdwvrhlqlkj.supabase.co';
  static const String supabaseKey =
      'sb_publishable_9_VegcIK9xnwZ1JYygvmKQ_TaqEws1C';

  static Future<void> initialize() async {
    // ignore: deprecated_member_use
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  }

  static SupabaseClient get client {
    return Supabase.instance.client;
  }
}
