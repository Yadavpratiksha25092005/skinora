import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/doctor_models.dart';

/// A UI-only "call" screen for testing the consultation flow.
/// NOTE: No real audio/VoIP connection happens here — this is a visual
/// placeholder. Real calling requires a service like Agora, Twilio, or
/// WebRTC integrated on the backend.
class ConsultationCallScreen extends StatefulWidget {
  final Appointment appointment;

  const ConsultationCallScreen({super.key, required this.appointment});

  @override
  State<ConsultationCallScreen> createState() => _ConsultationCallScreenState();
}

class _ConsultationCallScreenState extends State<ConsultationCallScreen> {
  bool _muted = false;
  bool _speakerOn = true;
  int _seconds = 0;
  late final Stream<int> _timer;

  @override
  void initState() {
    super.initState();
    _timer = Stream.periodic(const Duration(seconds: 1), (i) => i + 1);
    _timer.listen((s) {
      if (mounted) setState(() => _seconds = s);
    });
  }

  String get _durationLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.25),
                ),
                child: Center(
                  child: Text(
                    widget.appointment.patientName.isNotEmpty ? widget.appointment.patientName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.appointment.patientName,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_durationLabel, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Local test call — no real audio connection yet',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.5),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _callButton(
                    icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    onTap: () => setState(() => _muted = !_muted),
                    active: _muted,
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 24),
                  _callButton(
                    icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    onTap: () => setState(() => _speakerOn = !_speakerOn),
                    active: !_speakerOn,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _callButton({required IconData icon, required VoidCallback onTap, required bool active}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}