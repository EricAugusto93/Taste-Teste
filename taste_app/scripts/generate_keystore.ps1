# Script para gerar keystore de produção para Android
# Execute este script na pasta raiz do projeto

Write-Host "🔐 Gerando Keystore de Produção para Taste App" -ForegroundColor Cyan
Write-Host "" 

# Verificar se keytool está disponível
try {
    keytool -help | Out-Null
} catch {
    Write-Host "❌ Erro: keytool não encontrado. Certifique-se de que o Java JDK está instalado." -ForegroundColor Red
    exit 1
}

# Definir caminhos
$keystorePath = "android/taste-app-keystore.jks"
$keyPropertiesPath = "android/key.properties"

# Verificar se keystore já existe
if (Test-Path $keystorePath) {
    Write-Host "⚠️  Keystore já existe em: $keystorePath" -ForegroundColor Yellow
    $overwrite = Read-Host "Deseja sobrescrever? (s/N)"
    if ($overwrite -ne "s" -and $overwrite -ne "S") {
        Write-Host "Operação cancelada." -ForegroundColor Yellow
        exit 0
    }
    Remove-Item $keystorePath -Force
}

# Solicitar informações
Write-Host "📝 Preencha as informações para o keystore:" -ForegroundColor Green
$storePassword = Read-Host "Senha do keystore (mínimo 6 caracteres)" -AsSecureString
$keyPassword = Read-Host "Senha da chave (mínimo 6 caracteres)" -AsSecureString
$commonName = Read-Host "Nome completo (ex: Taste App)"
$organizationUnit = Read-Host "Unidade organizacional (ex: Development)"
$organization = Read-Host "Organização (ex: Taste Company)"
$city = Read-Host "Cidade"
$state = Read-Host "Estado/Província"
$country = Read-Host "Código do país (2 letras, ex: BR)"

# Converter SecureString para texto
$storePasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))
$keyPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))

# Gerar keystore
Write-Host "" 
Write-Host "🔨 Gerando keystore..." -ForegroundColor Cyan

$dname = "CN=$commonName, OU=$organizationUnit, O=$organization, L=$city, ST=$state, C=$country"

try {
    & keytool -genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity 10000 -alias "taste-app-key" -dname $dname -storepass $storePasswordText -keypass $keyPasswordText
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Keystore gerado com sucesso!" -ForegroundColor Green
        
        # Criar arquivo key.properties
        $keyPropertiesContent = @"
storePassword=$storePasswordText
keyPassword=$keyPasswordText
keyAlias=taste-app-key
storeFile=../taste-app-keystore.jks
"@
        
        $keyPropertiesContent | Out-File -FilePath $keyPropertiesPath -Encoding UTF8
        Write-Host "✅ Arquivo key.properties criado!" -ForegroundColor Green
        
        Write-Host "" 
        Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
        Write-Host "1. Mantenha o arquivo keystore em local seguro" -ForegroundColor White
        Write-Host "2. Faça backup das senhas" -ForegroundColor White
        Write-Host "3. Adicione key.properties ao .gitignore" -ForegroundColor White
        Write-Host "4. Execute: flutter build appbundle --release --flavor production" -ForegroundColor White
        
    } else {
        Write-Host "❌ Erro ao gerar keystore" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

# Limpar senhas da memória
$storePasswordText = $null
$keyPasswordText = $null
[System.GC]::Collect()

Write-Host "" 
Write-Host "🔐 Script concluído." -ForegroundColor Cyan