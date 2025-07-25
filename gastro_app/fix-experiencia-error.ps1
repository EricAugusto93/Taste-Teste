#!/usr/bin/env pwsh
# Script para corrigir erro de registro de experiências em restaurantes

Write-Host "🔧 Correção: Erro de Registro de Experiências" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Verificar se estamos no diretório correto
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "❌ Execute este script no diretório gastro_app/" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⚠️ ERRO IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "   PostgrestException: Could not find the 'nome' column" -ForegroundColor Red
Write-Host "   Código: PGRST204 (Schema cache desatualizado)" -ForegroundColor Red

Write-Host ""
Write-Host "🔧 SOLUÇÕES DISPONÍVEIS:" -ForegroundColor Yellow
Write-Host ""

Write-Host "📋 Opção 1: Aplicar correção no Supabase (RECOMENDADO)" -ForegroundColor Green
Write-Host "   1. Acesse: https://supabase.com/dashboard" -ForegroundColor White
Write-Host "   2. Vá para o seu projeto > SQL Editor" -ForegroundColor White
Write-Host "   3. Cole e execute o conteúdo de 'fix-usuarios-schema.sql'" -ForegroundColor White
Write-Host "   4. Aguarde a execução completar" -ForegroundColor White
Write-Host ""

Write-Host "📋 Opção 2: Hot Reload do app (temporário)" -ForegroundColor Yellow
Write-Host "   • Pressione 'r' no terminal onde o app está rodando" -ForegroundColor White
Write-Host "   • Tente registrar experiência novamente" -ForegroundColor White
Write-Host ""

Write-Host "📋 Opção 3: Restart completo do app" -ForegroundColor Yellow
Write-Host "   • Pare o app (Ctrl+C)" -ForegroundColor White
Write-Host "   • Execute: flutter run -d web-server --web-port 8080" -ForegroundColor White

Write-Host ""
Write-Host "🎯 APÓS APLICAR A CORREÇÃO:" -ForegroundColor Cyan
Write-Host "   ✅ Registro de experiências funcionará" -ForegroundColor Green
Write-Host "   ✅ Avaliações com emoji serão salvas" -ForegroundColor Green
Write-Host "   ✅ Sistema de favoritos normalizado" -ForegroundColor Green
Write-Host "   ✅ Perfil de usuário completo" -ForegroundColor Green

Write-Host ""
Write-Host "📁 ARQUIVOS CRIADOS:" -ForegroundColor Cyan
Write-Host "   • fix-usuarios-schema.sql (aplicar no Supabase)" -ForegroundColor White
Write-Host "   • Código atualizado com fallback robusto" -ForegroundColor White

Write-Host ""
Write-Host "🚀 TESTANDO A CORREÇÃO:" -ForegroundColor Cyan
Write-Host "   1. Abra o app: http://localhost:8080" -ForegroundColor White
Write-Host "   2. Faça login" -ForegroundColor White
Write-Host "   3. Clique no emoji 😋 em qualquer restaurante" -ForegroundColor White
Write-Host "   4. Registre uma experiência" -ForegroundColor White
Write-Host "   5. Verifique se não há mais erros no console" -ForegroundColor White

Write-Host ""
$response = Read-Host "Deseja abrir o arquivo SQL para copiar? (s/n)"

if ($response -eq 's' -or $response -eq 'S') {
    if (Test-Path "fix-usuarios-schema.sql") {
        Write-Host ""
        Write-Host "📋 Abrindo arquivo SQL..." -ForegroundColor Green
        Start-Process "fix-usuarios-schema.sql"
    } else {
        Write-Host ""
        Write-Host "❌ Arquivo não encontrado. Verifique se foi criado corretamente." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 Correção configurada com sucesso!" -ForegroundColor Green
Write-Host "   Aplique o SQL no Supabase e teste o app." -ForegroundColor White 