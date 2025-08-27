import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/config/google_maps_config.dart';

/// Widget para exibir diagnósticos do Google Maps
class GoogleMapsDiagnosticsWidget extends StatefulWidget {
  const GoogleMapsDiagnosticsWidget({super.key});

  @override
  State<GoogleMapsDiagnosticsWidget> createState() => _GoogleMapsDiagnosticsWidgetState();
}

class _GoogleMapsDiagnosticsWidgetState extends State<GoogleMapsDiagnosticsWidget> {
  Map<String, dynamic>? _diagnostics;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _runDiagnostics();
    }
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final diagnostics = await GoogleMapsConfig.runDiagnostics();
      setState(() {
        _diagnostics = diagnostics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _diagnostics = {
          'error': 'Falha ao executar diagnósticos: $e',
          'timestamp': DateTime.now().toIso8601String(),
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Diagnóstico Google Maps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _runDiagnostics,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_diagnostics != null)
              _buildDiagnosticsContent()
            else
              const Text('Nenhum diagnóstico disponível'),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticsContent() {
    final diagnostics = _diagnostics!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusCard(
          'Status Geral',
          GoogleMapsConfig.isAvailable,
          GoogleMapsConfig.isAvailable ? 'Disponível' : 'Indisponível',
        ),
        const SizedBox(height: 8),
        _buildStatusCard(
          'API Key',
          GoogleMapsConfig.hasValidApiKey,
          GoogleMapsConfig.hasValidApiKey ? 'Configurada' : 'Não configurada',
        ),
        const SizedBox(height: 8),
        _buildStatusCard(
          'Inicialização',
          diagnostics['initialization']?['completed'] ?? false,
          diagnostics['initialization']?['completed'] == true ? 'Concluída' : 'Pendente',
        ),
        if (diagnostics['connectivity'] != null) ...[
          const SizedBox(height: 8),
          _buildConnectivityCard(diagnostics['connectivity']),
        ],
        if (diagnostics['issues'] != null && (diagnostics['issues'] as List).isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildIssuesCard(diagnostics['issues']),
        ],
        const SizedBox(height: 16),
        _buildDetailsCard(diagnostics),
      ],
    );
  }

  Widget _buildStatusCard(String title, bool isOk, String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOk ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(
          color: isOk ? Colors.green : Colors.red,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            isOk ? Icons.check_circle : Icons.error,
            color: isOk ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            status,
            style: TextStyle(
              color: isOk ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivityCard(Map<String, dynamic> connectivity) {
    final isOk = connectivity['status'] == 'success';
    final status = connectivity['status'] ?? 'unknown';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOk ? Colors.green.shade50 : Colors.orange.shade50,
        border: Border.all(
          color: isOk ? Colors.green : Colors.orange,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            isOk ? Icons.wifi : Icons.wifi_off,
            color: isOk ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Conectividade',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            status,
            style: TextStyle(
              color: isOk ? Colors.green.shade700 : Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesCard(List<dynamic> issues) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Problemas Detectados',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...issues.map((issue) => Padding(
                padding: const EdgeInsets.only(left: 28, bottom: 4),
                child: Text(
                  '• $issue',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> diagnostics) {
    return ExpansionTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Detalhes Técnicos'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plataforma: ${diagnostics['platform'] ?? 'unknown'}'),
              Text('Timestamp: ${diagnostics['timestamp'] ?? 'unknown'}'),
              if (diagnostics['apiKey'] != null)
                Text('API Key: ${diagnostics['apiKey']['value'] ?? 'not_configured'}'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  GoogleMapsConfig.retryInitialization();
                  _runDiagnostics();
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}