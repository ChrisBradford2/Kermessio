import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../blocs/school_bloc.dart';
import '../blocs/school_event.dart';
import '../blocs/school_state.dart';
import '../models/school_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedRole;
  School? _selectedSchool; // The selected school will be stored here

  @override
  void initState() {
    super.initState();
    // Fetch the list of schools when the page is loaded
    context.read<SchoolBloc>().add(FetchSchoolsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inscription"),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is AuthUnauthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inscription réussie ! Veuillez vous connecter.'),
                  ),
                );
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                      (Route<dynamic> route) => false,
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  _buildTextField(
                    controller: _firstNameController,
                    labelText: 'Prénom',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un prénom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _lastNameController,
                    labelText: 'Nom de famille',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom de famille';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _usernameController,
                    labelText: 'Nom d\'utilisateur',
                    icon: Icons.account_circle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom d\'utilisateur';
                      }
                      final usernameRegex = RegExp(r'^[a-zA-Z0-9._-]+$');
                      if (!usernameRegex.hasMatch(value)) {
                        return 'Le nom d\'utilisateur ne peut contenir que des lettres, des chiffres, des underscores, et des tirets.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un email';
                      }
                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    labelText: 'Mot de passe',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirmer le mot de passe',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSchoolAutocomplete(context),
                  const SizedBox(height: 16),
                  _buildRoleDropdown(),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _selectedSchool != null) {
                        context.read<AuthBloc>().add(
                          AuthRegisterRequested(
                            lastName: _lastNameController.text,
                            firstName: _firstNameController.text,
                            username: _usernameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            role: _selectedRole!,
                            schoolId: _selectedSchool!.id, // Ensure school ID is selected
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez sélectionner une école')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.greenAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer $labelText';
            }
            return null;
          },
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Sélectionnez votre rôle',
        prefixIcon: const Icon(Icons.work, color: Colors.greenAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedRole,
      items: const [
        DropdownMenuItem(
          value: null,
          child: Text('Sélectionnez votre rôle'),
        ),
        if (kIsWeb)
          DropdownMenuItem(
            value: 'organizer',
            child: Text('Organisateur'),
          )
        else ...[
          DropdownMenuItem(
            value: 'parent',
            child: Text('Parent'),
          ),
          DropdownMenuItem(
            value: 'booth_holder',
            child: Text('Teneur de stand'),
          ),
        ],
      ],
      onChanged: (value) {
        setState(() {
          _selectedRole = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner un rôle';
        }
        return null;
      },
    );
  }

  Widget _buildSchoolAutocomplete(BuildContext context) {
    return BlocBuilder<SchoolBloc, SchoolState>(
      builder: (context, state) {
        if (state is SchoolLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SchoolLoaded) {
          return Autocomplete<School>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<School>.empty();
              }
              return state.schools.where((School school) {
                return school.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (School selection) {
              _selectedSchool = selection;
            },
            displayStringForOption: (School option) => option.name,
            fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
              return TextFormField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                decoration: InputDecoration(
                  labelText: 'Sélectionnez votre école',
                  prefixIcon: const Icon(Icons.school, color: Colors.greenAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une école';
                  }
                  return null;
                },
              );
            },
          );
        } else if (state is SchoolError) {
          return Text('Erreur lors du chargement des écoles : ${state.message}');
        }
        return const Text('Aucune école disponible');
      },
    );
  }
}
