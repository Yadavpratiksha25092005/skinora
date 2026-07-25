import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/basic_info_screen.dart';
import '../screens/home/home_dashboard.dart';
import '../screens/assessment/assessment_intro_screen.dart';
import '../screens/assessment/skin_assessment_screen.dart';
import '../screens/assessment/hair_assessment_screen.dart';
import '../screens/assessment/assessment_results_screen.dart';
import '../screens/assessment/skin_goals_screen.dart';
import '../screens/assessment/hair_goals_screen.dart';
import '../screens/assessment/routine_result_screen.dart';
import '../screens/features/community_screen.dart';
import '../screens/doctor/doctor_dashboard.dart';
import '../screens/wellness/cycle_calendar_screen.dart';
import '../screens/wellness/symptom_tracker_screen.dart';
import '../screens/wellness/wellness_info_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/basic-info',
        builder: (context, state) => const BasicInfoScreen(),
      ),
      // --- Assessment Flow ---
      GoRoute(
        path: '/assessment-intro',
        builder: (context, state) => const AssessmentIntroScreen(),
      ),
      GoRoute(
        path: '/skin-assessment',
        builder: (context, state) => const SkinAssessmentScreen(),
      ),
      GoRoute(
        path: '/hair-assessment',
        builder: (context, state) => const HairAssessmentScreen(),
      ),
      GoRoute(
        path: '/assessment-results',
        builder: (context, state) => const AssessmentResultsScreen(),
      ),
      GoRoute(
        path: '/skin-goals',
        builder: (context, state) => const SkinGoalsScreen(),
      ),
      GoRoute(
        path: '/hair-goals',
        builder: (context, state) => const HairGoalsScreen(),
      ),
      GoRoute(
        path: '/routine-result',
        builder: (context, state) => const RoutineResultScreen(),
      ),
      // --- Dashboard ---
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeDashboard(),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
  path: '/doctor-home',
  builder: (context, state) => const DoctorDashboard(),
),
      GoRoute(
        path: '/cycle-calendar',
        builder: (context, state) => const CycleCalendarScreen(),
      ),
      GoRoute(
        path: '/symptom-tracker',
        builder: (context, state) => const SymptomTrackerScreen(),
      ),
      GoRoute(
        path: '/wellness-info',
        builder: (context, state) => const WellnessInfoScreen(),
      ),
    ],
  );
}
