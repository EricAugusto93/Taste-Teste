#!/usr/bin/env pwsh
# Script para corrigir e testar o startup do Gastro App

Write-Host "🔧 Gastro App - Script de Correção e Startup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Verificar se estamos no diretório correto
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "❌ Execute este script no diretório gastro_app/" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 Etapa 1: Limpando cache e dependências..." -ForegroundColor Yellow

# Limpar cache Flutter
Write-Host "   🧹 Limpando cache Flutter..."
flutter clean

# Buscar dependências
Write-Host "   📦 Instalando dependências..."
flutter pub get

Write-Host ""
Write-Host "📋 Etapa 2: Verificando configurações..." -ForegroundColor Yellow

# Verificar arquivo .env
if (Test-Path ".env") {
    Write-Host "   ✅ Arquivo .env encontrado" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Arquivo .env não encontrado, usando valores padrão" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Etapa 3: Testando compilação..." -ForegroundColor Yellow

# Testar análise de código
Write-Host "   🔍 Analisando código..."
$analyzeResult = flutter analyze
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Análise de código passou" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Avisos na análise de código (pode ser normal)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Etapa 4: Iniciando aplicação..." -ForegroundColor Yellow

Write-Host "   🚀 Executando flutter run para web..."
Write-Host "   📱 Acesse: http://localhost:8080" -ForegroundColor Cyan
Write-Host ""

# Executar o app
flutter run -d web-server --web-port 8080 --web-hostname localhost

Write-Host ""
Write-Host "✨ Script concluído!" -ForegroundColor Green 