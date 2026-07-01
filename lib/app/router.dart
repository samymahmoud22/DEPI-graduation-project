import 'package:go_router/go_router.dart';
import 'package:visionmate/features/voice_assistant/domain/presentation/screens/voice_screen.dart';
import '/features/auth/presentation/screens/login_screen.dart';
import '/features/auth/presentation/screens/signup_screen.dart';
import '/features/auth/presentation/screens/forgot_password_screen.dart';
import '/features/history/presentation/screens/history_screen.dart';
import '/features/home/presentation/screens/home_screen.dart';
import '/features/navigation_feature/presentation/screens/navigation_screen.dart';
import '/features/person_recognition/presentation/screens/person_screen.dart';
import '/features/read_text/presentation/screens/read_text_screen.dart';
import '/features/scan_object/presentation/screens/scan_object_screen.dart';
import '/features/settings/presentation/screens/settings_screen.dart';
import '/features/splash/presentation/screens/splash_screen.dart';
import '/features/person_recognition/presentation/screens/enroll_person_screen.dart';
import '/features/auth/presentation/screens/email_verification_screen.dart';
import '/features/auth/presentation/screens/profile_screen.dart';


abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const emailVerification = '/email-verification';
  static const home = '/home';
  static const voice = '/voice';
  static const scanObject = '/scan-object';
  static const readText = '/read-text';
  static const person = '/person';
  static const enrollPerson = '/person/enroll';
  static const navigation = '/navigation';
  static const history = '/history';
  static const settings = '/settings';
  static const profile = '/profile';
}

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.emailVerification,
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return EmailVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.voice,
      builder: (context, state) => const VoiceScreen(),
    ),
    GoRoute(
      path: AppRoutes.scanObject,
      builder: (context, state) => const ScanObjectScreen(),
    ),
    GoRoute(
  path: AppRoutes.readText,
  builder: (context, state) => const ReadTextScreen(),
),
    GoRoute(
      path: AppRoutes.person,
      builder: (context, state) => const PersonScreen(),
    ),
    GoRoute(
      path: AppRoutes.enrollPerson,
      builder: (context, state) => const EnrollPersonScreen(),
    ),
    GoRoute(
      path: AppRoutes.navigation,
      builder: (context, state) => const NavigationScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

