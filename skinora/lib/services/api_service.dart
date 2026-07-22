import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central place for all backend API calls.
/// Every screen should go through this class instead of calling Dio directly.
class ApiService {
  // Windows desktop / same-machine testing -> localhost works.
  // If you later test on Android emulator, change this to 10.0.2.2
  // If you test on a real phone, change this to your PC's local IP (e.g. 192.168.1.5)
  static const String baseUrl = 'http://localhost:8080/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  ApiService() {
    // Automatically attach the saved JWT token (if any) to every request.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // ---------- Token storage helpers ----------

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ---------- AUTH: User ----------

  /// Signs up a new normal user. Returns the response data on success.
  /// Throws [ApiException] on failure with a user-friendly message.
  Future<Map<String, dynamic>> userSignup({
    required String fullName,
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/user/signup', data: {
        'full_name': fullName,
        'mobile_number': mobileNumber,
        'password': password,
      });

      final data = response.data['data'];
      await _saveToken(data['token']);
      return data;
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- AUTH: Doctor ----------

  Future<Map<String, dynamic>> doctorSignup({
    required String fullName,
    required String mobileNumber,
    required String email,
    required String password,
    required String specialization,
    required String licenseNumber,
    int experienceYears = 0,
    String qualification = '',
    String clinicName = '',
  }) async {
    try {
      final response = await _dio.post('/auth/doctor/signup', data: {
        'full_name': fullName,
        'mobile_number': mobileNumber,
        'email': email,
        'password': password,
        'specialization': specialization,
        'license_number': licenseNumber,
        'experience_years': experienceYears,
        'qualification': qualification,
        'clinic_name': clinicName,
      });

      final data = response.data['data'];
      await _saveToken(data['token']);
      return data;
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- AUTH: Shared Login ----------

  /// role must be either "user" or "doctor"
  Future<Map<String, dynamic>> login({
    required String mobileNumber,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'mobile_number': mobileNumber,
        'password': password,
        'role': role,
      });

      final data = response.data['data'];
      await _saveToken(data['token']);
      return data;
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- Error handling helper ----------

  String _extractErrorMessage(DioException e) {
    // Network-level errors (server not running, no internet, timeout)
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Make sure the backend is running.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please try again.';
    }

    // Backend returned a structured error, e.g. {"success": false, "message": "..."}
    final responseData = e.response?.data;
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return 'Something went wrong. Please try again.';
  }
}

/// Custom exception carrying a message safe to show directly in the UI.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}