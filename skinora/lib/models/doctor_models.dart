class Doctor {
  final String id;
  final String name;
  final String qualification;
  final String specialization; // e.g. "Acne", "Hair Fall", "General Dermatology"
  final int experienceYears;
  final double rating;
  final List<String> languages;
  final String about;
  final String? photoUrl; // null -> fallback to initials avatar

  const Doctor({
    required this.id,
    required this.name,
    required this.qualification,
    required this.specialization,
    required this.experienceYears,
    required this.rating,
    required this.languages,
    required this.about,
    this.photoUrl,
  });

  /// Parses a Doctor from the backend's JSON shape (models.Doctor).
  /// Backend doesn't have `languages`, so it defaults to English/Hindi.
  /// `about` is generated from the clinic name since the backend has no bio field.
  factory Doctor.fromJson(Map<String, dynamic> json) {
    final clinicName = json['clinic_name'] as String? ?? '';
    return Doctor(
      id: json['id'].toString(),
      name: json['full_name'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      specialization: json['specialization'] as String? ?? 'General Dermatology',
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      languages: const ['English', 'Hindi'],
      about: clinicName.isNotEmpty
          ? 'Practices at $clinicName.'
          : 'Available for consultation.',
    );
  }
}

enum ConsultationMode { chat, audio }

enum AppointmentStatus { pending, accepted, rejected, completed }

/// Parses a [ConsultationMode] from the backend's string value ("chat"/"audio").
ConsultationMode consultationModeFromString(String value) {
  switch (value) {
    case 'audio':
      return ConsultationMode.audio;
    case 'chat':
    default:
      return ConsultationMode.chat;
  }
}

/// Converts a [ConsultationMode] to the string value expected by the backend.
String consultationModeToString(ConsultationMode mode) {
  switch (mode) {
    case ConsultationMode.audio:
      return 'audio';
    case ConsultationMode.chat:
      return 'chat';
  }
}

/// Parses an [AppointmentStatus] from the backend's string value.
AppointmentStatus appointmentStatusFromString(String value) {
  switch (value) {
    case 'accepted':
      return AppointmentStatus.accepted;
    case 'rejected':
      return AppointmentStatus.rejected;
    case 'completed':
      return AppointmentStatus.completed;
    case 'pending':
    default:
      return AppointmentStatus.pending;
  }
}

/// A booked (or being-booked) appointment with a doctor.
class Appointment {
  final String id;
  final Doctor doctor;
  final String patientName;
  final DateTime date;
  final String timeSlot; // e.g. "10:00 AM"
  final ConsultationMode mode;
  final AppointmentStatus status;

  const Appointment({
    required this.id,
    required this.doctor,
    this.patientName = 'Patient',
    required this.date,
    required this.timeSlot,
    required this.mode,
    this.status = AppointmentStatus.pending,
  });

  /// Parses an Appointment from the backend's JSON shape (models.Appointment).
  /// Requires the `doctor` object to be present (backend preloads it on all
  /// read endpoints), since Doctor has no meaningful "unknown" fallback.
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'].toString(),
      doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      patientName: json['patient_name'] as String? ?? 'Patient',
      date: DateTime.parse(json['date'] as String),
      timeSlot: json['time_slot'] as String? ?? '',
      mode: consultationModeFromString(json['mode'] as String? ?? 'chat'),
      status: appointmentStatusFromString(json['status'] as String? ?? 'pending'),
    );
  }

  Appointment copyWith({AppointmentStatus? status}) {
    return Appointment(
      id: id,
      doctor: doctor,
      patientName: patientName,
      date: date,
      timeSlot: timeSlot,
      mode: mode,
      status: status ?? this.status,
    );
  }
}
