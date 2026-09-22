import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/owner_home_screen.dart';
import 'screens/create_listing_screen.dart';
import 'screens/owner_bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KodishaOwnerApp());
}

class KodishaOwnerApp extends StatelessWidget {
  const KodishaOwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        title: 'Kodisha Owner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/',
        routes: {
          '/': (ctx) => const SplashScreen(),
          '/login': (ctx) => const LoginScreen(),
          '/register': (ctx) => const RegisterScreen(role: 'owner'),
          '/home': (ctx) => const OwnerHomeScreen(),
          '/create-listing': (ctx) => const CreateListingScreen(),
          '/bookings': (ctx) => const OwnerBookingsScreen(),
          '/profile': (ctx) => const ProfileScreen(),
          '/chat': (ctx) => const ConversationsScreen(),
        },
      ),
    );
  }
}
