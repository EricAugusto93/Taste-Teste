#!/usr/bin/env pwsh
# Script para testar a correção do erro "Erro ao obter dados do usuário"

Write-Host "🔧 Teste da Correção: Erro ao obter dados do usuário" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

# Verificar se estamos no diretório correto
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "❌ Execute este script no diretório gastro_app/" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 Etapa 1: Limpando cache..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "📋 Etapa 2: Instalando dependências..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "📋 Etapa 3: Verificando análise de código..." -ForegroundColor Yellow
$analyzeResult = flutter analyze
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Análise passou" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Avisos encontrados (normal)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Etapa 4: Executando aplicação..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🔍 Procure pelos seguintes logs no console:" -ForegroundColor Cyan
Write-Host "   • 🔄 Usuário não encontrado na tabela, sincronizando..." -ForegroundColor White
Write-Host "   • ✅ Usuário sincronizado: email@exemplo.com" -ForegroundColor White
Write-Host ""
Write-Host "📱 Acesse: http://localhost:8080" -ForegroundColor Green
Write-Host "🎯 Faça login e verifique se o erro foi corrigido" -ForegroundColor Green
Write-Host ""

# Executar o app
flutter run -d web-server --web-port 8080 --web-hostname localhost 