import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// API Client for LinguaSigna Backend Integration
/// Connects Flutter frontend to validated backend systems
class ApiClient {
  static const String _baseUrl = 'http://localhost:3000';
  static const String _mlBaseUrl = 'http://localhost:5000';
  
  final http.Client _httpClient;
  String? _authToken;
  
  ApiClient({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();
  
  /// Set authentication token for API requests
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }
  
  /// Get headers with authentication
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  /// Handle HTTP response and errors
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException('Failed to parse response: $e');
      }
    } else {
      throw ApiException(
        'API Error ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }
  
  // ============================================================================
  // AUTHENTICATION API CALLS
  // ============================================================================
  
  /// Login user with email and password
  /// Returns user data and authentication token
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final result = _handleResponse(response);
      
      // Store auth token if provided
      if (result['token'] != null) {
        setAuthToken(result['token'] as String);
      }
      
      return result;
    } catch (e) {
      throw ApiException('Login failed: $e');
    }
  }
  
  /// Register new user
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Registration failed: $e');
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      await _httpClient.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: _headers,
      );
      
      clearAuthToken();
    } catch (e) {
      // Clear token even if logout API fails
      clearAuthToken();
      throw ApiException('Logout failed: $e');
    }
  }
  
  // ============================================================================
  // TRANSLATION SESSION API CALLS  
  // ============================================================================
  
  /// Create new translation session
  Future<Map<String, dynamic>> createTranslationSession(
    String userId, 
    String language,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/translation/session'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'language': language,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Create translation session failed: $e');
    }
  }
  
  /// Get translation session by ID
  Future<Map<String, dynamic>> getTranslationSession(String sessionId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/translation/session/$sessionId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Get translation session failed: $e');
    }
  }
  
  // ============================================================================
  // ML TRANSLATION API CALLS
  // ============================================================================
  
  /// Send image frame to ML API for translation
  Future<Map<String, dynamic>> translateImage(
    Uint8List imageBytes, 
    String language,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_mlBaseUrl/translate'),
      );
      
      request.fields['language'] = language;
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'frame.jpg',
        ),
      );
      
      // Add auth headers (if ML API requires auth)
      request.headers.addAll(_headers);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('ML translation failed: $e');
    }
  }
  
  /// Check ML server health
  Future<bool> checkMLHealth() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_mlBaseUrl/health'),
        headers: _headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // ============================================================================
  // VIDEO ROOM API CALLS
  // ============================================================================
  
  /// Create new video room
  Future<Map<String, dynamic>> createVideoRoom(String userId) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/video/room'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Create video room failed: $e');
    }
  }
  
  /// Join existing video room
  Future<Map<String, dynamic>> joinVideoRoom(
    String roomId, 
    String userId,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/video/room/$roomId/join'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Join video room failed: $e');
    }
  }
  
  /// Leave video room
  Future<void> leaveVideoRoom(String roomId, String userId) async {
    try {
      await _httpClient.post(
        Uri.parse('$_baseUrl/video/room/$roomId/leave'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
        }),
      );
    } catch (e) {
      throw ApiException('Leave video room failed: $e');
    }
  }
  
  // ============================================================================
  // HEALTH CHECK API CALLS
  // ============================================================================
  
  /// Check backend server health
  Future<bool> checkBackendHealth() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/health'),
        headers: _headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Dispose HTTP client
  void dispose() {
    _httpClient.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  const ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ApiException: $message';
}

/// API Response wrapper for typed responses
class ApiResponse<T> {
  final T data;
  final bool success;
  final String? message;
  final int? statusCode;
  
  const ApiResponse({
    required this.data,
    required this.success,
    this.message,
    this.statusCode,
  });
  
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      data: data,
      success: true,
      message: message,
      statusCode: 200,
    );
  }
  
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      data: null as T,
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
