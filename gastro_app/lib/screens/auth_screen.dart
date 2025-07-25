import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/logo_widget.dart';
import '../widgets/email_confirmation_dialog.dart';
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

  void _showEmailConfirmationDialog(String email) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => EmailConfirmationDialog(email: email),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gradientFundo,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calcular espaçamentos baseado na altura disponível
                final isCompactScreen = safeAreaHeight < 700;
                final topSpacing = isCompactScreen ? 20.0 : 40.0;
                final logoSpacing = isCompactScreen ? 20.0 : 30.0;
                final cardSpacing = isCompactScreen ? 16.0 : 24.0;
                final bottomSpacing = isCompactScreen ? 16.0 : 24.0;
                
                return Container(
                  width: double.infinity,
                  height: constraints.maxHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 400 ? 32.0 : 24.0,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: topSpacing),
                      
                      // Logo e header compacto
                      _buildCompactHeader(isCompactScreen),
                      
                      SizedBox(height: logoSpacing),
                      
                      // Card de autenticação otimizado
                      Expanded(
                        child: _buildOptimizedAuthCard(isCompactScreen),
                      ),
                      
                      SizedBox(height: cardSpacing),
                      
                      // Rodapé minimalista
                      _buildCompactFooter(),
                      
                      SizedBox(height: bottomSpacing),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(bool isCompactScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Real Taste Test
        Hero(
          tag: 'taste_test_logo',
          child: Container(
            padding: EdgeInsets.all(isCompactScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1,
              ),
            ),
            child: isCompactScreen 
              ? LogoWidget.medium()
              : LogoWidget.large(),
          ),
        ),
        
        if (!isCompactScreen) ...[
          const SizedBox(height: 16),
          
          // Título simplificado
          const Text(
            'Bem-vindo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtítulo compacto
          Text(
            'Sua jornada gastronômica começa aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.cinzaMedio,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptimizedAuthCard(bool isCompactScreen) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: 400,
        maxHeight: isCompactScreen ? 420 : 480,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppTheme.bordoSuave,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Tab bar otimizada
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
          
          // Conteúdo das abas com altura flexível
          Expanded(
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

  Widget _buildCompactFooter() {
    return Text(
      'Ao continuar, você aceita nossos termos e política de privacidade',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        color: AppTheme.cinzaMedio.withOpacity(0.8),
        height: 1.3,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // Handlers para login e registro atualizados
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
      } else if (result.needsEmailConfirmation) {
        _showEmailConfirmationDialog(result.emailToConfirm!);
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
      } else if (result.needsEmailConfirmation) {
        _showEmailConfirmationDialog(result.emailToConfirm!);
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