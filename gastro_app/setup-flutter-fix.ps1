# Script de Instalacao do Flutter - Gastro App
# Versao corrigida sem problemas de encoding

Write-Host "Instalando Flutter para o Gastro App..." -ForegroundColor Green

# Verificar se ja esta instalado
if (Get-Command "flutter" -ErrorAction SilentlyContinue) {
    Write-Host "Flutter ja esta instalado!" -ForegroundColor Green
    flutter --version
    Write-Host "Executando flutter pub get..." -ForegroundColor Yellow
    flutter pub get
    Write-Host "Pronto para executar o app!" -ForegroundColor Green
    exit 0
}

Write-Host "Flutter nao encontrado. Instalando..." -ForegroundColor Yellow

# Criar diretorio
$flutterDir = "C:\flutter"
if (!(Test-Path $flutterDir)) {
    New-Item -ItemType Directory -Path $flutterDir -Force
}

# URL do Flutter estavel
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.9-stable.zip"
$flutterZip = "C:\flutter\flutter_windows.zip"

try {
    Write-Host "Baixando Flutter SDK..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip
    
    Write-Host "Extraindo arquivos..." -ForegroundColor Yellow
    Expand-Archive -Path $flutterZip -DestinationPath "C:\" -Force
    
    Write-Host "Removendo arquivo temporario..." -ForegroundColor Yellow
    Remove-Item $flutterZip
    
    Write-Host "Configurando PATH..." -ForegroundColor Yellow
    
    # Adicionar ao PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $flutterBin = "C:\flutter\bin"
    
    if ($currentPath -notlike "*$flutterBin*") {
        $newPath = "$currentPath;$flutterBin"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Flutter adicionado ao PATH!" -ForegroundColor Green
        
        # Atualizar PATH da sessao atual
        $env:Path += ";$flutterBin"
    }
    
    Write-Host "Executando Flutter Doctor..." -ForegroundColor Yellow
    & "C:\flutter\bin\flutter.bat" doctor
    
    Write-Host ""
    Write-Host "FLUTTER INSTALADO COM SUCESSO!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Para executar o Gastro App:" -ForegroundColor Cyan
    Write-Host "  1. Reinicie o PowerShell" -ForegroundColor White
    Write-Host "  2. cd gastro_app" -ForegroundColor White
    Write-Host "  3. flutter pub get" -ForegroundColor White
    Write-Host "  4. flutter run -d web-server --web-port 8080" -ForegroundColor White
    
} catch {
    Write-Host "Erro durante a instalacao: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Instalacao Manual:" -ForegroundColor Yellow
    Write-Host "  1. Baixe: https://docs.flutter.dev/get-started/install/windows"
    Write-Host "  2. Extraia para C:\flutter"
    Write-Host "  3. Adicione C:\flutter\bin ao PATH"
} 