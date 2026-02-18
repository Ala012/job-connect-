import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigation handled by AuthWrapper
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion. Veuillez réessayer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Language toggle
          Consumer<LocalizationProvider>(
            builder: (context, localizationProvider, _) {
              return PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'en') {
                    localizationProvider.setLocale(const Locale('en'));
                  } else {
                    localizationProvider.setLocale(const Locale('fr'));
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: 'en', child: Text('English')),
                  const PopupMenuItem(value: 'fr', child: Text('Français')),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      localizationProvider.isEnglish ? 'EN' : 'FR',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
          // Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Icon(
                  Icons.work_outline,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'JobConnect',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Consumer<LocalizationProvider>(
                  builder: (context, localizationProvider, _) {
                    return Text(
                      localizationProvider.isEnglish
                          ? 'Sign in to continue'
                          : 'Connectez-vous pour continuer',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 48),
                Consumer<LocalizationProvider>(
                  builder: (context, localizationProvider, _) {
                    return TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: localizationProvider.isEnglish ? 'Email' : 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizationProvider.isEnglish
                              ? 'Please enter your email'
                              : 'Veuillez entrer votre email';
                        }
                        if (!value.contains('@')) {
                          return localizationProvider.isEnglish
                              ? 'Invalid email'
                              : 'Email invalide';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<LocalizationProvider>(
                  builder: (context, localizationProvider, _) {
                    return TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText:
                            localizationProvider.isEnglish ? 'Password' : 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizationProvider.isEnglish
                              ? 'Please enter your password'
                              : 'Veuillez entrer votre mot de passe';
                        }
                        if (value.length < 6) {
                          return localizationProvider.isEnglish
                              ? 'Password must be at least 6 characters'
                              : 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                Consumer2<AuthProvider, LocalizationProvider>(
                  builder: (context, authProvider, localizationProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(localizationProvider.isEnglish ? 'Sign in' : 'Se connecter'),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Consumer<LocalizationProvider>(
                  builder: (context, localizationProvider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(localizationProvider.isEnglish
                            ? "Don't have an account? "
                            : 'Pas encore de compte ? '),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                              localizationProvider.isEnglish ? 'Sign up' : 'S\'inscrire'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


