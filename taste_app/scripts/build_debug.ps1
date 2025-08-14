# Script para build de desenvolvimento/debug
# PowerShell script para Windows

Write-Host "🔨 Iniciando build de desenvolvimento..." -ForegroundColor Green

# Limpa builds anteriores
Write-Host "🧹 Limpando builds anteriores..." -ForegroundColor Yellow
flutter clean

# Instala dependências
Write-Host "📦 Instalando dependências..." -ForegroundColor Yellow
flutter pub get

# Gera código necessário
Write-Host "⚙️ Gerando código..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build para desenvolvimento
Write-Host "🏗️ Compilando para desenvolvimento..." -ForegroundColor Yellow

# Web Debug
Write-Host "🌐 Build Web (Debug)..." -ForegroundColor Cyan
flutter build web --debug --dart-define=ENVIRONMENT=development

# Android Debug (se disponível)
if (Get-Command "flutter" -ErrorAction SilentlyContinue) {
    Write-Host "📱 Build Android (Debug)..." -ForegroundColor Cyan
    flutter build apk --debug --dart-define=ENVIRONMENT=development
}

Write-Host "✅ Build de desenvolvimento concluído!" -ForegroundColor Green
Write-Host "📁 Arquivos gerados em:" -ForegroundColor White
Write-Host "   - Web: build/web/" -ForegroundColor Gray
Write-Host "   - Android: build/app/outputs/flutter-apk/" -ForegroundColor Gray