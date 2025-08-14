import 'dart:io';
import 'dart:math';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('Arquivo de cobertura não encontrado!');
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

  print('\n=== RELATÓRIO DE COBERTURA DE TESTES ===\n');
  print('Cobertura Geral: $overallPercentage% ($totalCovered/$totalLines linhas)');
  print('\n=== ARQUIVOS COM BAIXA COBERTURA (<80%) ===\n');

  final lowCoverage = reports.where((r) => r.percentage < 80).toList();
  if (lowCoverage.isEmpty) {
    print('✅ Todos os arquivos têm cobertura >= 80%!');
  } else {
    for (final report in lowCoverage) {
      final status = report.percentage < 50 ? '🔴' : '🟡';
      print('$status ${report.file}: ${report.percentage}% (${report.covered}/${report.total})');
    }
  }

  print('\n=== ARQUIVOS COM BOA COBERTURA (>=80%) ===\n');
  final goodCoverage = reports.where((r) => r.percentage >= 80).toList();
  for (final report in goodCoverage) {
    print('✅ ${report.file}: ${report.percentage}% (${report.covered}/${report.total})');
  }

  print('\n=== RESUMO POR CATEGORIA ===\n');
  
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
      print('$category: $avgCoverage% média (${files.length} arquivos)');
    }
  });

  print('\n=== RECOMENDAÇÕES ===\n');
  if (overallPercentage < 85) {
    print('🎯 Meta: Atingir 85% de cobertura geral');
    print('📈 Atual: $overallPercentage%');
    print('📊 Faltam: ${((totalLines * 0.85) - totalCovered).round()} linhas para cobrir');
  } else {
    print('🎉 Meta de 85% de cobertura atingida!');
  }

  if (lowCoverage.isNotEmpty) {
    print('\n🔧 Priorizar testes para:');
    lowCoverage.take(5).forEach((report) {
      print('   • ${report.file} (${report.percentage}%)');
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