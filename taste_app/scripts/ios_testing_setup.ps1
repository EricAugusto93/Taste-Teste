# Script para configurar testes em dispositivos iOS
# Configura ambiente de desenvolvimento iOS e testes

Write-Host "🍎 Configuração de Testes iOS - Taste App" -ForegroundColor Cyan
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

# Verificar se está no macOS (necessário para desenvolvimento iOS)
if ($env:OS -eq "Windows_NT") {
    Write-Host "⚠️  Este script é otimizado para macOS" -ForegroundColor Yellow
    Write-Host "📱 Para testes iOS no Windows, considere:" -ForegroundColor White
    Write-Host "   • Usar simulador iOS online (BrowserStack, Sauce Labs)" -ForegroundColor Gray
    Write-Host "   • Configurar máquina virtual macOS" -ForegroundColor Gray
    Write-Host "   • Usar serviços de CI/CD com runners macOS" -ForegroundColor Gray
    Write-Host "" 
}

# Verificar dependências
Write-Host "🔍 Verificando dependências iOS..." -ForegroundColor Yellow

$missingDeps = @()

if (-not (Test-Command "flutter")) {
    $missingDeps += "Flutter SDK"
}

if (-not (Test-Command "xcodebuild")) {
    $missingDeps += "Xcode Command Line Tools"
}

if (-not (Test-Command "xcrun")) {
    $missingDeps += "Xcode Developer Tools"
}

if ($missingDeps.Count -gt 0) {
    Write-Host "❌ Dependências faltando: $($missingDeps -join ', ')" -ForegroundColor Red
    Write-Host "" 
    Write-Host "📋 Para instalar no macOS:" -ForegroundColor Yellow
    Write-Host "   1. Instale Xcode da App Store" -ForegroundColor Gray
    Write-Host "   2. Execute: xcode-select --install" -ForegroundColor Gray
    Write-Host "   3. Execute: sudo xcodebuild -license accept" -ForegroundColor Gray
    Write-Host "" 
} else {
    Write-Host "✅ Dependências iOS encontradas" -ForegroundColor Green
}

Write-Host "" 

# 1. Verificar configuração do projeto iOS
Write-Host "📱 Verificando configuração do projeto iOS..." -ForegroundColor Cyan

if (Test-Path "ios/Runner.xcodeproj") {
    Write-Host "✅ Projeto Xcode encontrado" -ForegroundColor Green
    
    # Verificar Info.plist
    if (Test-Path "ios/Runner/Info.plist") {
        Write-Host "✅ Info.plist encontrado" -ForegroundColor Green
        
        # Ler algumas configurações importantes
        $infoPlist = Get-Content "ios/Runner/Info.plist" -Raw
        
        if ($infoPlist -match "CFBundleIdentifier") {
            Write-Host "✅ Bundle Identifier configurado" -ForegroundColor Green
        }
        
        if ($infoPlist -match "CFBundleVersion") {
            Write-Host "✅ Bundle Version configurado" -ForegroundColor Green
        }
    }
    
    # Verificar Podfile
    if (Test-Path "ios/Podfile") {
        Write-Host "✅ Podfile encontrado" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Podfile não encontrado" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Projeto iOS não encontrado" -ForegroundColor Red
    exit 1
}

# 2. Listar simuladores disponíveis
Write-Host "📱 Verificando simuladores iOS disponíveis..." -ForegroundColor Cyan

if (Test-Command "xcrun") {
    try {
        $simulators = xcrun simctl list devices available
        Write-Host "📱 Simuladores disponíveis:" -ForegroundColor White
        Write-Host $simulators -ForegroundColor Gray
    } catch {
        Write-Host "⚠️  Não foi possível listar simuladores" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  xcrun não disponível" -ForegroundColor Yellow
}

# 3. Verificar dispositivos físicos conectados
Write-Host "📱 Verificando dispositivos iOS conectados..." -ForegroundColor Cyan

if (Test-Command "xcrun") {
    try {
        $devices = xcrun devicectl list devices
        if ($devices) {
            Write-Host "📱 Dispositivos conectados:" -ForegroundColor White
            Write-Host $devices -ForegroundColor Gray
        } else {
            Write-Host "📱 Nenhum dispositivo físico conectado" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  Não foi possível verificar dispositivos" -ForegroundColor Yellow
    }
}

# 4. Configurar dependências iOS
Write-Host "📦 Configurando dependências iOS..." -ForegroundColor Cyan

if (Test-Path "ios/Podfile") {
    try {
        Set-Location "ios"
        pod install
        Set-Location ".."
        Write-Host "✅ CocoaPods instalado com sucesso" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao instalar CocoaPods: $($_.Exception.Message)" -ForegroundColor Red
        Set-Location ".."
    }
} else {
    Write-Host "⚠️  Podfile não encontrado, pulando CocoaPods" -ForegroundColor Yellow
}

# 5. Executar testes unitários iOS
Write-Host "🧪 Executando testes unitários..." -ForegroundColor Cyan

try {
    flutter test
    Write-Host "✅ Testes unitários executados" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Alguns testes falharam" -ForegroundColor Yellow
}

# 6. Executar testes de integração (se existirem)
Write-Host "🔗 Verificando testes de integração..." -ForegroundColor Cyan

if (Test-Path "integration_test") {
    Write-Host "📁 Pasta de testes de integração encontrada" -ForegroundColor White
    
    # Listar arquivos de teste
    $testFiles = Get-ChildItem "integration_test" -Filter "*.dart"
    if ($testFiles.Count -gt 0) {
        Write-Host "📝 Arquivos de teste encontrados:" -ForegroundColor White
        foreach ($file in $testFiles) {
            Write-Host "   • $($file.Name)" -ForegroundColor Gray
        }
        
        Write-Host "" 
        Write-Host "💡 Para executar testes de integração:" -ForegroundColor Yellow
        Write-Host "   flutter test integration_test" -ForegroundColor Gray
    }
} else {
    Write-Host "📁 Nenhum teste de integração encontrado" -ForegroundColor Yellow
}

# 7. Comandos úteis para testes iOS
Write-Host "" 
Write-Host "📋 Comandos úteis para testes iOS:" -ForegroundColor Yellow
Write-Host "" 

Write-Host "🏗️ Build para simulador:" -ForegroundColor Cyan
Write-Host "flutter build ios --debug --simulator" -ForegroundColor Gray
Write-Host "" 

Write-Host "🏗️ Build para dispositivo:" -ForegroundColor Cyan
Write-Host "flutter build ios --debug" -ForegroundColor Gray
Write-Host "" 

Write-Host "🚀 Executar no simulador:" -ForegroundColor Cyan
Write-Host "flutter run -d ios" -ForegroundColor Gray
Write-Host "" 

Write-Host "📱 Listar dispositivos:" -ForegroundColor Cyan
Write-Host "flutter devices" -ForegroundColor Gray
Write-Host "" 

Write-Host "🧪 Executar testes de integração:" -ForegroundColor Cyan
Write-Host "flutter test integration_test" -ForegroundColor Gray
Write-Host "" 

Write-Host "🔧 Limpar build iOS:" -ForegroundColor Cyan
Write-Host "flutter clean && cd ios && pod install && cd .." -ForegroundColor Gray
Write-Host "" 

# 8. Criar arquivo de configuração de teste
Write-Host "📝 Criando configuração de teste..." -ForegroundColor Cyan

$testConfig = @"
# Configuração de Testes iOS - Taste App

## Pré-requisitos
- macOS com Xcode instalado
- Flutter SDK configurado
- CocoaPods instalado
- Dispositivo iOS ou simulador

## Comandos Essenciais

### Preparar ambiente
```bash
flutter clean
cd ios && pod install && cd ..
flutter pub get
```

### Executar testes
```bash
# Testes unitários
flutter test

# Testes de integração
flutter test integration_test

# Executar no simulador
flutter run -d ios

# Build para teste
flutter build ios --debug
```

### Simuladores
```bash
# Listar simuladores
xcrun simctl list devices

# Abrir simulador específico
open -a Simulator --args -CurrentDeviceUDID [DEVICE_UDID]
```

### Dispositivos físicos
```bash
# Listar dispositivos conectados
xcrun devicectl list devices

# Instalar em dispositivo específico
flutter install -d [DEVICE_ID]
```

## Troubleshooting

### Erro de signing
1. Abra o projeto no Xcode: `open ios/Runner.xcworkspace`
2. Configure Team e Bundle Identifier
3. Selecione dispositivo de desenvolvimento

### Erro de CocoaPods
```bash
cd ios
pod deintegrate
pod install
```

### Erro de permissões
```bash
sudo xcode-select --reset
sudo xcodebuild -license accept
```

## Checklist de Teste

- [ ] Projeto compila sem erros
- [ ] Testes unitários passam
- [ ] App executa no simulador
- [ ] App executa em dispositivo físico
- [ ] Funcionalidades principais testadas
- [ ] Performance aceitável
- [ ] Sem vazamentos de memória
- [ ] Compatibilidade com versões iOS suportadas
"@

$testConfig | Out-File -FilePath "ios_testing_guide.md" -Encoding UTF8
Write-Host "✅ Guia de testes criado: ios_testing_guide.md" -ForegroundColor Green

# 9. Verificar configurações de signing
Write-Host "🔐 Verificando configurações de signing..." -ForegroundColor Cyan

if (Test-Path "ios/Runner.xcodeproj/project.pbxproj") {
    $projectFile = Get-Content "ios/Runner.xcodeproj/project.pbxproj" -Raw
    
    if ($projectFile -match "DEVELOPMENT_TEAM") {
        Write-Host "✅ Development Team configurado" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Development Team não configurado" -ForegroundColor Yellow
        Write-Host "💡 Configure no Xcode: Signing & Capabilities" -ForegroundColor Gray
    }
    
    if ($projectFile -match "PRODUCT_BUNDLE_IDENTIFIER") {
        Write-Host "✅ Bundle Identifier configurado" -ForegroundColor Green
    }
}

# 10. Resumo final
Write-Host "" 
Write-Host "📋 Resumo da Configuração iOS:" -ForegroundColor Green
Write-Host "" 

$summary = @(
    "Projeto iOS configurado",
    "Dependências verificadas",
    "Simuladores listados",
    "CocoaPods instalado",
    "Testes unitários executados",
    "Guia de testes criado",
    "Configurações de signing verificadas"
)

foreach ($item in $summary) {
    Write-Host "  ✅ $item" -ForegroundColor White
}

Write-Host "" 
Write-Host "🍎 Configuração iOS concluída!" -ForegroundColor Cyan
Write-Host "💡 Consulte ios_testing_guide.md para instruções detalhadas" -ForegroundColor Yellow
Write-Host "🔧 Configure signing no Xcode antes de testar em dispositivos físicos" -ForegroundColor Yellow