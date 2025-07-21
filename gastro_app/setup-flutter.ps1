# Script de Instalação Automática do Flutter
# Gastro App - Nova Identidade Visual

Write-Host "🚀 Instalando Flutter para o Gastro App..." -ForegroundColor Green

# Verificar se já está instalado
if (Get-Command "flutter" -ErrorAction SilentlyContinue) {
    Write-Host "✅ Flutter já está instalado!" -ForegroundColor Green
    flutter --version
    flutter doctor
    exit 0
}

Write-Host "📥 Baixando Flutter SDK..." -ForegroundColor Yellow

# Criar diretório
$flutterDir = "C:\flutter"
if (!(Test-Path $flutterDir)) {
    New-Item -ItemType Directory -Path $flutterDir
}

# Baixar Flutter
$flutterZip = "C:\flutter\flutter_windows.zip"
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.9-stable.zip"

try {
    Write-Host "⬇️ Baixando de $flutterUrl..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip
    
    Write-Host "📂 Extraindo arquivo..." -ForegroundColor Yellow
    Expand-Archive -Path $flutterZip -DestinationPath "C:\" -Force
    
    Write-Host "🗑️ Limpando arquivo temporário..." -ForegroundColor Yellow
    Remove-Item $flutterZip
    
    Write-Host "🔧 Configurando PATH..." -ForegroundColor Yellow
    
    # Adicionar ao PATH do usuário
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $flutterBin = "C:\flutter\bin"
    
    if ($currentPath -notlike "*$flutterBin*") {
        $newPath = "$currentPath;$flutterBin"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "✅ Flutter adicionado ao PATH!" -ForegroundColor Green
        
        # Atualizar PATH da sessão atual
        $env:Path += ";$flutterBin"
    }
    
    Write-Host "🏥 Executando Flutter Doctor..." -ForegroundColor Yellow
    & "C:\flutter\bin\flutter.bat" doctor
    
    Write-Host "" -ForegroundColor White
    Write-Host "🎉 FLUTTER INSTALADO COM SUCESSO!" -ForegroundColor Green
    Write-Host "" -ForegroundColor White
    Write-Host "📱 Para executar o Gastro App:" -ForegroundColor Cyan
    Write-Host "   1. Reinicie o PowerShell" -ForegroundColor White
    Write-Host "   2. cd gastro_app" -ForegroundColor White
    Write-Host "   3. flutter pub get" -ForegroundColor White
    Write-Host "   4. flutter run" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "🎨 Nova identidade visual será aplicada automaticamente!" -ForegroundColor Magenta
    
} catch {
    Write-Host "❌ Erro durante a instalação: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "" -ForegroundColor White
    Write-Host "🔧 Instalação Manual:" -ForegroundColor Yellow
    Write-Host "   1. Baixe: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "   2. Extraia para C:\flutter" -ForegroundColor White
    Write-Host "   3. Adicione C:\flutter\bin ao PATH" -ForegroundColor White
}

Write-Host "" -ForegroundColor White
Write-Host "📖 Documentação completa: gastro_app/docs/IDENTIDADE_VISUAL.md" -ForegroundColor Blue 