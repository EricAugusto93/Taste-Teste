# Script para configurar Google Maps API Key
# Uso: .\scripts\setup_google_maps.ps1 -ApiKey "sua_api_key_aqui"

param(
    [Parameter(Mandatory=$true)]
    [string]$ApiKey,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# Função para log
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Função para validar API key
function Test-ApiKey {
    param([string]$Key)
    
    if ([string]::IsNullOrWhiteSpace($Key)) {
        return $false
    }
    
    if ($Key -eq "YOUR_GOOGLE_MAPS_API_KEY_HERE" -or $Key -eq "YOUR_API_KEY" -or $Key -eq "YOUR_GOOGLE_MAPS_API_KEY") {
        return $false
    }
    
    # Validação básica do formato da API key do Google
    if ($Key.Length -lt 30) {
        return $false
    }
    
    return $true
}

# Função para atualizar arquivo .env
function Update-EnvFile {
    param([string]$ApiKey)
    
    $envFile = ".env"
    
    if (-not (Test-Path $envFile)) {
        Write-Log "Arquivo .env não encontrado!" "ERROR"
        return $false
    }
    
    try {
        $content = Get-Content $envFile
        $updated = $false
        
        for ($i = 0; $i -lt $content.Length; $i++) {
            if ($content[$i] -match "^GOOGLE_MAPS_API_KEY=") {
                $content[$i] = "GOOGLE_MAPS_API_KEY=$ApiKey"
                $updated = $true
                break
            }
        }
        
        if (-not $updated) {
            $content += "GOOGLE_MAPS_API_KEY=$ApiKey"
        }
        
        $content | Set-Content $envFile -Encoding UTF8
        Write-Log "Arquivo .env atualizado com sucesso" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Erro ao atualizar .env: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Função para atualizar AndroidManifest.xml
function Update-AndroidManifest {
    param([string]$ApiKey)
    
    $manifestFile = "android\app\src\main\AndroidManifest.xml"
    
    if (-not (Test-Path $manifestFile)) {
        Write-Log "AndroidManifest.xml não encontrado!" "WARN"
        return $false
    }
    
    try {
        $content = Get-Content $manifestFile -Raw
        $pattern = 'android:value="YOUR_GOOGLE_MAPS_API_KEY"'
        $replacement = "android:value=`"$ApiKey`""
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
            $content | Set-Content $manifestFile -Encoding UTF8
            Write-Log "AndroidManifest.xml atualizado com sucesso" "SUCCESS"
            return $true
        } else {
            Write-Log "Padrão não encontrado no AndroidManifest.xml" "WARN"
            return $false
        }
    }
    catch {
        Write-Log "Erro ao atualizar AndroidManifest.xml: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Função para atualizar AppDelegate.swift
function Update-AppDelegate {
    param([string]$ApiKey)
    
    $appDelegateFile = "ios\Runner\AppDelegate.swift"
    
    if (-not (Test-Path $appDelegateFile)) {
        Write-Log "AppDelegate.swift não encontrado!" "WARN"
        return $false
    }
    
    try {
        $content = Get-Content $appDelegateFile -Raw
        $pattern = 'GMSServices\.provideAPIKey\("YOUR_GOOGLE_MAPS_API_KEY"\)'
        $replacement = "GMSServices.provideAPIKey(`"$ApiKey`")"
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
            $content | Set-Content $appDelegateFile -Encoding UTF8
            Write-Log "AppDelegate.swift atualizado com sucesso" "SUCCESS"
            return $true
        } else {
            Write-Log "Padrão não encontrado no AppDelegate.swift" "WARN"
            return $false
        }
    }
    catch {
        Write-Log "Erro ao atualizar AppDelegate.swift: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Função para atualizar index.html
function Update-IndexHtml {
    param([string]$ApiKey)
    
    $indexFile = "web\index.html"
    
    if (-not (Test-Path $indexFile)) {
        Write-Log "index.html não encontrado!" "WARN"
        return $false
    }
    
    try {
        $content = Get-Content $indexFile -Raw
        $pattern = 'key=YOUR_API_KEY'
        $replacement = "key=$ApiKey"
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
            $content | Set-Content $indexFile -Encoding UTF8
            Write-Log "index.html atualizado com sucesso" "SUCCESS"
            return $true
        } else {
            Write-Log "Padrão não encontrado no index.html" "WARN"
            return $false
        }
    }
    catch {
        Write-Log "Erro ao atualizar index.html: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Função para criar backup
function Create-Backup {
    $backupDir = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    try {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        
        $filesToBackup = @(
            ".env",
            "android\app\src\main\AndroidManifest.xml",
            "ios\Runner\AppDelegate.swift",
            "web\index.html"
        )
        
        foreach ($file in $filesToBackup) {
            if (Test-Path $file) {
                $destPath = Join-Path $backupDir (Split-Path $file -Leaf)
                Copy-Item $file $destPath
                if ($Verbose) {
                    Write-Log "Backup criado: $destPath" "INFO"
                }
            }
        }
        
        Write-Log "Backup criado em: $backupDir" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Erro ao criar backup: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Função principal
function Main {
    Write-Log "Iniciando configuração do Google Maps API Key..." "INFO"
    
    # Validar API key
    if (-not (Test-ApiKey $ApiKey)) {
        Write-Log "API Key inválida! Verifique se a chave está correta." "ERROR"
        Write-Log "A API key deve ter pelo menos 30 caracteres e não pode ser um placeholder." "ERROR"
        exit 1
    }
    
    # Verificar se estamos no diretório correto
    if (-not (Test-Path "pubspec.yaml")) {
        Write-Log "Execute este script a partir da raiz do projeto Flutter!" "ERROR"
        exit 1
    }
    
    # Criar backup
    Write-Log "Criando backup dos arquivos..." "INFO"
    if (-not (Create-Backup)) {
        Write-Log "Falha ao criar backup. Continuando mesmo assim..." "WARN"
    }
    
    # Atualizar arquivos
    $results = @()
    
    Write-Log "Atualizando arquivo .env..." "INFO"
    $results += Update-EnvFile $ApiKey
    
    Write-Log "Atualizando AndroidManifest.xml..." "INFO"
    $results += Update-AndroidManifest $ApiKey
    
    Write-Log "Atualizando AppDelegate.swift..." "INFO"
    $results += Update-AppDelegate $ApiKey
    
    Write-Log "Atualizando index.html..." "INFO"
    $results += Update-IndexHtml $ApiKey
    
    # Resumo
    $successCount = ($results | Where-Object { $_ -eq $true }).Count
    $totalCount = $results.Count
    
    Write-Log "Configuração concluída: $successCount/$totalCount arquivos atualizados" "INFO"
    
    if ($successCount -gt 0) {
        Write-Log "Google Maps API Key configurada com sucesso!" "SUCCESS"
        Write-Log "Execute 'flutter clean && flutter pub get' para aplicar as mudanças." "INFO"
    } else {
        Write-Log "Nenhum arquivo foi atualizado. Verifique os logs acima." "WARN"
    }
    
    # Instruções adicionais
    Write-Log "" "INFO"
    Write-Log "Próximos passos:" "INFO"
    Write-Log "1. Verifique se as APIs necessárias estão habilitadas no Google Cloud Console" "INFO"
    Write-Log "2. Configure as restrições da API key conforme necessário" "INFO"
    Write-Log "3. Teste o aplicativo em diferentes plataformas" "INFO"
    Write-Log "" "INFO"
    Write-Log "Para mais informações, consulte: docs/google_maps_setup.md" "INFO"
}

# Executar script principal
Main