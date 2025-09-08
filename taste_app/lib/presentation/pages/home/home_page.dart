import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // << novo
import 'home_provider.dart';

/// Página principal (Home) conforme referência visual
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isNavigationReady = false;
  LatLng? _currentPosition; // posição do usuário
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
    _getUserLocation(); // busca localização assim que inicia
  }

  /// Aguarda o router estar pronto antes de habilitar navegação
  void _initializeNavigation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isNavigationReady = true;
      });
    }
  }

  /// Busca a localização atual do usuário
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Serviço de localização desabilitado.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Permissão negada.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Permissão negada permanentemente.");
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF2c3b83),
      body: SafeArea(
        child: Column(
          children: [
            _buildLogoHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMapSection(),
                    _buildMoodSection(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo_tt2.png',
              height: 80,
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Qual a sua vibe hoje?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: const Text(
              'um ramen quentinho no Bom Fim',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vou direto e só mando qual é bom.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Mapa com localização atual do usuário
  Widget _buildMapSection() {
    if (_currentPosition == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          height: 180,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF2c3b83)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descubra por clima,',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'ocasião ou desejo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.2,
            children: [
              _buildMoodCard('Date Night\n🍝',
                  const Color(0xFFFFA726), '32555c5c-b206-4c31-9e4d-1cf5d68d1e8d'),
              _buildMoodCard('Para curar\na ressaca 🍔',
                  const Color(0xFFFF7043), '45a122d2-d5fd-4e20-ab17-2d1a1699c3e0'),
              _buildMoodCard('Com vibe\nleve 🥗',
                  const Color(0xFF42A5F5), '0a575266-ee8e-4c72-82e9-2a85359682cb'),
              _buildMoodCard(
                  ref.read(homeProvider.notifier).getRestaurantNameForCategory(
                      'dfadf4da-3c7b-4d85-b6da-5b0bddd60195',
                      'Clássicos\nCuritiba'),
                  const Color(0xFF5C6BC0),
                  'dfadf4da-3c7b-4d85-b6da-5b0bddd60195'),
              _buildMoodCard(
                  ref.read(homeProvider.notifier).getRestaurantNameForCategory(
                      'a945c6bb-0554-4181-831c-17928864ee52',
                      'Vontade\nde doce'),
                  const Color(0xFF9C27B0),
                  'a945c6bb-0554-4181-831c-17928864ee52'),
              _buildMoodCard(
                  ref.read(homeProvider.notifier).getRestaurantNameForCategory(
                      'c9fdb068-aff4-4fe1-84ff-10974d62fba9',
                      'Almoço\nde domingo'),
                  const Color(0xFFFFCA28),
                  'c9fdb068-aff4-4fe1-84ff-10974d62fba9'),
              _buildMoodCard(
                  ref.read(homeProvider.notifier).getRestaurantNameForCategory(
                      '948a606b-78ff-4bcd-9d37-f14ec5654e25',
                      'Happy hour\nde firma'),
                  const Color(0xFF26C6DA),
                  '948a606b-78ff-4bcd-9d37-f14ec5654e25'),
              _buildMoodCard(
                  ref.read(homeProvider.notifier).getRestaurantNameForCategory(
                      '1417ab7f-338c-4dd4-96d7-87bcaa8099bf', 'Sushi fresh'),
                  const Color(0xFFFF5722),
                  '1417ab7f-338c-4dd4-96d7-87bcaa8099bf'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(String text, Color color, String categoryId) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isNavigationReady
            ? () => _navigateTo('/discovery/$categoryId')
            : null,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.crimsonText(
                textStyle: const TextStyle(
                  color: Color(0xFF2c3b83),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B35),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem('Descubra', true),
              _buildBottomNavItem('Mapa', false),
              _buildBottomNavItem('Perfil', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(String label, bool isSelected) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isNavigationReady ? () => _onBottomNavTap(label) : null,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color:
                  isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _onBottomNavTap(String label) {
    switch (label) {
      case 'Descubra':
        _navigateTo('/discovery/todos');
        break;
      case 'Mapa':
        _navigateTo('/map');
        break;
      case 'Perfil':
        _navigateTo('/profile');
        break;
    }
  }

  void _navigateTo(String path) {
    if (!_isNavigationReady || !mounted) return;

    try {
      if (GoRouter.maybeOf(context) != null) {
        context.go(path);
      } else {
        debugPrint(
            'GoRouter não disponível no contexto, tentando novamente em 100ms');
        Future.delayed(
            const Duration(milliseconds: 100), () => _navigateTo(path));
      }
    } catch (e) {
      debugPrint('Erro na navegação: $e');
      Future.delayed(
          const Duration(milliseconds: 200), () => _navigateTo(path));
    }
  }
}
