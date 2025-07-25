# 🔧 Correção: Erro ao Registrar Experiências

## ❌ **Problema Identificado**

O erro `PostgrestException(message: Could not find the 'nome' column of 'usuarios' in the schema cache, code: PGRST204)` está impedindo o registro de experiências nos restaurantes.

### **Sintomas:**
- ❌ Erro `PGRST204` ao tentar registrar experiência
- ❌ Não consegue salvar avaliações com emoji
- ❌ Sistema de favoritos pode estar comprometido
- ❌ Console mostra erro de "coluna nome não encontrada"

### **Causa Raiz:**
- **Schema desatualizado:** A coluna `nome` não existe na tabela `usuarios` ou o cache do PostgREST está desatualizado
- **Migração incompleta:** O schema não foi aplicado corretamente no Supabase
- **Inconsistência de dados:** Discrepância entre código e estrutura do banco

## ✅ **Soluções Implementadas**

### **1. Script SQL de Correção** ⭐ (PRINCIPAL)
**Arquivo:** `fix-usuarios-schema.sql`

O script realiza:
- ✅ Verifica se a tabela `usuarios` existe
- ✅ Adiciona coluna `nome` se não existir  
- ✅ Corrige políticas RLS
- ✅ Recria trigger de criação automática
- ✅ Sincroniza usuários existentes
- ✅ Força refresh do cache do schema
- ✅ Valida resultado final

### **2. Código Robusto com Fallback**
**Arquivo:** `lib/services/usuario_service.dart`

- ✅ **Tentativa principal:** Usar schema completo com coluna `nome`
- ✅ **Fallback automático:** Funcionar sem coluna `nome` se necessário
- ✅ **Logs detalhados:** Para debugging e monitoramento
- ✅ **Error handling:** Tratamento de erros de schema

## 🚀 **Como Aplicar a Correção**

### **Método 1: Aplicar SQL no Supabase** (RECOMENDADO)

1. **Acesse o Supabase Dashboard:**
   - Vá para [https://supabase.com/dashboard](https://supabase.com/dashboard)
   - Selecione seu projeto do Gastro App

2. **Abra o SQL Editor:**
   - No menu lateral, clique em **"SQL Editor"**
   - Clique em **"New query"**

3. **Execute o Script de Correção:**
   - Copie todo o conteúdo de `fix-usuarios-schema.sql`
   - Cole no editor SQL
   - Clique em **"Run"** (ou pressione Ctrl+Enter)

4. **Verifique a Execução:**
   - Aguarde a execução completar
   - Verifique se aparecem as mensagens de sucesso:
     ```
     ✅ Tabela usuarios existe
     ✅ Coluna nome existe  
     ✅ CORREÇÃO APLICADA COM SUCESSO!
     ```

### **Método 2: Script PowerShell** (AUXILIAR)

```powershell
cd gastro_app
.\fix-experiencia-error.ps1
```

### **Método 3: Hot Reload** (TEMPORÁRIO)

Se o app estiver rodando:
- Pressione `r` no terminal
- Tente registrar experiência novamente

## 🧪 **Como Testar a Correção**

### **Passo a Passo:**

1. **Abra o App:**
   ```
   http://localhost:8080
   ```

2. **Faça Login:**
   - Entre com suas credenciais
   - Aguarde a tela inicial carregar

3. **Teste Registro de Experiência:**
   - Clique no emoji 😋 em qualquer restaurante
   - Selecione um emoji (ex: 😋 Delicioso)
   - Adicione um comentário opcional
   - Clique em "Salvar Experiência"

4. **Verifique os Logs:**
   - Abra o console do navegador (F12)
   - Deve aparecer:
     ```
     ✅ Usuário sincronizado com sucesso
     ```
   - **NÃO** deve aparecer:
     ```
     ❌ Erro detalhado na sincronização: PostgrestException
     ```

### **Resultados Esperados:**

- ✅ **Experiência salva com sucesso**
- ✅ **Modal de experiência fecha normalmente**
- ✅ **Sem erros no console**
- ✅ **Emoji aparece no histórico de experiências**

## 📊 **Validação Técnica**

### **No Supabase Dashboard:**

1. **Verificar Estrutura da Tabela:**
   - Vá para **Table Editor > usuarios**
   - Confirme que a coluna `nome` existe
   - Tipo deve ser: `varchar(255)`

2. **Verificar Dados:**
   - Clique em **"View data"**
   - Confirme que há registros de usuários
   - Campo `nome` deve estar preenchido

3. **Verificar Políticas RLS:**
   - Vá para **Authentication > Policies**
   - Tabela `usuarios` deve ter 3 políticas ativas

### **No Console do App:**

- ✅ Logs de sincronização positivos
- ✅ Sem erros `PGRST204`
- ✅ Operações de favoritos funcionando

## 🔄 **Se o Problema Persistir**

### **Diagnóstico Adicional:**

1. **Verificar Conexão:**
   ```sql
   SELECT current_user, current_database();
   ```

2. **Verificar Schema:**
   ```sql
   SELECT column_name, data_type 
   FROM information_schema.columns 
   WHERE table_name = 'usuarios';
   ```

3. **Forçar Refresh:**
   ```sql
   NOTIFY pgrst, 'reload schema';
   ```

### **Soluções Alternativas:**

1. **Restart do Serviço PostgREST:**
   - No Supabase Dashboard > Settings
   - Restart project (pode levar alguns minutos)

2. **Verificar Variáveis de Ambiente:**
   - Confirme SUPABASE_URL e SUPABASE_ANON_KEY
   - No arquivo `.env` do projeto

3. **Limpeza de Cache:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d web-server --web-port 8080
   ```

## 📋 **Checklist de Validação**

Após aplicar a correção, verifique:

- [ ] ✅ Script SQL executado sem erros
- [ ] ✅ Tabela `usuarios` tem coluna `nome`
- [ ] ✅ App compila e executa sem erros
- [ ] ✅ Login funciona normalmente
- [ ] ✅ Registro de experiência funciona
- [ ] ✅ Sistema de favoritos funciona
- [ ] ✅ Sem erros `PGRST204` no console
- [ ] ✅ Usuário consegue avaliar restaurantes

## 🎯 **Causa Raiz e Prevenção**

### **O que Causou o Problema:**
- Schema inicial pode não ter sido aplicado completamente
- Migração manual incompleta
- Cache do PostgREST desatualizado

### **Como Prevenir:**
- ✅ Usar migrações automatizadas no Supabase
- ✅ Verificar schema após cada deploy
- ✅ Implementar health checks da API
- ✅ Manter fallbacks robustos no código

## 📞 **Suporte**

Se ainda houver problemas:

1. **Verifique os logs detalhados** no console do app
2. **Execute o script de diagnóstico** novamente
3. **Compartilhe a mensagem de erro específica**
4. **Confirme se o SQL foi executado** no Supabase

---

**🎉 Correção bem-sucedida = Experiências funcionando!** 