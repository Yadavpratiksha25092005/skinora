import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central place for all backend API calls.
/// Every screen should go through this class instead of calling Dio directly.
class ApiService {
  // Windows desktop / same-machine testing -> localhost works.
  // If you later test on Android emulator, change this to 10.0.2.2
  // If you test on a real phone, change this to your PC's local IP (e.g. 192.168.1.5)
  static const String baseUrl = 'http://192.168.1.12:8080/api';
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // ---------- Local storage helpers ----------

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Saves basic profile info locally so screens (like the dashboard header)
  /// can show it instantly without an extra network round trip.
  Future<void> _saveLocalProfile({
    required String fullName,
    required String role,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_full_name', fullName);
    await prefs.setString('user_role', role);
    if (userId != null) await prefs.setInt('user_id', userId);
  }

  Future<String> getSavedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_full_name') ?? 'there';
  }

  Future<String> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? 'user';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ---------- AUTH: User ----------

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
      await _saveLocalProfile(
        fullName: data['user']['full_name'] ?? fullName,
        role: 'user',
        userId: data['user']['id'],
      );
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
      await _saveLocalProfile(
        fullName: data['doctor']['full_name'] ?? fullName,
        role: 'doctor',
        userId: data['doctor']['id'],
      );
      return data;
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- AUTH: Shared Login ----------

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

      final profile = role == 'doctor' ? data['doctor'] : data['user'];
      await _saveLocalProfile(
        fullName: profile['full_name'] ?? '',
        role: role,
        userId: profile['id'],
      );
      return data;
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- ASSESSMENT ----------

  Future<Map<String, dynamic>> submitAssessment(Map<String, dynamic> answers) async {
    try {
      final response = await _dio.post('/user/assessment', data: answers);
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>?> getLatestAssessment() async {
    try {
      final response = await _dio.get('/user/assessment/latest');
      return response.data['data'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null; // no assessment yet
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- Doctors ----------

  Future<List<dynamic>> getDoctors() async {
    try {
      final response = await _dio.get('/user/doctors');
      return response.data['data'] as List<dynamic>? ?? [];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- Appointments ----------

  Future<Map<String, dynamic>> bookAppointment({
    required int doctorId,
    required String date,
    required String timeSlot,
    required String mode,
  }) async {
    try {
      final response = await _dio.post('/user/appointments', data: {
        'doctor_id': doctorId,
        'date': date,
        'time_slot': timeSlot,
        'mode': mode,
      });
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<List<dynamic>> getUserAppointments() async {
    try {
      final response = await _dio.get('/user/appointments');
      return response.data['data'] as List<dynamic>? ?? [];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<List<dynamic>> getDoctorAppointments() async {
    try {
      final response = await _dio.get('/doctor/appointments');
      return response.data['data'] as List<dynamic>? ?? [];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> acceptAppointment(String id) async {
    try {
      final response = await _dio.put('/doctor/appointments/$id/accept');
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> rejectAppointment(String id) async {
    try {
      final response = await _dio.put('/doctor/appointments/$id/reject');
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- Community: Remedies ----------

  Future<Map<String, dynamic>> createRemedy({
    required String title,
    required String category,
    required String ingredients,
    required String preparationSteps,
  }) async {
    try {
      final response = await _dio.post('/user/remedies', data: {
        'title': title,
        'category': category,
        'ingredients': ingredients,
        'preparation_steps': preparationSteps,
      });
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<List<dynamic>> getAllRemedies({String? category}) async {
    try {
      final response = await _dio.get(
        '/user/remedies',
        queryParameters: category != null && category != 'All' ? {'category': category} : null,
      );
      return response.data['data'] as List<dynamic>? ?? [];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<List<dynamic>> getSavedRemedies() async {
    try {
      final response = await _dio.get('/user/remedies/saved');
      return response.data['data'] as List<dynamic>? ?? [];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> toggleLikeRemedy(int remedyId) async {
    try {
      final response = await _dio.post('/user/remedies/$remedyId/like');
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> toggleSaveRemedy(int remedyId) async {
    try {
      final response = await _dio.post('/user/remedies/$remedyId/save');
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<List<dynamic>> getComments(int remedyId) async {
    try {
      final response = await _dio.get('/user/remedies/$remedyId/comments');
      return response.data['data'] as List<dynamic>? ?? [];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> addComment(int remedyId, String text) async {
    try {
      final response = await _dio.post('/user/remedies/$remedyId/comments', data: {'text': text});
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- Error handling helper ----------

  String _extractErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Make sure the backend is running.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please try again.';
    }

    final responseData = e.response?.data;
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return 'Something went wrong. Please try again.';
  }

  // ---------- SKIN SCAN (Gemini AI analysis) ----------

  Future<Map<String, dynamic>> analyzeSkin(String base64Image) async {
    try {
      final response = await _dio.post(
        '/user/skin-scan',
        data: {'image_base64': base64Image},
        options: Options(
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<List<dynamic>> getSkinScanHistory() async {
    try {
      final response = await _dio.get('/user/skin-scan/history');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- HAIR SCAN (Gemini AI analysis) ----------

  Future<Map<String, dynamic>> analyzeHair(String base64Image) async {
    try {
      final response = await _dio.post(
        '/user/hair-scan',
        data: {'image_base64': base64Image},
        options: Options(
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<List<dynamic>> getHairScanHistory() async {
    try {
      final response = await _dio.get('/user/hair-scan/history');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  // ---------- AI CHAT (Gemini) ----------

  Future<String> sendChatMessage(String message, List<Map<String, String>> history) async {
    try {
      final response = await _dio.post(
        '/user/chat',
        data: {
          'message': message,
          'history': history,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      return response.data['data']['reply'] as String;
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}