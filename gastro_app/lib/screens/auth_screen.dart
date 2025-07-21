import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/taste_test_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfbe9d2), // Cor de fundo areia clara
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Logo e título
                _buildHeader(),
                
                const SizedBox(height: 50),
                
                // Card principal com as abas
                _buildAuthCard(),
                
                const SizedBox(height: 30),
                
                // Rodapé com informações
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo Taste Test
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2c3985).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TasteTestLogo.large(
            subtitle: 'GASTRO EXPERIENCE',
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Título principal
        const Text(
          'Gastro App',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3985),
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtítulo
        Text(
          'Entre para personalizar sua experiência gastronômica',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab bar personalizada
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFfbe9d2).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF2c3985),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF2c3985),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Entrar'),
                Tab(text: 'Criar Conta'),
              ],
            ),
          ),
          
          // Conteúdo das abas
          SizedBox(
            height: 400, // Altura fixa para evitar mudanças bruscas
            child: TabBarView(
              controller: _tabController,
              children: [
                LoginForm(
                  onSubmit: _handleLogin,
                  isLoading: _isLoading,
                ),
                RegisterForm(
                  onSubmit: _handleRegister,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Texto de política
        Text(
          'Ao continuar, você concorda com nossos Termos de Uso e Política de Privacidade',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            height: 1.4,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Versão do app
        Text(
          'Gastro App v1.0.0',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  // Handlers para login e registro
  Future<void> _handleLogin(String email, String password) async {
    _setLoading(true);
    
    try {
      final result = await AuthService.signIn(
        email: email,
        password: password,
      );
      
      if (result.isSuccess) {
        _showSuccessMessage('Login realizado com sucesso!');
        // Navigation será tratada automaticamente pelo AuthWrapper
      } else {
        _showErrorMessage(result.error ?? 'Erro no login');
      }
    } catch (e) {
      _showErrorMessage('Erro inesperado. Tente novamente.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleRegister(String email, String password, String? name) async {
    _setLoading(true);
    
    try {
      final result = await AuthService.signUp(
        email: email,
        password: password,
        name: name,
      );
      
      if (result.isSuccess) {
        _showSuccessMessage('Conta criada com sucesso!');
        // Navigation será tratada automaticamente pelo AuthWrapper
      } else {
        _showErrorMessage(result.error ?? 'Erro no registro');
      }
    } catch (e) {
      _showErrorMessage('Erro inesperado. Tente novamente.');
    } finally {
      _setLoading(false);
    }
  }
} 