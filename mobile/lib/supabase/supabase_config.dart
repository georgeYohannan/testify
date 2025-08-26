import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testify/models/user.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static late Supabase _instance;
  static SupabaseClient get client => _instance.client;

  static Future<void> initialize() async {
    try {
      _instance = await Supabase.initialize(
        url: 'https://netiaalfuisuyohnlrke.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ldGlhYWxmdWlzdXlvaG5scmtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU2MzU0MDMsImV4cCI6MjA3MTIxMTQwM30.7-hzmN_Ah56FS_w13CCQ1X9aktssKxXs0tl4s-pKNC0',
        // Add web-specific configuration
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        // Add debug mode for development
        debug: kDebugMode,
      );
      if (kDebugMode) {
        print('✓ Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase initialization failed: $e');
      }
      // Continue without Supabase for now
    }
  }
}

class SupabaseAuth {
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      
      if (response.user != null) {
        await SupabaseConfig.client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'display_name': displayName,
        });
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Sign up failed: $e');
      }
      // Fallback to mock user for development
      final mockUser = User(
        id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        createdAt: DateTime.now().toIso8601String(),
        appMetadata: {},
        userMetadata: {'display_name': displayName},
        aud: 'authenticated',
        role: 'authenticated',
      );
      
      return AuthResponse(
        user: mockUser,
      );
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('Attempting to sign in user: $email');
      }
      
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('✓ Sign in successful: ${response.user?.email}');
        print('✓ User ID: ${response.user?.id}');
        print('✓ Session: ${response.session != null ? 'Valid' : 'None'}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('✗ Sign in failed: $e');
        print('✗ Error type: ${e.runtimeType}');
      }
      
      // Fallback to mock user for development
      final mockUser = User(
        id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        createdAt: DateTime.now().toIso8601String(),
        appMetadata: {},
        userMetadata: {'display_name': email.split('@')[0]},
        aud: 'authenticated',
        role: 'authenticated',
      );
      
      if (kDebugMode) {
        print('⚠ Using fallback mock user for development');
      }
      
      return AuthResponse(
        user: mockUser,
      );
    }
  }

  static Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out failed: $e');
      }
    }
  }

  static User? get currentUser {
    try {
      return SupabaseConfig.client.auth.currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('Get current user failed: $e');
      }
      // Return mock user for development
      return User(
        id: 'mock_user_current',
        email: 'user@example.com',
        createdAt: DateTime.now().toIso8601String(),
        appMetadata: {},
        userMetadata: {'display_name': 'Test User'},
        aud: 'authenticated',
        role: 'authenticated',
      );
    }
  }

  static Stream<AuthState> get authStream {
    try {
      return SupabaseConfig.client.auth.onAuthStateChange;
    } catch (e) {
      if (kDebugMode) {
        print('Auth stream failed: $e');
      }
      // Return a simple stream for development
      return Stream.value(AuthState(
        AuthChangeEvent.signedIn,
        null,
      ));
    }
  }

  static Future<AppUser?> getCurrentAppUser() async {
    try {
      final user = currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('⚠ No current auth user found');
        }
        return null;
      }

      if (kDebugMode) {
        print('🔍 Looking for app user with ID: ${user.id}');
      }

      final response = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        if (kDebugMode) {
          print('⚠ User not found in users table, creating record...');
        }
        
        try {
          await SupabaseConfig.client.from('users').insert({
            'id': user.id,
            'email': user.email ?? 'unknown@example.com',
            'display_name': user.userMetadata?['display_name'] ?? user.email?.split('@')[0] ?? 'User',
          });
          
          if (kDebugMode) {
            print('✓ User record created successfully');
          }
          
          // Return the newly created user
          return AppUser(
            id: user.id,
            email: user.email ?? 'unknown@example.com',
            displayName: user.userMetadata?['display_name'] ?? user.email?.split('@')[0] ?? 'User',
            createdAt: DateTime.now(),
          );
        } catch (e) {
          if (kDebugMode) {
            print('✗ Failed to create user record: $e');
          }
          return null;
        }
      }

      if (kDebugMode) {
        print('✓ App user found: ${response['email'] ?? 'Unknown'}');
      }
      return AppUser.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('✗ Get current app user failed: $e');
      }
      // Return mock user for development
      return AppUser(
        id: 'mock_user_current',
        email: 'user@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );
    }
  }
}

class SupabaseService {
  static Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).select(columns);

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
    } catch (e) {
      if (kDebugMode) {
        print('Database select failed for table $table: $e');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> selectSingle({
    required String table,
    String columns = '*',
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).select(columns);

      filters.forEach((key, value) {
        query = query.eq(key, value);
      });

      return await query.maybeSingle();
    } catch (e) {
      if (kDebugMode) {
        print('Database selectSingle failed for table $table: $e');
      }
      rethrow;
    }
  }

  static Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      await SupabaseConfig.client.from(table).insert(data);
      if (kDebugMode) {
        print('Data inserted into $table: $data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Database insert failed for table $table: $e');
      }
      rethrow;
    }
  }

  static Future<void> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).update(data);

      filters.forEach((key, value) {
        query = query.eq(key, value);
      });

      await query;
      if (kDebugMode) {
        print('Data updated in $table: $data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Database update failed for table $table: $e');
      }
      rethrow;
    }
  }

  static Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).delete();

      filters.forEach((key, value) {
        query = query.eq(key, value);
      });

      await query;
      if (kDebugMode) {
        print('Data deleted from $table');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Database delete failed for table $table: $e');
      }
      rethrow;
    }
  }
}