# Script para configurar ambiente de produção
# Configura variáveis, otimiza assets e prepara para deploy

Write-Host "🚀 Configurando Ambiente de Produção - Taste App" -ForegroundColor Cyan
Write-Host "" 

# Função para verificar se comando existe
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Verificar dependências
Write-Host "🔍 Verificando dependências..." -ForegroundColor Yellow

$missingDeps = @()

if (-not (Test-Command "flutter")) {
    $missingDeps += "Flutter SDK"
}

if (-not (Test-Command "dart")) {
    $missingDeps += "Dart SDK"
}

if ($missingDeps.Count -gt 0) {
    Write-Host "❌ Dependências faltando: $($missingDeps -join ', ')" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Todas as dependências encontradas" -ForegroundColor Green
Write-Host "" 

# 1. Configurar variáveis de produção
Write-Host "⚙️  Configurando variáveis de produção..." -ForegroundColor Cyan

# Verificar se arquivo .env.production existe
if (-not (Test-Path ".env.production")) {
    Write-Host "❌ Arquivo .env.production não encontrado" -ForegroundColor Red
    Write-Host "📝 Criando arquivo de exemplo..." -ForegroundColor Yellow
    
    $envContent = @"
# Production Environment Configuration
ENVIRONMENT=production

# Supabase Configuration (Production)
SUPABASE_URL=YOUR_PRODUCTION_SUPABASE_URL
SUPABASE_ANON_KEY=YOUR_PRODUCTION_SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=YOUR_PRODUCTION_SERVICE_ROLE_KEY

# Google Maps API Key (Production)
GOOGLE_MAPS_API_KEY=YOUR_PRODUCTION_GOOGLE_MAPS_API_KEY

# OpenAI API Configuration (Production)
OPENAI_API_KEY=YOUR_PRODUCTION_OPENAI_API_KEY
OPENAI_MODEL=gpt-3.5-turbo

# Analytics and Monitoring
ANALYTICS_ENABLED=true
CRASH_REPORTING_ENABLED=true

# Performance Settings
CACHE_DURATION_HOURS=24
MAX_CACHE_SIZE_MB=100
IMAGE_CACHE_DURATION_DAYS=7

# Feature Flags
ENABLE_OFFLINE_MODE=true
ENABLE_PUSH_NOTIFICATIONS=false
ENABLE_SOCIAL_LOGIN=false
"@
    
    $envContent | Out-File -FilePath ".env.production" -Encoding UTF8
    Write-Host "✅ Arquivo .env.production criado" -ForegroundColor Green
    Write-Host "⚠️  IMPORTANTE: Preencha com suas chaves de produção!" -ForegroundColor Yellow
}

# 2. Limpar cache e dependências
Write-Host "🧹 Limpando cache e dependências..." -ForegroundColor Cyan

try {
    flutter clean
    Write-Host "✅ Flutter clean executado" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no flutter clean: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    flutter pub get
    Write-Host "✅ Dependências atualizadas" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao atualizar dependências: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Otimizar assets
Write-Host "🎨 Otimizando assets..." -ForegroundColor Cyan

# Verificar se existem imagens para otimizar
$imageExtensions = @("*.png", "*.jpg", "*.jpeg", "*.webp")
$imagePaths = @("assets/images", "assets/icons", "store_assets")

foreach ($path in $imagePaths) {
    if (Test-Path $path) {
        $images = Get-ChildItem -Path $path -Include $imageExtensions -Recurse
        if ($images.Count -gt 0) {
            Write-Host "📁 Encontradas $($images.Count) imagens em $path" -ForegroundColor White
            
            # Aqui você pode adicionar otimização de imagens se tiver ferramentas instaladas
            # Por exemplo: imagemin, tinypng-cli, etc.
        }
    }
}

# 4. Verificar configurações de build
Write-Host "🔧 Verificando configurações de build..." -ForegroundColor Cyan

# Verificar pubspec.yaml
if (Test-Path "pubspec.yaml") {
    $pubspec = Get-Content "pubspec.yaml" -Raw
    
    # Verificar versão
    if ($pubspec -match "version:\s*([\d\.]+)\+([\d]+)") {
        $version = $matches[1]
        $buildNumber = $matches[2]
        Write-Host "📦 Versão atual: $version ($buildNumber)" -ForegroundColor White
        
        # Sugerir incremento de versão para produção
        $newBuildNumber = [int]$buildNumber + 1
        Write-Host "💡 Sugestão: Incremente para $version+$newBuildNumber" -ForegroundColor Yellow
    }
}

# 5. Verificar configurações de signing
Write-Host "🔐 Verificando configurações de signing..." -ForegroundColor Cyan

# Android
if (Test-Path "android/key.properties") {
    Write-Host "✅ Configurações de signing Android encontradas" -ForegroundColor Green
} else {
    Write-Host "⚠️  Configurações de signing Android não encontradas" -ForegroundColor Yellow
    Write-Host "💡 Execute: .\scripts\generate_keystore.ps1" -ForegroundColor Gray
}

# iOS (verificar se existem certificados)
if (Test-Path "ios/Runner.xcodeproj") {
    Write-Host "✅ Projeto iOS encontrado" -ForegroundColor Green
    Write-Host "💡 Configure signing no Xcode antes do build" -ForegroundColor Yellow
}

# 6. Executar análise de código
Write-Host "🔍 Executando análise de código..." -ForegroundColor Cyan

try {
    flutter analyze
    Write-Host "✅ Análise de código concluída" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Problemas encontrados na análise de código" -ForegroundColor Yellow
}

# 7. Executar testes
Write-Host "🧪 Executando testes..." -ForegroundColor Cyan

try {
    flutter test
    Write-Host "✅ Testes executados com sucesso" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Alguns testes falharam" -ForegroundColor Yellow
    Write-Host "💡 Verifique os testes antes do deploy" -ForegroundColor Gray
}

# 8. Preparar comandos de build
Write-Host "" 
Write-Host "📋 Comandos para build de produção:" -ForegroundColor Yellow
Write-Host "" 

Write-Host "📱 Android (APK):" -ForegroundColor Cyan
Write-Host "flutter build apk --release --flavor production --dart-define=ENVIRONMENT=production" -ForegroundColor Gray
Write-Host "" 

Write-Host "📱 Android (Bundle):" -ForegroundColor Cyan
Write-Host "flutter build appbundle --release --flavor production --dart-define=ENVIRONMENT=production" -ForegroundColor Gray
Write-Host "" 

Write-Host "🍎 iOS:" -ForegroundColor Cyan
Write-Host "flutter build ios --release --flavor production --dart-define=ENVIRONMENT=production" -ForegroundColor Gray
Write-Host "" 

Write-Host "🌐 Web:" -ForegroundColor Cyan
Write-Host "flutter build web --release --dart-define=ENVIRONMENT=production" -ForegroundColor Gray
Write-Host "" 

# 9. Checklist final
Write-Host "✅ Checklist de Produção:" -ForegroundColor Green
Write-Host "" 

$checklist = @(
    "Variáveis de produção configuradas (.env.production)",
    "Chaves de API de produção configuradas",
    "Keystore Android gerado e configurado",
    "Certificados iOS configurados no Xcode",
    "Versão incrementada no pubspec.yaml",
    "Análise de código sem erros críticos",
    "Testes passando",
    "Assets otimizados",
    "Descrições das lojas preparadas",
    "Screenshots capturados"
)

foreach ($item in $checklist) {
    Write-Host "  ☐ $item" -ForegroundColor White
}

Write-Host "" 
Write-Host "🚀 Configuração de produção concluída!" -ForegroundColor Cyan
Write-Host "💡 Revise o checklist antes de fazer o build final" -ForegroundColor Yellow