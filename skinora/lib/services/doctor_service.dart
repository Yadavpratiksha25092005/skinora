import '../models/doctor_models.dart';
import 'api_service.dart';

/// Provides doctor data and booking, backed by the real Go backend via
/// [ApiService]. Screens only depend on this class, so no UI changes are
/// needed beyond the `specializations` -> `getSpecializations()` call site
/// (see doctor_list_screen.dart).
class DoctorService {
  static final DoctorService _instance = DoctorService._internal();
  factory DoctorService() => _instance;
  DoctorService._internal();

  final ApiService _api = ApiService();

  List<Doctor>? _cachedDoctors;

  Future<List<Doctor>> getAllDoctors({bool forceRefresh = false}) async {
    if (_cachedDoctors != null && !forceRefresh) return _cachedDoctors!;

    final data = await _api.getDoctors();
    _cachedDoctors = data
        .map((json) => Doctor.fromJson(json as Map<String, dynamic>))
        .toList();
    return _cachedDoctors!;
  }

  Future<List<Doctor>> search({String query = '', String? specialization}) async {
    final all = await getAllDoctors();
    return all.where((doc) {
      final matchesQuery = query.isEmpty ||
          doc.name.toLowerCase().contains(query.toLowerCase()) ||
          doc.specialization.toLowerCase().contains(query.toLowerCase());
      final matchesFilter = specialization == null ||
          specialization == 'All' ||
          doc.specialization == specialization;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  Future<List<Doctor>> suggestDoctorsFor(String condition) async {
    final all = await getAllDoctors();
    final matches = all
        .where((doc) => doc.specialization.toLowerCase() == condition.toLowerCase())
        .toList();
    if (matches.isEmpty) {
      return all.where((doc) => doc.specialization == 'General Dermatology').toList();
    }
    return matches;
  }

  /// Replaces the old synchronous `specializations` getter — specializations
  /// now come from the real doctor list, so this needs a network round trip.
  Future<List<String>> getSpecializations() async {
    final all = await getAllDoctors();
    return ['All', ...all.map((d) => d.specialization).toSet()];
  }

  // ---------- Booking (patient side) ----------

  Future<Appointment> bookAppointment({
    required Doctor doctor,
    required DateTime date,
    required String timeSlot,
    required ConsultationMode mode,
    String patientName = 'Patient',
  }) async {
    // patientName is intentionally ignored — the backend always derives it
    // from the authenticated user's own record.
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final data = await _api.bookAppointment(
      doctorId: int.parse(doctor.id),
      date: dateStr,
      timeSlot: timeSlot,
      mode: consultationModeToString(mode),
    );
    return Appointment.fromJson(data);
  }

  Future<List<Appointment>> getHistory() async {
    final data = await _api.getUserAppointments();
    return data.map((json) => Appointment.fromJson(json as Map<String, dynamic>)).toList();
  }

  // ---------- Doctor side ----------

  Future<List<Appointment>> getAllAppointments() async {
    final data = await _api.getDoctorAppointments();
    final appointments =
        data.map((json) => Appointment.fromJson(json as Map<String, dynamic>)).toList();
    appointments.sort((a, b) => a.date.compareTo(b.date));
    return appointments;
  }

  Future<List<Appointment>> getPendingAppointments() async {
    final all = await getAllAppointments();
    return all.where((a) => a.status == AppointmentStatus.pending).toList();
  }

  Future<List<Appointment>> getTodayAppointments() async {
    final all = await getAllAppointments();
    final now = DateTime.now();
    return all
        .where((a) =>
            a.date.year == now.year && a.date.month == now.month && a.date.day == now.day)
        .toList();
  }

  Future<void> acceptAppointment(String id) async {
    await _api.acceptAppointment(id);
  }

  Future<void> rejectAppointment(String id) async {
    await _api.rejectAppointment(id);
  }
}
