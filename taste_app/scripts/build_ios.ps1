#!/usr/bin/env pwsh
# Script para build do iOS em diferentes ambientes

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('development', 'staging', 'production')]
    [string]$Environment = 'development',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('debug', 'release', 'profile')]
    [string]$BuildType = 'debug',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('simulator', 'device')]
    [string]$Target = 'simulator',
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean,
    
    [Parameter(Mandatory=$false)]
    [switch]$Archive,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# Cores para output
$Red = "\033[31m"
$Green = "\033[32m"
$Yellow = "\033[33m"
$Blue = "\033[34m"
$Reset = "\033[0m"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = $Reset)
    Write-Host "$Color$Message$Reset"
}

function Show-Header {
    Write-ColorOutput "" $Blue
    Write-ColorOutput "🍎 Taste iOS Build Script" $Blue
    Write-ColorOutput "==========================" $Blue
    Write-ColorOutput "Environment: $Environment" $Green
    Write-ColorOutput "Build Type: $BuildType" $Green
    Write-ColorOutput "Target: $Target" $Green
    Write-ColorOutput "Clean Build: $($Clean.IsPresent)" $Green
    Write-ColorOutput "Archive: $($Archive.IsPresent)" $Green
    Write-ColorOutput "" $Blue
}

function Test-Prerequisites {
    Write-ColorOutput "🔍 Verificando pré-requisitos..." $Yellow
    
    # Verifica se Flutter está instalado
    try {
        $flutterVersion = flutter --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter não encontrado"
        }
        Write-ColorOutput "✅ Flutter encontrado" $Green
    }
    catch {
        Write-ColorOutput "❌ Flutter não está instalado ou não está no PATH" $Red
        exit 1
    }
    
    # Verifica se Xcode está disponível (apenas no macOS)
    if ($IsMacOS) {
        try {
            $xcodeVersion = xcodebuild -version 2>$null
            if ($LASTEXITCODE -ne 0) {
                throw "Xcode não encontrado"
            }
            Write-ColorOutput "✅ Xcode encontrado" $Green
        }
        catch {
            Write-ColorOutput "❌ Xcode não está instalado" $Red
            exit 1
        }
    } else {
        Write-ColorOutput "⚠️  Build iOS disponível apenas no macOS" $Yellow
        Write-ColorOutput "   Continuando com verificações básicas..." $Yellow
    }
    
    # Verifica se está no diretório correto
    if (!(Test-Path "pubspec.yaml")) {
        Write-ColorOutput "❌ Execute o script no diretório raiz do projeto Flutter" $Red
        exit 1
    }
    
    # Verifica se o diretório iOS existe
    if (!(Test-Path "ios")) {
        Write-ColorOutput "❌ Diretório iOS não encontrado" $Red
        exit 1
    }
    
    Write-ColorOutput "✅ Pré-requisitos verificados" $Green
}

function Invoke-CleanBuild {
    if ($Clean) {
        Write-ColorOutput "🧹 Limpando build anterior..." $Yellow
        flutter clean
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ Erro ao limpar build" $Red
            exit 1
        }
        
        # Limpa também o build do Xcode
        if ($IsMacOS -and (Test-Path "ios/build")) {
            Remove-Item -Recurse -Force "ios/build"
        }
        
        Write-ColorOutput "✅ Build limpo" $Green
    }
}

function Get-Dependencies {
    Write-ColorOutput "📦 Obtendo dependências..." $Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Erro ao obter dependências" $Red
        exit 1
    }
    
    # Instala pods do iOS
    if ($IsMacOS) {
        Write-ColorOutput "📦 Instalando CocoaPods..." $Yellow
        Set-Location "ios"
        pod install
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ Erro ao instalar pods" $Red
            Set-Location ".."
            exit 1
        }
        Set-Location ".."
    }
    
    Write-ColorOutput "✅ Dependências obtidas" $Green
}

function Start-Build {
    Write-ColorOutput "🔨 Iniciando build..." $Yellow
    
    if (!$IsMacOS) {
        Write-ColorOutput "❌ Build iOS só é possível no macOS" $Red
        exit 1
    }
    
    # Constrói o comando de build
    if ($Archive) {
        $buildCommand = "flutter build ipa"
    } else {
        $buildCommand = "flutter build ios"
    }
    
    # Adiciona tipo de build
    if ($BuildType -eq "debug") {
        $buildCommand += " --debug"
    } elseif ($BuildType -eq "release") {
        $buildCommand += " --release"
    } elseif ($BuildType -eq "profile") {
        $buildCommand += " --profile"
    }
    
    # Adiciona target
    if ($Target -eq "simulator") {
        $buildCommand += " --simulator"
    }
    
    # Adiciona dart-define para ambiente
    $buildCommand += " --dart-define=ENVIRONMENT=$Environment"
    $buildCommand += " --dart-define=DEBUG=$($BuildType -eq 'debug')"
    
    # Adiciona verbose se solicitado
    if ($Verbose) {
        $buildCommand += " --verbose"
    }
    
    Write-ColorOutput "Executando: $buildCommand" $Blue
    
    # Executa o build
    Invoke-Expression $buildCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Erro no build" $Red
        exit 1
    }
    
    Write-ColorOutput "✅ Build concluído com sucesso" $Green
}

function Show-BuildInfo {
    Write-ColorOutput "" $Blue
    Write-ColorOutput "📋 Informações do Build" $Blue
    Write-ColorOutput "========================" $Blue
    
    if ($Archive) {
        # Procura pelo arquivo IPA
        $ipaPath = "build/ios/ipa/*.ipa"
        $ipaFiles = Get-ChildItem $ipaPath -ErrorAction SilentlyContinue
        
        if ($ipaFiles) {
            $ipaFile = $ipaFiles[0]
            $ipaSize = $ipaFile.Length / 1MB
            Write-ColorOutput "📁 IPA: $($ipaFile.FullName)" $Green
            Write-ColorOutput "📏 Tamanho: $([math]::Round($ipaSize, 2)) MB" $Green
        }
    } else {
        # Procura pelo app
        $appPath = "build/ios/iphonesimulator/Runner.app"
        if ($Target -eq "device") {
            $appPath = "build/ios/iphoneos/Runner.app"
        }
        
        if (Test-Path $appPath) {
            Write-ColorOutput "📁 App: $appPath" $Green
        }
    }
    
    Write-ColorOutput "🏷️  Environment: $Environment" $Green
    Write-ColorOutput "🔧 Build Type: $BuildType" $Green
    Write-ColorOutput "🎯 Target: $Target" $Green
    Write-ColorOutput "" $Blue
}

function Show-NextSteps {
    Write-ColorOutput "📝 Próximos Passos" $Blue
    Write-ColorOutput "==================" $Blue
    
    if ($Archive) {
        Write-ColorOutput "1. O arquivo IPA foi gerado em build/ios/ipa/" $Yellow
        Write-ColorOutput "2. Você pode fazer upload para TestFlight ou App Store" $Yellow
        Write-ColorOutput "3. Use Xcode Organizer ou Transporter para upload" $Yellow
    } else {
        Write-ColorOutput "1. Para testar no simulador: flutter run --flavor $Environment" $Yellow
        Write-ColorOutput "2. Para testar em dispositivo: flutter run --flavor $Environment --release" $Yellow
        Write-ColorOutput "3. Para gerar IPA: execute com --Archive" $Yellow
    }
    
    Write-ColorOutput "" $Blue
}

function Main {
    try {
        Show-Header
        Test-Prerequisites
        Invoke-CleanBuild
        Get-Dependencies
        Start-Build
        Show-BuildInfo
        Show-NextSteps
        
        Write-ColorOutput "🎉 Build concluído com sucesso!" $Green
    }
    catch {
        Write-ColorOutput "❌ Erro durante o build: $_" $Red
        exit 1
    }
}

# Executa o script principal
Main