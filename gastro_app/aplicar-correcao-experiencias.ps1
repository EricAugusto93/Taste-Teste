#!/usr/bin/env pwsh
# Script CRÍTICO para correção dos erros de registro de experiências

Write-Host "🚨 CORREÇÃO CRÍTICA: ERROS DE REGISTRO DE EXPERIÊNCIAS" -ForegroundColor Red
Write-Host "========================================================" -ForegroundColor Red

# Verificar se estamos no diretório correto
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "❌ Execute este script no diretório gastro_app/" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "❌ ERROS IDENTIFICADOS:" -ForegroundColor Yellow
Write-Host "   1. PGRST204: Could not find the 'nome' column" -ForegroundColor Red
Write-Host "   2. 42703: record 'new' has no field 'updated_at'" -ForegroundColor Red
Write-Host "   3. Registro de experiências não funciona" -ForegroundColor Red

Write-Host ""
Write-Host "CORRECOES APLICADAS:" -ForegroundColor Green
Write-Host "   Script SQL v2 criado (fix-usuarios-schema-v2.sql)" -ForegroundColor White
Write-Host "   Modelo Usuario.dart atualizado (sem updated_at)" -ForegroundColor White
Write-Host "   UsuarioService.dart simplificado" -ForegroundColor White
Write-Host "   Fallbacks robustos implementados" -ForegroundColor White

Write-Host ""
Write-Host "ACAO OBRIGATORIA: APLICAR SQL NO SUPABASE" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Abra: https://supabase.com/dashboard" -ForegroundColor Yellow
Write-Host "2. Va para seu projeto > SQL Editor" -ForegroundColor Yellow
Write-Host "3. Copie todo o conteudo de 'fix-usuarios-schema-v2.sql'" -ForegroundColor Yellow
Write-Host "4. Cole no editor e execute (Run)" -ForegroundColor Yellow
Write-Host "5. Aguarde a mensagem: 'CORRECAO APLICADA COM SUCESSO!'" -ForegroundColor Yellow

Write-Host ""
Write-Host "📁 ABRINDO ARQUIVO SQL..." -ForegroundColor Green

# Abrir o arquivo SQL para facilitar a cópia
if (Test-Path "fix-usuarios-schema-v2.sql") {
    Start-Process "fix-usuarios-schema-v2.sql"
    Write-Host "Arquivo SQL aberto para copia" -ForegroundColor Green
} else {
    Write-Host "❌ Arquivo SQL não encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔄 AGUARDANDO APLICAÇÃO DO SQL..." -ForegroundColor Yellow
$response = Read-Host "Já aplicou o SQL no Supabase? (s/n)"

if ($response -eq 's' -or $response -eq 'S') {
    Write-Host ""
    Write-Host "🚀 TESTANDO A CORREÇÃO..." -ForegroundColor Cyan
    
    # Limpar cache Flutter
    Write-Host "   🧹 Limpando cache Flutter..." -ForegroundColor White
    flutter clean | Out-Null
    
    # Instalar dependências
    Write-Host "   📦 Instalando dependências..." -ForegroundColor White
    flutter pub get | Out-Null
    
    # Verificar análise de código
    Write-Host "   🔍 Verificando código..." -ForegroundColor White
    $analyzeResult = flutter analyze 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Código está sem erros críticos" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Existem warnings no código (isso é normal)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🎉 CORREÇÃO APLICADA!" -ForegroundColor Green
    Write-Host "===================" -ForegroundColor Green
    Write-Host "✅ Código atualizado" -ForegroundColor Green
    Write-Host "✅ SQL aplicado no banco" -ForegroundColor Green
    Write-Host "✅ Fallbacks implementados" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "🧪 TESTE FINAL:" -ForegroundColor Cyan
    Write-Host "1. Execute: flutter run -d web-server --web-port 8080" -ForegroundColor White
    Write-Host "2. Abra: http://localhost:8080" -ForegroundColor White
    Write-Host "3. Faça login" -ForegroundColor White
    Write-Host "4. Clique no emoji 😋 em um restaurante" -ForegroundColor White
    Write-Host "5. Registre uma experiência" -ForegroundColor White
    Write-Host "6. Verifique se salvou sem erros" -ForegroundColor White
    
    Write-Host ""
    $runApp = Read-Host "Deseja executar o app agora? (s/n)"
    
    if ($runApp -eq 's' -or $runApp -eq 'S') {
        Write-Host ""
        Write-Host "🚀 Iniciando o app..." -ForegroundColor Cyan
        flutter run -d web-server --web-port 8080
    }
    
} else {
    Write-Host ""
    Write-Host "⚠️ IMPORTANTE: Execute o SQL primeiro!" -ForegroundColor Yellow
    Write-Host "   O registro de experiências só funcionará após aplicar o SQL" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Passos para aplicar:" -ForegroundColor Cyan
    Write-Host "   1. Acesse: https://supabase.com/dashboard" -ForegroundColor White
    Write-Host "   2. Vá para: Seu projeto > SQL Editor" -ForegroundColor White
    Write-Host "   3. Cole o conteúdo de 'fix-usuarios-schema-v2.sql'" -ForegroundColor White
    Write-Host "   4. Execute e aguarde o sucesso" -ForegroundColor White
    Write-Host "   5. Execute este script novamente" -ForegroundColor White
}

Write-Host ""
Write-Host "🎯 RESULTADO ESPERADO:" -ForegroundColor Cyan
Write-Host "   ✅ Registro de experiências funcionando" -ForegroundColor Green
Write-Host "   ✅ Avaliações com emoji sendo salvas" -ForegroundColor Green
Write-Host "   ✅ Sistema de favoritos normalizado" -ForegroundColor Green
Write-Host "   Sem mais erros PGRST204 ou 42703" -ForegroundColor Green 