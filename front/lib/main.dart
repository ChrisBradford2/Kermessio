import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:front/repositories/child_repository.dart';
import 'blocs/child_bloc.dart';
import 'repositories/auth_repository.dart';
import 'blocs/auth_bloc.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home/home_page.dart';
import 'blocs/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  // Initialize Stripe
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  Stripe.instance.applySettings();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthRepository authRepository = AuthRepository();
  final ChildRepository childRepository = ChildRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<ChildBloc>(
          create: (context) => ChildBloc(childRepository: childRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kermessio',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
        },
        initialRoute: '/',
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    if (kDebugMode) {
      print("AuthBloc initialisé avec succès : $authBloc");
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (kDebugMode) {
            print("L'utilisateur est authentifié.");
          }
          return const HomePage();
        } else {
          if (kDebugMode) {
            print("L'utilisateur n'est pas authentifié.");
          }
          return LoginPage();
        }
      },
    );
  }
}
