# Script de build para diferentes ambientes do Taste App
# Uso: .\scripts\build.ps1 -Environment [dev|staging|prod] -Platform [android|ios|web] -BuildType [debug|release]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("android", "ios", "web")]
    [string]$Platform,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("debug", "release", "profile")]
    [string]$BuildType = "release"
)

# Cores para output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-FlutterInstallation {
    try {
        $flutterVersion = flutter --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Flutter encontrado" $SuccessColor
            return $true
        }
    } catch {
        Write-ColorOutput "✗ Flutter não encontrado. Instale o Flutter primeiro." $ErrorColor
        return $false
    }
    return $false
}

function Get-BuildCommand {
    param(
        [string]$Environment,
        [string]$Platform,
        [string]$BuildType
    )
    
    $flavor = switch ($Environment) {
        "dev" { "development" }
        "staging" { "staging" }
        "prod" { "production" }
    }
    
    $dartDefines = "--dart-define=ENVIRONMENT=$Environment"
    
    switch ($Platform) {
        "android" {
            if ($BuildType -eq "debug") {
                return "flutter build apk --flavor $flavor --debug $dartDefines"
            } else {
                return "flutter build apk --flavor $flavor --release $dartDefines"
            }
        }
        "ios" {
            if ($BuildType -eq "debug") {
                return "flutter build ios --flavor $flavor --debug $dartDefines"
            } else {
                return "flutter build ios --flavor $flavor --release $dartDefines"
            }
        }
        "web" {
            return "flutter build web --$BuildType $dartDefines"
        }
    }
}

function Start-Build {
    Write-ColorOutput "🚀 Iniciando build do Taste App" $InfoColor
    Write-ColorOutput "   Ambiente: $Environment" $InfoColor
    Write-ColorOutput "   Plataforma: $Platform" $InfoColor
    Write-ColorOutput "   Tipo: $BuildType" $InfoColor
    Write-ColorOutput ""
    
    # Verificar instalação do Flutter
    if (-not (Test-FlutterInstallation)) {
        exit 1
    }
    
    # Limpar builds anteriores
    Write-ColorOutput "🧹 Limpando builds anteriores..." $InfoColor
    flutter clean
    
    # Obter dependências
    Write-ColorOutput "📦 Obtendo dependências..." $InfoColor
    flutter pub get
    
    # Gerar código se necessário
    Write-ColorOutput "⚙️ Gerando código..." $InfoColor
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    # Executar build
    $buildCommand = Get-BuildCommand -Environment $Environment -Platform $Platform -BuildType $BuildType
    Write-ColorOutput "🔨 Executando: $buildCommand" $InfoColor
    
    Invoke-Expression $buildCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "" 
        Write-ColorOutput "✅ Build concluído com sucesso!" $SuccessColor
        
        # Mostrar localização do arquivo gerado
        switch ($Platform) {
            "android" {
                $apkPath = "build\app\outputs\flutter-apk\app-$Environment-$BuildType.apk"
                if (Test-Path $apkPath) {
                    Write-ColorOutput "📱 APK gerado: $apkPath" $SuccessColor
                }
            }
            "web" {
                Write-ColorOutput "🌐 Build web gerado em: build\web" $SuccessColor
            }
        }
    } else {
        Write-ColorOutput "" 
        Write-ColorOutput "❌ Build falhou!" $ErrorColor
        exit 1
    }
}

# Verificar se estamos no diretório correto
if (-not (Test-Path "pubspec.yaml")) {
    Write-ColorOutput "❌ Execute este script a partir do diretório raiz do projeto Flutter" $ErrorColor
    exit 1
}

# Iniciar o processo de build
Start-Build