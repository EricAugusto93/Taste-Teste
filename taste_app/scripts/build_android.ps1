#!/usr/bin/env pwsh
# Script para build do Android em diferentes ambientes

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('development', 'staging', 'production')]
    [string]$Environment = 'development',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('debug', 'release', 'profile')]
    [string]$BuildType = 'debug',
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean,
    
    [Parameter(Mandatory=$false)]
    [switch]$Install,
    
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
    Write-ColorOutput "🏗️  Taste Android Build Script" $Blue
    Write-ColorOutput "================================" $Blue
    Write-ColorOutput "Environment: $Environment" $Green
    Write-ColorOutput "Build Type: $BuildType" $Green
    Write-ColorOutput "Clean Build: $($Clean.IsPresent)" $Green
    Write-ColorOutput "Auto Install: $($Install.IsPresent)" $Green
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
    
    # Verifica se está no diretório correto
    if (!(Test-Path "pubspec.yaml")) {
        Write-ColorOutput "❌ Execute o script no diretório raiz do projeto Flutter" $Red
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
    Write-ColorOutput "✅ Dependências obtidas" $Green
}

function Start-Build {
    Write-ColorOutput "🔨 Iniciando build..." $Yellow
    
    # Constrói o comando de build
    $buildCommand = "flutter build apk"
    
    # Adiciona flavor
    $buildCommand += " --flavor $Environment"
    
    # Adiciona tipo de build
    if ($BuildType -eq "debug") {
        $buildCommand += " --debug"
    } elseif ($BuildType -eq "release") {
        $buildCommand += " --release"
    } elseif ($BuildType -eq "profile") {
        $buildCommand += " --profile"
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

function Install-APK {
    if ($Install) {
        Write-ColorOutput "📱 Instalando APK..." $Yellow
        
        # Encontra o APK gerado
        $apkPath = "build/app/outputs/flutter-apk/app-$Environment-$BuildType.apk"
        
        if (!(Test-Path $apkPath)) {
            # Tenta caminho alternativo
            $apkPath = "build/app/outputs/flutter-apk/app-$BuildType.apk"
        }
        
        if (Test-Path $apkPath) {
            adb install -r $apkPath
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ APK instalado com sucesso" $Green
            } else {
                Write-ColorOutput "❌ Erro ao instalar APK" $Red
            }
        } else {
            Write-ColorOutput "❌ APK não encontrado em $apkPath" $Red
        }
    }
}

function Show-BuildInfo {
    Write-ColorOutput "" $Blue
    Write-ColorOutput "📋 Informações do Build" $Blue
    Write-ColorOutput "========================" $Blue
    
    # Encontra o APK gerado
    $apkPath = "build/app/outputs/flutter-apk/app-$Environment-$BuildType.apk"
    if (!(Test-Path $apkPath)) {
        $apkPath = "build/app/outputs/flutter-apk/app-$BuildType.apk"
    }
    
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-ColorOutput "📁 APK: $apkPath" $Green
        Write-ColorOutput "📏 Tamanho: $([math]::Round($apkSize, 2)) MB" $Green
    }
    
    Write-ColorOutput "🏷️  Flavor: $Environment" $Green
    Write-ColorOutput "🔧 Build Type: $BuildType" $Green
    Write-ColorOutput "" $Blue
}

function Main {
    try {
        Show-Header
        Test-Prerequisites
        Invoke-CleanBuild
        Get-Dependencies
        Start-Build
        Install-APK
        Show-BuildInfo
        
        Write-ColorOutput "🎉 Build concluído com sucesso!" $Green
    }
    catch {
        Write-ColorOutput "❌ Erro durante o build: $_" $Red
        exit 1
    }
}

# Executa o script principal
Main