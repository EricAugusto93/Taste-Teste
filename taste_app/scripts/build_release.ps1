# Script para build de produção/release
# PowerShell script para Windows

Write-Host "🚀 Iniciando build de produção..." -ForegroundColor Green

# Limpa builds anteriores
Write-Host "🧹 Limpando builds anteriores..." -ForegroundColor Yellow
flutter clean

# Instala dependências
Write-Host "📦 Instalando dependências..." -ForegroundColor Yellow
flutter pub get

# Gera código necessário
Write-Host "⚙️ Gerando código..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs

# Executa testes
Write-Host "🧪 Executando testes..." -ForegroundColor Yellow
flutter test

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Testes falharam! Build cancelado." -ForegroundColor Red
    exit 1
}

# Analisa código
Write-Host "🔍 Analisando código..." -ForegroundColor Yellow
flutter analyze

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Problemas encontrados na análise do código!" -ForegroundColor Yellow
    $continue = Read-Host "Continuar mesmo assim? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Host "❌ Build cancelado pelo usuário." -ForegroundColor Red
        exit 1
    }
}

# Build para produção
Write-Host "🏗️ Compilando para produção..." -ForegroundColor Yellow

# Web Release
Write-Host "🌐 Build Web (Release)..." -ForegroundColor Cyan
flutter build web --release --dart-define=ENVIRONMENT=production

# Android Release (se disponível)
if (Get-Command "flutter" -ErrorAction SilentlyContinue) {
    Write-Host "📱 Build Android (Release)..." -ForegroundColor Cyan
    flutter build apk --release --dart-define=ENVIRONMENT=production
    
    # App Bundle para Google Play
    Write-Host "📦 Build Android App Bundle..." -ForegroundColor Cyan
    flutter build appbundle --release --dart-define=ENVIRONMENT=production
}

# Gera relatório de tamanho
Write-Host "📊 Gerando relatório de tamanho..." -ForegroundColor Yellow
flutter build web --analyze-size --dart-define=ENVIRONMENT=production

Write-Host "✅ Build de produção concluído!" -ForegroundColor Green
Write-Host "📁 Arquivos gerados em:" -ForegroundColor White
Write-Host "   - Web: build/web/" -ForegroundColor Gray
Write-Host "   - Android APK: build/app/outputs/flutter-apk/" -ForegroundColor Gray
Write-Host "   - Android Bundle: build/app/outputs/bundle/release/" -ForegroundColor Gray

Write-Host "🎉 Pronto para