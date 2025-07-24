import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/taste_test_logo.dart';
import '../config/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
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
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.customColors['success'],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gradientFundo,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      
                      // Logo centralizado
                      _buildCleanHeader(),
                      
                      const SizedBox(height: 60),
                      
                      // Card de autenticação minimalista
                      _buildCleanAuthCard(),
                      
                      const SizedBox(height: 40),
                      
                      // Rodapé simples
                      _buildCleanFooter(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanHeader() {
    return Column(
      children: [
        // Logo Taste Test com design clean
        Hero(
          tag: 'taste_test_logo',
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: AppTheme.gradientSuave,
              borderRadius: BorderRadius.circular(AppTheme.radiusExtraGrande),
              boxShadow: AppTheme.sombraCard,
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1,
              ),
            ),
            child: TasteTestLogo.large(),
          ),
        ),
        
        const SizedBox(height: 36),
        
        // Título clean
        const Text(
          'Bem-vindo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: AppTheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtítulo minimalista
        Text(
          'Sua jornada gastronômica começa aqui',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.cinzaMedio,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCleanAuthCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        boxShadow: AppTheme.sombraElevada,
        border: Border.all(
          color: AppTheme.bordoSuave,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Tab bar minimalista
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.cinzaClaro,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppTheme.gradientPrimario,
                borderRadius: BorderRadius.circular(AppTheme.radiusPequeno),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.cinzaMedio,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Entrar'),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Criar Conta'),
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo das abas
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 380,
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
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

  Widget _buildCleanFooter() {
    return Column(
      children: [
        // Texto de política simplificado
        Text(
          'Ao continuar, você aceita nossos termos e política de privacidade',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.cinzaMedio.withOpacity(0.8),
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Handlers para login e registro (mantidos inalterados)
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