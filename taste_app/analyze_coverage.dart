import 'dart:io';
import 'package:flutter/foundation.dart';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    debugPrint('Arquivo de cobertura não encontrado!'); // Mantém print para scripts de análise
    return;
  }

  final lines = file.readAsLinesSync();
  final Map<String, CoverageData> coverage = {};
  String? currentFile;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll('\\', '/');
      coverage[currentFile] = CoverageData();
    } else if (line.startsWith('LF:') && currentFile != null) {
      coverage[currentFile]!.totalLines = int.parse(line.substring(3));
    } else if (line.startsWith('LH:') && currentFile != null) {
      coverage[currentFile]!.coveredLines = int.parse(line.substring(3));
    }
  }

  // Calcular estatísticas gerais
  int totalLines = 0;
  int totalCovered = 0;
  final List<FileReport> reports = [];

  coverage.forEach((file, data) {
    if (file.startsWith('lib/')) {
      totalLines += data.totalLines;
      totalCovered += data.coveredLines;
      final percentage = data.totalLines > 0 
          ? (data.coveredLines / data.totalLines * 100).round()
          : 0;
      reports.add(FileReport(file, percentage, data.coveredLines, data.totalLines));
    }
  });

  final overallPercentage = totalLines > 0 
      ? (totalCovered / totalLines * 100).round()
      : 0;

  // Ordenar por cobertura (menor primeiro)
  reports.sort((a, b) => a.percentage.compareTo(b.percentage));

  debugPrint('\n=== RELATÓRIO DE COBERTURA DE TESTES ===\n');
  debugPrint('Cobertura Geral: $overallPercentage% ($totalCovered/$totalLines linhas)');
  debugPrint('\n=== ARQUIVOS COM BAIXA COBERTURA (<80%) ===\n');

  final lowCoverage = reports.where((r) => r.percentage < 80).toList();
  if (lowCoverage.isEmpty) {
    debugPrint('✅ Todos os arquivos têm cobertura >= 80%!');
  } else {
    for (final report in lowCoverage) {
      final status = report.percentage < 50 ? '🔴' : '🟡';
      debugPrint('$status ${report.file}: ${report.percentage}% (${report.covered}/${report.total})');
    }
  }

  debugPrint('\n=== ARQUIVOS COM BOA COBERTURA (>=80%) ===\n');
  final goodCoverage = reports.where((r) => r.percentage >= 80).toList();
  for (final report in goodCoverage) {
    debugPrint('✅ ${report.file}: ${report.percentage}% (${report.covered}/${report.total})');
  }

  debugPrint('\n=== RESUMO POR CATEGORIA ===\n');
  
  final categories = {
    'Models': reports.where((r) => r.file.contains('/models/')),
    'Repositories': reports.where((r) => r.file.contains('/repositories/')),
    'Providers': reports.where((r) => r.file.contains('/providers/')),
    'Services': reports.where((r) => r.file.contains('/services/')),
    'Pages': reports.where((r) => r.file.contains('/pages/')),
    'Widgets': reports.where((r) => r.file.contains('/widgets/')),
  };

  categories.forEach((category, files) {
    if (files.isNotEmpty) {
      final avgCoverage = files.map((f) => f.percentage).reduce((a, b) => a + b) ~/ files.length;
      debugPrint('$category: $avgCoverage% média (${files.length} arquivos)');
    }
  });

  debugPrint('\n=== RECOMENDAÇÕES ===\n');
  if (overallPercentage < 85) {
    debugPrint('🎯 Meta: Atingir 85% de cobertura geral');
    debugPrint('📈 Atual: $overallPercentage%');
    debugPrint('📊 Faltam: ${((totalLines * 0.85) - totalCovered).round()} linhas para cobrir');
  } else {
    debugPrint('🎉 Meta de 85% de cobertura atingida!');
  }

  if (lowCoverage.isNotEmpty) {
    debugPrint('\n🔧 Priorizar testes para:');
    lowCoverage.take(5).forEach((report) {
      debugPrint('   • ${report.file} (${report.percentage}%)');
    });
  }
}

class CoverageData {
  int totalLines = 0;
  int coveredLines = 0;
}

class FileReport {
  final String file;
  final int percentage;
  final int covered;
  final int total;

  FileReport(this.file, this.percentage, this.covered, this.total);
}