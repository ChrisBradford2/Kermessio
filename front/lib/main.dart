import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/auth_repository.dart';
import 'blocs/auth_bloc.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'blocs/auth_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository();

  MyApp({super.key}); // Initialize the repository

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authRepository: authRepository), // Provide AuthBloc to the app
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kermessio',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Define routes for navigation
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
        },
        initialRoute: '/', // Start the app on the AuthWrapper screen
      ),
    );
  }
}

// A widget to check if the user is authenticated or not
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomePage(); // If authenticated, show the home page
        } else if (state is AuthUnauthenticated) {
          return LoginPage(); // If not authenticated, show the login page
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Show a loading spinner
            ),
          );
        } else {
          return LoginPage(); // By default, show the login page
        }
      },
    );
  }
}
