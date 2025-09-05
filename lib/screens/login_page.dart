// ===== 4. SCREENS =====
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';
import 'main_page.dart'; // ou o nome da sua tela principal

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
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

  // ✅ VALIDAÇÕES
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  // ✅ MÉTODO QUE ESTAVA FALTANDO:
  Future<void> _handleLogin() async {
    // Limpar erros anteriores
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    // Validar formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Tentar fazer login
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Verificar se o widget ainda está montado
      if (!mounted) return;

      if (success) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setBool('isLoggedIn', true);
        // Login bem-sucedido - navegar para tela principal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Login realizado com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navegar para a tela principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const MainScreen(), // Substitua pela sua tela principal
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // Login falhou - mostrar erro
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authProvider.error ??
                        'Erro no login. Verifique suas credenciais.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Erro inesperado
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Erro inesperado: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF405DE6),
              Color(0xFF5B51D8),
              Color(0xFF833AB4),
              Color(0xFFC13584),
              Color(0xFFE1306C),
              Color(0xFFFF5722),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo/Título
                        const Text(
                          'Instagram Insights',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF833AB4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faça login para acessar seus insights',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Campo Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Digite seu email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF833AB4), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campo Senha
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Digite sua senha',
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF833AB4), width: 2),
                            ),
                          ),
                          onFieldSubmitted: (_) =>
                              _handleLogin(), // Enter para fazer login
                        ),
                        const SizedBox(height: 24),

                        // Botão Login - ✅ AGORA USA O _handleLogin
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Container(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF833AB4),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: const Color(0xFF833AB4)
                                      .withValues(alpha: 0.3),
                                ),
                                child: authProvider.isLoading
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Entrando...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Entrar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Link "Esqueceu a senha?"
                        TextButton(
                          onPressed: () {
                            // TODO: Implementar recuperação de senha
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Funcionalidade em desenvolvimento'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              color: Color(0xFF833AB4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Divisor
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Link para registro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Não tem conta? ',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Cadastre-se',
                                style: TextStyle(
                                  color: Color(0xFF833AB4),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
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
          ),
        ),
      ),
    );
  }
}
