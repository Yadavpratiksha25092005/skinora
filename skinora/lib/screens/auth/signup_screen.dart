import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Shared fields
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Doctor-only fields
  final _emailController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _clinicController = TextEditingController();

  String _selectedRole = 'user';
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    _clinicController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedRole == 'doctor') {
        final data = await _apiService.doctorSignup(
          fullName: _fullNameController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          specialization: _specializationController.text.trim(),
          licenseNumber: _licenseController.text.trim(),
          experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
          qualification: _qualificationController.text.trim(),
          clinicName: _clinicController.text.trim(),
        );
        debugPrint('Doctor signup successful: $data');

        if (!mounted) return;
        context.go('/doctor-home');
      } else {
        final data = await _apiService.userSignup(
          fullName: _fullNameController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
          password: _passwordController.text,
        );
        debugPrint('User signup successful: $data');

        if (!mounted) return;
        context.push('/basic-info');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDoctor = _selectedRole == 'doctor';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeInUp(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your personalized skincare journey.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // ---------- Role toggle ----------
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _roleTab('user', 'I am a User', Icons.person_outline_rounded)),
                        Expanded(child: _roleTab('doctor', 'I am a Doctor', Icons.medical_services_outlined)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline_rounded,
                    controller: _fullNameController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Mobile Number',
                    hint: 'Enter your mobile number',
                    prefixIcon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    controller: _mobileController,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                      if (v.trim().length < 10) return 'Enter a valid mobile number';
                      return null;
                    },
                  ),

                  // ---------- Doctor-only fields ----------
                  if (isDoctor) ...[
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Specialization',
                      hint: 'e.g. Dermatologist',
                      prefixIcon: Icons.medical_information_outlined,
                      controller: _specializationController,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Specialization is required' : null,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'License Number',
                      hint: 'Medical license number',
                      prefixIcon: Icons.badge_outlined,
                      controller: _licenseController,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'License number is required' : null,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Experience (years)',
                      hint: 'e.g. 5',
                      prefixIcon: Icons.timeline_outlined,
                      keyboardType: TextInputType.number,
                      controller: _experienceController,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Qualification',
                      hint: 'e.g. MBBS, MD Dermatology',
                      prefixIcon: Icons.school_outlined,
                      controller: _qualificationController,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Clinic Name',
                      hint: 'Your clinic or hospital name',
                      prefixIcon: Icons.local_hospital_outlined,
                      controller: _clinicController,
                    ),
                  ],

                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a strong password',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    controller: _passwordController,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'At least 6 characters required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (v) {
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Create Account',
                    isLoading: _isLoading,
                    onPressed: _handleSignup,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          context.pop();
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTab(String role, String label, IconData icon) {
    final bool selected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}