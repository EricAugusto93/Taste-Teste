# Guia de Correção - Sistema de Autenticação do Painel Administrativo

## 🚨 Problema Identificado

**Erro**: `Invalid login credentials`
**Logs do Sistema**:
```
❌ Erro de autenticação: AuthApiError: Invalid login credentials
💥 Erro no processo de login: Error: Erro de autenticação: Invalid login credentials
```

## 🔍 Diagnóstico da Causa Raiz

O erro ocorre porque:
1. ✅ A tabela `admins` existe no banco de dados
2. ✅ O email `admin@gastroapp.com` pode estar na tabela `admins`
3. ❌ **O usuário não foi criado no Supabase Auth**
4. ❌ Sem usuário no Auth, a autenticação falha antes mesmo de verificar a tabela `admins`

## 🛠️ Solução Passo a Passo

### Passo 1: Verificar Estado Atual

#### 1.1 Verificar Tabela Admins
```sql
-- Execute no SQL Editor do Supabase
SELECT * FROM admins WHERE email = 'admin@gastroapp.com';
```

**Resultado Esperado**:
```
id                                   | email                | created_at
-------------------------------------|----------------------|-------------------------
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | admin@gastroapp.com  | 2024-01-15 10:30:00+00
```

#### 1.2 Verificar Usuários no Auth
1. Acesse o painel do Supabase
2. Vá para **Authentication > Users**
3. Procure por `admin@gastroapp.com`

**Problema**: Se o usuário não aparecer na lista, ele não existe no sistema de autenticação.

### Passo 2: Criar Usuário no Supabase Auth

#### 2.1 Via Painel Supabase (Recomendado)
1. **Acesse**: Dashboard do Supabase
2. **Navegue**: Authentication > Users
3. **Clique**: "Add user" (botão verde)
4. **Preencha**:
   - **Email**: `admin@gastroapp.com`
   - **Password**: `admin123`
   - **Auto Confirm User**: ✅ **IMPORTANTE: Marcar esta opção**
5. **Clique**: "Create user"

#### 2.2 Verificação Pós-Criação
Após criar o usuário, você deve ver:
- ✅ Usuário na lista de Authentication > Users
- ✅ Status: "Confirmed" (não "Unconfirmed")
- ✅ Email verificado automaticamente

### Passo 3: Verificar Integração Completa

#### 3.1 Verificar Tabela Admins
```sql
-- Se o email não estiver na tabela, adicionar:
INSERT INTO admins (email) 
VALUES ('admin@gastroapp.com')
ON CONFLICT (email) DO NOTHING;

-- Verificar se foi inserido:
SELECT * FROM admins WHERE email = 'admin@gastroapp.com';
```

#### 3.2 Testar Autenticação
1. Acesse `http://localhost:3000/login`
2. Use as credenciais:
   - **Email**: `admin@gastroapp.com`
   - **Password**: `admin123`
3. Clique em "Entrar no Painel"

**Resultado Esperado**:
```
🔐 Iniciando processo de login...
📧 Email: admin@gastroapp.com
🔄 Tentando autenticar com Supabase...
📊 Resultado da autenticação: { user: admin@gastroapp.com, session: true, error: null }
✅ Usuário autenticado: admin@gastroapp.com
🔍 Verificando se o usuário é admin...
👤 Resultado verificação admin: true
✅ Usuário é admin, salvando sessão...
🎯 Redirecionando para dashboard...
```

## 🔧 Soluções para Problemas Específicos

### Problema: "User not found"
**Causa**: Usuário não existe no Auth
**Solução**: Seguir Passo 2 acima

### Problema: "Email not confirmed"
**Causa**: Usuário criado mas não confirmado
**Solução**:
1. Authentication > Users
2. Encontrar o usuário
3. Clique nos "..." > "Send confirmation email"
4. OU marque "Auto Confirm User" ao criar

### Problema: "Access denied after login"
**Causa**: Usuário existe no Auth mas não na tabela `admins`
**Solução**:
```sql
INSERT INTO admins (email) VALUES ('admin@gastroapp.com');
```

### Problema: "Network error"
**Causa**: Configuração incorreta do Supabase
**Solução**: Verificar `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

## 📋 Checklist de Verificação

### ✅ Pré-requisitos
- [ ] Projeto Supabase criado e ativo
- [ ] Variáveis de ambiente configuradas em `.env.local`
- [ ] Tabela `admins` criada no banco
- [ ] Tabela `restaurantes` criada no banco
- [ ] Bucket `images` criado no Storage

### ✅ Configuração de Autenticação
- [ ] Email/Password habilitado em Auth Settings
- [ ] Usuário `admin@gastroapp.com` criado no Auth
- [ ] Usuário confirmado (não "unconfirmed")
- [ ] Email adicionado na tabela `admins`
- [ ] Políticas RLS configuradas

### ✅ Teste de Funcionalidade
- [ ] Login funciona sem erros
- [ ] Redirecionamento para dashboard
- [ ] Lista de restaurantes carrega
- [ ] Criação de restaurante funciona
- [ ] Upload de imagem funciona

## 🚀 Script de Configuração Rápida

### SQL para Configuração Completa
```sql
-- 1. Criar tabela admins (se não existir)
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Adicionar admin principal
INSERT INTO admins (email) 
VALUES ('admin@gastroapp.com')
ON CONFLICT (email) DO NOTHING;

-- 3. Habilitar RLS
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- 4. Criar política para admins
CREATE POLICY "Admin can view admins" ON admins
    FOR SELECT 
    USING (
        auth.role() = 'authenticated' AND 
        auth.jwt() ->> 'email' IN (SELECT email FROM admins)
    );

-- 5. Verificar configuração
SELECT 
    'Tabela admins' as item,
    CASE WHEN EXISTS (SELECT 1 FROM admins WHERE email = 'admin@gastroapp.com') 
         THEN '✅ Configurado' 
         ELSE '❌ Não configurado' 
    END as status;
```

## 🔄 Processo de Criação de Novos Administradores

### Para Futuros Administradores

#### Método 1: Via Painel (Recomendado)
1. **Supabase Dashboard**:
   - Authentication > Users > Add user
   - Email: `novo-admin@exemplo.com`
   - Password: senha segura
   - Auto Confirm: ✅

2. **SQL Editor**:
   ```sql
   INSERT INTO admins (email) VALUES ('novo-admin@exemplo.com');
   ```

#### Método 2: Via Convite (Futuro)
```sql
-- Função para convidar admin (implementação futura)
CREATE OR REPLACE FUNCTION invite_admin(admin_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Inserir na tabela admins
    INSERT INTO admins (email) VALUES (admin_email);
    
    -- Enviar convite via email (requer configuração SMTP)
    -- PERFORM send_invitation_email(admin_email);
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
```

## 🛡️ Segurança e Boas Práticas

### Senhas Seguras
- **Mínimo**: 8 caracteres
- **Recomendado**: 12+ caracteres
- **Incluir**: Maiúsculas, minúsculas, números, símbolos
- **Evitar**: Senhas óbvias como "admin123" em produção

### Gestão de Acessos
```sql
-- Listar todos os admins
SELECT email, created_at FROM admins ORDER BY created_at;

-- Remover admin (cuidado!)
DELETE FROM admins WHERE email = 'admin-removido@exemplo.com';

-- Verificar último login (requer logs)
SELECT 
    email,
    last_sign_in_at,
    created_at
FROM auth.users 
WHERE email IN (SELECT email FROM admins);
```

### Auditoria
```sql
-- Criar tabela de logs de admin (opcional)
CREATE TABLE admin_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_email VARCHAR(255),
    action VARCHAR(100),
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger para log automático (exemplo)
CREATE OR REPLACE FUNCTION log_admin_action()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO admin_logs (admin_email, action, details)
    VALUES (
        auth.jwt() ->> 'email',
        TG_OP,
        row_to_json(NEW)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## 📞 Suporte e Troubleshooting

### Logs Úteis para Debug
```javascript
// No console do navegador (F12)
console.log('Supabase URL:', process.env.NEXT_PUBLIC_SUPABASE_URL);
console.log('Supabase Key:', process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.substring(0, 10) + '...');

// Testar conexão
supabase.auth.getSession().then(console.log);
```

### Contatos de Suporte
- **Supabase Docs**: https://supabase.com/docs
- **Community**: https://github.com/supabase/supabase/discussions
- **Status**: https://status.supabase.com/

---

## ✅ Resumo da Solução

**O problema principal é que o usuário admin não existe no Supabase Auth.**

**Solução em 3 passos**:
1. 🔧 Criar usuário no Supabase Auth (Dashboard > Authentication > Users)
2. 📝 Verificar email na tabela `admins`
3. ✅ Testar login no painel

**Após seguir estes passos, o sistema de autenticação funcionará corretamente.**