import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word__way/models/user.dart';

class SupabaseConfig {
  static late Supabase _instance;
  static SupabaseClient get client => _instance.client;

  static Future<void> initialize() async {
    _instance = await Supabase.initialize(
      url: 'SUPABASE_URL',
      anonKey: 'SUPABASE_ANON_KEY',
    );
  }
}

class SupabaseAuth {
  static final SupabaseClient _client = SupabaseConfig.client;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );
    
    if (response.user != null) {
      await _client.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'display_name': displayName,
      });
    }
    
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStream => _client.auth.onAuthStateChange;

  static Future<AppUser?> getCurrentAppUser() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return AppUser.fromJson(response);
  }
}

class SupabaseService {
  static final SupabaseClient _client = SupabaseConfig.client;

  static Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    dynamic query = _client.from(table).select(columns);

    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return await query;
  }

  static Future<Map<String, dynamic>?> selectSingle({
    required String table,
    String columns = '*',
    required Map<String, dynamic> filters,
  }) async {
    dynamic query = _client.from(table).select(columns);

    filters.forEach((key, value) {
      query = query.eq(key, value);
    });

    return await query.maybeSingle();
  }

  static Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    await _client.from(table).insert(data);
  }

  static Future<void> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
  }) async {
    dynamic query = _client.from(table).update(data);

    filters.forEach((key, value) {
      query = query.eq(key, value);
    });

    await query;
  }

  static Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  }) async {
    dynamic query = _client.from(table).delete();

    filters.forEach((key, value) {
      query = query.eq(key, value);
    });

    await query;
  }
}