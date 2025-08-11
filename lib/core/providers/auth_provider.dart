import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'api_client_provider.dart';
import '../services/api_client.dart';

part 'auth_provider.g.dart';

/// Authentication state management with real API integration
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Check for stored authentication on app start
    _checkStoredAuth();
    
    return const AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
      error: null,
    );
  }

  /// Check for stored authentication token/data
  Future<void> _checkStoredAuth() async {
    // TODO: Implement secure storage check
    // For now, start as unauthenticated
    // In production, check SharedPreferences/SecureStorage for stored token
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    // Set loading state
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
    );

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.login(email, password);

      // Extract user data from API response
      final userData = response['user'] as Map<String, dynamic>?;
      final token = response['token'] as String?;

      if (userData != null && token != null) {
        final user = User.fromJson(userData);

        // Update state with authenticated user
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          error: null,
        );

        // TODO: Store token securely for persistence
        // await _storeAuthToken(token);
      } else {
        throw const ApiException('Invalid response from server');
      }
    } catch (e) {
      // Handle authentication error
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: e is ApiException ? e.message : 'Sign in failed: $e',
      );
    }
  }

  /// Sign up with email and password
  Future<void> signUp(String email, String password) async {
    // Set loading state
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
    );

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.register(email, password);

      // After successful registration, automatically sign in
      await signIn(email, password);
    } catch (e) {
      // Handle registration error
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: e is ApiException ? e.message : 'Sign up failed: $e',
      );
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      // Clear authentication state
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
      );

      // TODO: Clear stored token
      // await _clearStoredAuth();
    }
  }

  /// Clear any authentication errors
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state.status == AuthStatus.authenticated;

  /// Get current user (null if not authenticated)
  User? get currentUser => state.user;
}

/// Authentication state data class
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    required this.status,
    required this.user,
    required this.error,
  });

  /// Create a copy of this state with modified fields
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}

/// Authentication status enumeration
enum AuthStatus {
  loading,
  authenticated,
  unauthenticated,
}

/// User data model
class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Create User from JSON response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Get user display name (name or email)
  String get displayName => name ?? email;

  /// Get user initials for avatar
  String get initials {
    final displayText = displayName;
    if (displayText.isEmpty) return 'U';
    
    final words = displayText.split(' ');
    if (words.length == 1) {
      return displayText.substring(0, 1).toUpperCase();
    } else {
      return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
    }
  }

  @override
  List<Object?> get props => [id, email, name, createdAt, lastLoginAt];
}

/// Authentication state selector providers for optimized rebuilds
@riverpod
AuthStatus authStatus(Ref ref) {
  return ref.watch(authNotifierProvider.select((state) => state.status));
}

@riverpod
User? currentUser(Ref ref) {
  return ref.watch(authNotifierProvider.select((state) => state.user));
}

@riverpod
String? authError(Ref ref) {
  return ref.watch(authNotifierProvider.select((state) => state.error));
}

@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authNotifierProvider.select((state) => state.status == AuthStatus.authenticated));
}

@riverpod
bool isLoading(Ref ref) {
  return ref.watch(authNotifierProvider.select((state) => state.status == AuthStatus.loading));
}
