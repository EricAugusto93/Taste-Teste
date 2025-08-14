# Guia de Manutenção e Operação - Sistema Taste

## 1. Procedimentos de Administração

### 1.1 Criação de Novos Administradores

#### Processo Completo

**Passo 1: Criar Usuário no Supabase Auth**
1. Acesse o Supabase Dashboard: https://app.supabase.com
2. Navegue para Authentication > Users
3. Clique em "Add user"
4. Preencha os dados:
   ```
   Email: admin@exemplo.com
   Password: [senha segura]
   Email Confirm: true (marcar)
   ```
5. Clique em "Create user"

**Passo 2: Adicionar à Tabela de Administradores**
```sql
-- Execute no SQL Editor do Supabase
INSERT INTO admins (email) 
VALUES ('admin@exemplo.com');

-- Verificar se foi criado
SELECT * FROM admins WHERE email = 'admin@exemplo.com';
```

**Passo 3: Teste de Acesso**
1. Acesse o painel administrativo: http://localhost:3000/login
2. Faça login com as credenciais criadas
3. Verifique se o acesso ao dashboard foi liberado

#### Script Automatizado

```sql
-- Função para criar administrador completo
CREATE OR REPLACE FUNCTION create_admin(
    admin_email VARCHAR,
    admin_password VARCHAR DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    admin_exists BOOLEAN;
BEGIN
    -- Verificar se já existe
    SELECT EXISTS(SELECT 1 FROM admins WHERE email = admin_email) INTO admin_exists;
    
    IF admin_exists THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Admin já existe',
            'email', admin_email
        );
    END IF;
    
    -- Adicionar à tabela admins
    INSERT INTO admins (email) VALUES (admin_email);
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Admin criado com sucesso. Criar usuário no Supabase Auth manualmente.',
        'email', admin_email,
        'next_steps', ARRAY[
            'Acessar Supabase Dashboard',
            'Criar usuário em Authentication > Users',
            'Testar login no painel administrativo'
        ]
    );
END;
$$ LANGUAGE plpgsql;

-- Uso da função
SELECT create_admin('novo.admin@empresa.com');
```

### 1.2 Remoção de Administradores

**Processo Seguro:**

```sql
-- 1. Verificar administradores existentes
SELECT 
    id,
    email,
    created_at,
    (SELECT COUNT(*) FROM admins) as total_admins
FROM admins;

-- 2. Remover da tabela admins (manter pelo menos 1 admin)
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM admins) > 1 THEN
        DELETE FROM admins WHERE email = 'admin.removido@empresa.com';
        RAISE NOTICE 'Admin removido com sucesso';
    ELSE
        RAISE EXCEPTION 'Não é possível remover o último administrador';
    END IF;
END $$;

-- 3. Opcional: Remover do Supabase Auth
-- (Fazer manualmente no Dashboard ou via API)
```

### 1.3 Gestão de Categorias

#### Criar Nova Categoria

```sql
-- Template para nova categoria
INSERT INTO categories (name, description, icon_url)
VALUES (
    'Nome da Categoria',
    'Descrição detalhada da categoria',
    'https://your-project.supabase.co/storage/v1/object/public/images/icons/categoria.png'
);

-- Verificar criação
SELECT 
    id,
    name,
    description,
    icon_url,
    created_at,
    (SELECT COUNT(*) FROM restaurantes WHERE category_id = categories.id) as restaurant_count
FROM categories
ORDER BY created_at DESC
LIMIT 5;
```

#### Reorganizar Categorias

```sql
-- Mover restaurantes de uma categoria para outra
UPDATE restaurantes 
SET category_id = 'nova-categoria-uuid'
WHERE category_id = 'categoria-antiga-uuid';

-- Remover categoria vazia
DELETE FROM categories 
WHERE id = 'categoria-antiga-uuid'
AND NOT EXISTS (
    SELECT 1 FROM restaurantes WHERE category_id = categories.id
);
```

### 1.4 Manutenção de Restaurantes

#### Auditoria de Dados

```sql
-- Verificar integridade dos dados
SELECT 
    'Restaurantes sem categoria' as issue,
    COUNT(*) as count
FROM restaurantes 
WHERE category_id IS NULL

UNION ALL

SELECT 
    'Restaurantes sem imagem' as issue,
    COUNT(*) as count
FROM restaurantes 
WHERE imagem_url IS NULL OR imagem_url = ''

UNION ALL

SELECT 
    'Restaurantes com coordenadas inválidas' as issue,
    COUNT(*) as count
FROM restaurantes 
WHERE latitude = 0 OR longitude = 0

UNION ALL

SELECT 
    'Restaurantes sem rating' as issue,
    COUNT(*) as count
FROM restaurantes 
WHERE rating IS NULL OR rating = 0;
```

#### Limpeza de Dados

```sql
-- Corrigir ratings zerados
UPDATE restaurantes 
SET rating = 4.0 
WHERE rating = 0 OR rating IS NULL;

-- Corrigir review_count negativos
UPDATE restaurantes 
SET review_count = 0 
WHERE review_count < 0;

-- Normalizar tags (remover duplicatas)
UPDATE restaurantes 
SET tags = (
    SELECT array_agg(DISTINCT unnest_tag ORDER BY unnest_tag)
    FROM unnest(tags) as unnest_tag
)
WHERE array_length(tags, 1) > 0;
```

## 2. Backup e Recovery

### 2.1 Estratégia de Backup

#### Backup Automático Diário

```bash
#!/bin/bash
# backup-daily.sh

# Configurações
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backups/taste-system"
SUPABASE_HOST="db.your-project.supabase.co"
SUPABASE_DB="postgres"
SUPABASE_USER="postgres"

# Criar diretório se não existir
mkdir -p $BACKUP_DIR

# Backup do schema
echo "Iniciando backup do schema..."
pg_dump --host=$SUPABASE_HOST \
        --port=5432 \
        --username=$SUPABASE_USER \
        --dbname=$SUPABASE_DB \
        --schema-only \
        --no-owner \
        --no-privileges \
        --file="$BACKUP_DIR/schema_$DATE.sql"

# Backup dos dados
echo "Iniciando backup dos dados..."
pg_dump --host=$SUPABASE_HOST \
        --port=5432 \
        --username=$SUPABASE_USER \
        --dbname=$SUPABASE_DB \
        --data-only \
        --no-owner \
        --no-privileges \
        --file="$BACKUP_DIR/data_$DATE.sql"

# Backup das configurações
echo "Backup das configurações..."
cp admin-panel/.env.local "$BACKUP_DIR/admin-panel-env_$DATE.backup"
cp taste_app/.env "$BACKUP_DIR/flutter-app-env_$DATE.backup"

# Compactar backups antigos (manter últimos 30 dias)
find $BACKUP_DIR -name "*.sql" -mtime +30 -exec gzip {} \;
find $BACKUP_DIR -name "*.gz" -mtime +90 -delete

echo "Backup concluído: $DATE"
```

#### Backup de Storage (Imagens)

```bash
#!/bin/bash
# backup-storage.sh

# Usar Supabase CLI para backup de storage
supabase storage download --project-ref your-project-ref \
                         --bucket images \
                         --destination ./storage-backup/

# Compactar backup
tar -czf "storage-backup-$(date +%Y%m%d).tar.gz" storage-backup/

# Limpar backup temporário
rm -rf storage-backup/
```

### 2.2 Procedimentos de Recovery

#### Restauração Completa

```bash
#!/bin/bash
# restore-system.sh

# Parâmetros
BACKUP_DATE=$1
BACKUP_DIR="/backups/taste-system"

if [ -z "$BACKUP_DATE" ]; then
    echo "Uso: $0 YYYYMMDD_HHMMSS"
    echo "Backups disponíveis:"
    ls -la $BACKUP_DIR/schema_*.sql | head -10
    exit 1
fi

# Verificar se arquivos existem
SCHEMA_FILE="$BACKUP_DIR/schema_$BACKUP_DATE.sql"
DATA_FILE="$BACKUP_DIR/data_$BACKUP_DATE.sql"

if [ ! -f "$SCHEMA_FILE" ] || [ ! -f "$DATA_FILE" ]; then
    echo "Arquivos de backup não encontrados para $BACKUP_DATE"
    exit 1
fi

echo "ATENÇÃO: Esta operação irá sobrescrever todos os dados!"
read -p "Deseja continuar? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operação cancelada"
    exit 1
fi

# Restaurar schema
echo "Restaurando schema..."
psql --host=$SUPABASE_HOST \
     --port=5432 \
     --username=$SUPABASE_USER \
     --dbname=$SUPABASE_DB \
     --file="$SCHEMA_FILE"

# Restaurar dados
echo "Restaurando dados..."
psql --host=$SUPABASE_HOST \
     --port=5432 \
     --username=$SUPABASE_USER \
     --dbname=$SUPABASE_DB \
     --file="$DATA_FILE"

echo "Restauração concluída!"
echo "Verifique a integridade dos dados e reinicie os serviços."
```

#### Restauração Seletiva

```sql
-- Restaurar apenas uma tabela específica
-- 1. Fazer backup da tabela atual
CREATE TABLE restaurantes_backup AS 
SELECT * FROM restaurantes;

-- 2. Limpar tabela
TRUNCATE TABLE restaurantes CASCADE;

-- 3. Restaurar dados específicos do backup
-- (executar comandos INSERT do arquivo de backup)

-- 4. Verificar integridade
SELECT 
    COUNT(*) as total_restaurantes,
    COUNT(CASE WHEN category_id IS NOT NULL THEN 1 END) as com_categoria,
    COUNT(CASE WHEN imagem_url IS NOT NULL THEN 1 END) as com_imagem
FROM restaurantes;

-- 5. Se OK, remover backup
-- DROP TABLE restaurantes_backup;
```

### 2.3 Monitoramento de Backup

```sql
-- Tabela para logs de backup
CREATE TABLE backup_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    backup_type VARCHAR(50) NOT NULL, -- 'full', 'schema', 'data', 'storage'
    status VARCHAR(20) NOT NULL, -- 'success', 'failed', 'partial'
    file_path VARCHAR(500),
    file_size_mb DECIMAL(10,2),
    duration_seconds INTEGER,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Função para registrar backup
CREATE OR REPLACE FUNCTION log_backup(
    backup_type_param VARCHAR,
    status_param VARCHAR,
    file_path_param VARCHAR DEFAULT NULL,
    file_size_mb_param DECIMAL DEFAULT NULL,
    duration_seconds_param INTEGER DEFAULT NULL,
    error_message_param TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    log_id UUID;
BEGIN
    INSERT INTO backup_logs (
        backup_type, status, file_path, file_size_mb, 
        duration_seconds, error_message
    ) VALUES (
        backup_type_param, status_param, file_path_param, 
        file_size_mb_param, duration_seconds_param, error_message_param
    ) RETURNING id INTO log_id;
    
    RETURN log_id;
END;
$$ LANGUAGE plpgsql;

-- View para monitoramento
CREATE VIEW backup_status AS
SELECT 
    backup_type,
    status,
    COUNT(*) as count,
    MAX(created_at) as last_backup,
    AVG(duration_seconds) as avg_duration,
    SUM(file_size_mb) as total_size_mb
FROM backup_logs 
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY backup_type, status
ORDER BY backup_type, status;
```

## 3. Troubleshooting Avançado

### 3.1 Diagnóstico de Performance

#### Análise de Queries Lentas

```sql
-- Habilitar log de queries lentas (executar como superuser)
ALTER SYSTEM SET log_min_duration_statement = 1000; -- 1 segundo
SELECT pg_reload_conf();

-- Verificar queries mais executadas
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements 
WHERE query LIKE '%restaurantes%'
ORDER BY total_time DESC
LIMIT 10;

-- Analisar plano de execução da busca
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM search_restaurants(
    'pizza', NULL, -23.5505, -46.6333, 10, 0, NULL, NULL, NULL, NULL, 20, 0
);
```

#### Otimização de Índices

```sql
-- Verificar uso de índices
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Identificar índices não utilizados
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes 
WHERE idx_scan = 0
AND schemaname = 'public';

-- Recriar estatísticas
ANALYZE restaurantes;
ANALYZE categories;
ANALYZE reviews;
```

### 3.2 Problemas de Conectividade

#### Teste de Conexão Supabase

```bash
#!/bin/bash
# test-connectivity.sh

echo "Testando conectividade com Supabase..."

# Teste de DNS
echo "1. Teste de DNS:"
nslookup your-project.supabase.co

# Teste de conectividade HTTP
echo "2. Teste HTTP:"
curl -I https://your-project.supabase.co/rest/v1/

# Teste de conectividade PostgreSQL
echo "3. Teste PostgreSQL:"
psql "postgresql://postgres:password@db.your-project.supabase.co:5432/postgres" \
     -c "SELECT 'Conexão OK' as status, NOW() as timestamp;"

# Teste de autenticação
echo "4. Teste de Auth:"
curl -X POST https://your-project.supabase.co/auth/v1/token \
     -H "Content-Type: application/json" \
     -H "apikey: your-anon-key" \
     -d '{"email":"test@example.com","password":"test123"}'
```

#### Diagnóstico de Latência

```sql
-- Função para medir latência de operações
CREATE OR REPLACE FUNCTION measure_latency()
RETURNS TABLE (
    operation VARCHAR,
    avg_latency_ms DECIMAL,
    min_latency_ms DECIMAL,
    max_latency_ms DECIMAL,
    sample_count INTEGER
) AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    i INTEGER;
BEGIN
    -- Teste de SELECT simples
    start_time := clock_timestamp();
    FOR i IN 1..10 LOOP
        PERFORM COUNT(*) FROM restaurantes;
    END LOOP;
    end_time := clock_timestamp();
    
    RETURN QUERY SELECT 
        'SELECT COUNT' as operation,
        EXTRACT(EPOCH FROM (end_time - start_time)) * 100 as avg_latency_ms,
        EXTRACT(EPOCH FROM (end_time - start_time)) * 100 as min_latency_ms,
        EXTRACT(EPOCH FROM (end_time - start_time)) * 100 as max_latency_ms,
        10 as sample_count;
    
    -- Teste de busca complexa
    start_time := clock_timestamp();
    FOR i IN 1..5 LOOP
        PERFORM * FROM search_restaurants('pizza', NULL, -23.5505, -46.6333, 10, 0, NULL, NULL, NULL, NULL, 10, 0);
    END LOOP;
    end_time := clock_timestamp();
    
    RETURN QUERY SELECT 
        'SEARCH FUNCTION' as operation,
        EXTRACT(EPOCH FROM (end_time - start_time)) * 200 as avg_latency_ms,
        EXTRACT(EPOCH FROM (end_time - start_time)) * 200 as min_latency_ms,
        EXTRACT(EPOCH FROM (end_time - start_time)) * 200 as max_latency_ms,
        5 as sample_count;
END;
$$ LANGUAGE plpgsql;

-- Executar teste
SELECT * FROM measure_latency();
```

### 3.3 Problemas de Autenticação

#### Reset de Senha de Admin

```sql
-- Verificar admins existentes
SELECT 
    a.id,
    a.email,
    a.created_at,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM auth.users u 
            WHERE u.email = a.email
        ) THEN 'Usuário existe no Auth'
        ELSE 'Usuário NÃO existe no Auth'
    END as auth_status
FROM admins a;

-- Função para verificar status de autenticação
CREATE OR REPLACE FUNCTION check_admin_auth_status(admin_email VARCHAR)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    admin_exists BOOLEAN;
    auth_user_exists BOOLEAN;
BEGIN
    -- Verificar se existe na tabela admins
    SELECT EXISTS(SELECT 1 FROM admins WHERE email = admin_email) INTO admin_exists;
    
    -- Verificar se existe no auth.users
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = admin_email) INTO auth_user_exists;
    
    result := jsonb_build_object(
        'email', admin_email,
        'is_admin', admin_exists,
        'has_auth_user', auth_user_exists,
        'status', CASE 
            WHEN admin_exists AND auth_user_exists THEN 'OK'
            WHEN admin_exists AND NOT auth_user_exists THEN 'MISSING_AUTH_USER'
            WHEN NOT admin_exists AND auth_user_exists THEN 'NOT_ADMIN'
            ELSE 'NOT_FOUND'
        END,
        'action_needed', CASE 
            WHEN admin_exists AND NOT auth_user_exists THEN 'Criar usuário no Supabase Auth'
            WHEN NOT admin_exists AND auth_user_exists THEN 'Adicionar email à tabela admins'
            WHEN NOT admin_exists AND NOT auth_user_exists THEN 'Criar admin completo'
            ELSE 'Nenhuma ação necessária'
        END
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Usar a função
SELECT check_admin_auth_status('admin@empresa.com');
```

#### Limpeza de Sessões

```sql
-- Verificar sessões ativas
SELECT 
    id,
    user_id,
    created_at,
    updated_at,
    expires_at
FROM auth.sessions 
WHERE expires_at > NOW()
ORDER BY updated_at DESC;

-- Revogar sessões expiradas
DELETE FROM auth.sessions 
WHERE expires_at < NOW();

-- Revogar todas as sessões de um usuário específico
DELETE FROM auth.sessions 
WHERE user_id = 'user-uuid-here';
```

## 4. Monitoramento e Alertas

### 4.1 Dashboard de Monitoramento

```sql
-- View para dashboard de sistema
CREATE VIEW system_dashboard AS
SELECT 
    'Restaurantes' as metric,
    COUNT(*)::TEXT as value,
    'Total de restaurantes cadastrados' as description
FROM restaurantes

UNION ALL

SELECT 
    'Categorias' as metric,
    COUNT(*)::TEXT as value,
    'Total de categorias ativas' as description
FROM categories

UNION ALL

SELECT 
    'Admins' as metric,
    COUNT(*)::TEXT as value,
    'Total de administradores' as description
FROM admins

UNION ALL

SELECT 
    'Reviews' as metric,
    COUNT(*)::TEXT as value,
    'Total de avaliações' as description
FROM reviews

UNION ALL

SELECT 
    'Storage Usage' as metric,
    pg_size_pretty(pg_database_size(current_database())) as value,
    'Tamanho total do banco' as description

UNION ALL

SELECT 
    'Uptime' as metric,
    EXTRACT(EPOCH FROM (NOW() - pg_postmaster_start_time()))::INTEGER::TEXT || ' segundos' as value,
    'Tempo de atividade do PostgreSQL' as description;
```

### 4.2 Alertas Automáticos

```sql
-- Função para verificar saúde do sistema
CREATE OR REPLACE FUNCTION system_health_check()
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    restaurant_count INTEGER;
    admin_count INTEGER;
    recent_errors INTEGER;
    avg_response_time DECIMAL;
BEGIN
    -- Contadores básicos
    SELECT COUNT(*) INTO restaurant_count FROM restaurantes;
    SELECT COUNT(*) INTO admin_count FROM admins;
    
    -- Verificar erros recentes
    SELECT COUNT(*) INTO recent_errors 
    FROM integration_logs 
    WHERE status = 'error' 
    AND created_at > NOW() - INTERVAL '1 hour';
    
    -- Tempo de resposta médio
    SELECT AVG(duration_ms) INTO avg_response_time
    FROM integration_logs 
    WHERE created_at > NOW() - INTERVAL '1 hour'
    AND duration_ms IS NOT NULL;
    
    result := jsonb_build_object(
        'timestamp', NOW(),
        'status', CASE 
            WHEN admin_count = 0 THEN 'CRITICAL'
            WHEN recent_errors > 10 THEN 'WARNING'
            WHEN avg_response_time > 5000 THEN 'WARNING'
            ELSE 'OK'
        END,
        'metrics', jsonb_build_object(
            'restaurants', restaurant_count,
            'admins', admin_count,
            'recent_errors', recent_errors,
            'avg_response_time_ms', avg_response_time
        ),
        'alerts', CASE 
            WHEN admin_count = 0 THEN jsonb_build_array('Nenhum administrador configurado')
            WHEN recent_errors > 10 THEN jsonb_build_array('Muitos erros na última hora')
            WHEN avg_response_time > 5000 THEN jsonb_build_array('Tempo de resposta alto')
            ELSE jsonb_build_array()
        END
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Executar verificação
SELECT system_health_check();
```

### 4.3 Logs Estruturados

```sql
-- Configurar logging estruturado
CREATE TABLE system_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    level VARCHAR(10) NOT NULL, -- 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'
    component VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    context JSONB DEFAULT '{}',
    user_id UUID,
    session_id VARCHAR(100),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para consulta eficiente
CREATE INDEX idx_system_logs_level ON system_logs(level);
CREATE INDEX idx_system_logs_component ON system_logs(component);
CREATE INDEX idx_system_logs_created_at ON system_logs(created_at DESC);
CREATE INDEX idx_system_logs_user_id ON system_logs(user_id);

-- Função para log estruturado
CREATE OR REPLACE FUNCTION log_event(
    level_param VARCHAR,
    component_param VARCHAR,
    message_param TEXT,
    context_param JSONB DEFAULT '{}'
)
RETURNS UUID AS $$
DECLARE
    log_id UUID;
BEGIN
    INSERT INTO system_logs (
        level, component, message, context, user_id
    ) VALUES (
        level_param, component_param, message_param, context_param, auth.uid()
    ) RETURNING id INTO log_id;
    
    RETURN log_id;
END;
$$ LANGUAGE plpgsql;

-- Exemplos de uso
SELECT log_event('INFO', 'admin-panel', 'Restaurante criado', 
    jsonb_build_object('restaurant_id', 'uuid-here', 'name', 'Nome do Restaurante'));

SELECT log_event('ERROR', 'flutter-app', 'Falha na busca', 
    jsonb_build_object('query', 'pizza', 'error', 'Connection timeout'));
```

## 5. Atualizações e Versionamento

### 5.1 Processo de Atualização

#### Checklist de Atualização

```bash
#!/bin/bash
# update-system.sh

echo "=== CHECKLIST DE ATUALIZAÇÃO SISTEMA TASTE ==="
echo

# 1. Backup completo
echo "1. Realizando backup completo..."
./backup-daily.sh
echo "✅ Backup concluído"

# 2. Verificar saúde do sistema
echo "2. Verificando saúde do sistema..."
psql -c "SELECT system_health_check();" > health-check-pre.json
echo "✅ Health check salvo em health-check-pre.json"

# 3. Atualizar dependências
echo "3. Atualizando dependências..."
cd admin-panel
npm audit fix
npm update
cd ../taste_app
flutter pub upgrade
cd ..
echo "✅ Dependências atualizadas"

# 4. Executar testes
echo "4. Executando testes..."
cd admin-panel
npm test
cd ../taste_app
flutter test
cd ..
echo "✅ Testes executados"

# 5. Deploy gradual
echo "5. Iniciando deploy..."
echo "⚠️  Monitore os logs durante o deploy"

# 6. Verificação pós-deploy
echo "6. Aguardando deploy... (pressione Enter após conclusão)"
read

psql -c "SELECT system_health_check();" > health-check-post.json
echo "✅ Verificação pós-deploy concluída"

echo
echo "=== ATUALIZAÇÃO CONCLUÍDA ==="
echo "Verifique os arquivos health-check-*.json para comparar o estado do sistema"
```

### 5.2 Migrações de Banco

#### Template de Migração

```sql
-- Migration: YYYY-MM-DD_description.sql
-- Versão: 1.x.x
-- Descrição: [Descrição da migração]

-- Verificar versão atual
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'schema_migrations') THEN
        CREATE TABLE schema_migrations (
            version VARCHAR(50) PRIMARY KEY,
            description TEXT,
            applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END $$;

-- Verificar se migração já foi aplicada
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM schema_migrations WHERE version = '2024-01-15_add_new_features') THEN
        RAISE EXCEPTION 'Migração já aplicada: 2024-01-15_add_new_features';
    END IF;
END $$;

-- === INÍCIO DA MIGRAÇÃO ===

-- Exemplo: Adicionar nova coluna
ALTER TABLE restaurantes 
ADD COLUMN IF NOT EXISTS delivery_radius INTEGER DEFAULT 5;

-- Exemplo: Criar nova tabela
CREATE TABLE IF NOT EXISTS promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurantes(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percent INTEGER CHECK (discount_percent > 0 AND discount_percent <= 100),
    valid_from TIMESTAMP WITH TIME ZONE NOT NULL,
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_promotions_restaurant ON promotions(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_promotions_active ON promotions(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_promotions_valid ON promotions(valid_from, valid_until);

-- Atualizar políticas RLS
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active promotions" ON promotions
    FOR SELECT USING (is_active = true AND valid_from <= NOW() AND valid_until >= NOW());

CREATE POLICY "Admin can manage promotions" ON promotions
    FOR ALL USING (
        auth.role() = 'authenticated' AND 
        auth.jwt() ->> 'email' IN (SELECT email FROM admins)
    );

-- === FIM DA MIGRAÇÃO ===

-- Registrar migração
INSERT INTO schema_migrations (version, description)
VALUES ('2024-01-15_add_new_features', 'Adicionar sistema de promoções e raio de entrega');

-- Verificar integridade
DO $$
DECLARE
    promotion_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO promotion_count FROM promotions;
    RAISE NOTICE 'Migração concluída. Promoções criadas: %', promotion_count;
END $$;
```

### 5.3 Rollback de Migrações

```sql
-- Rollback: YYYY-MM-DD_description_rollback.sql

-- Verificar se migração foi aplicada
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM schema_migrations WHERE version = '2024-01-15_add_new_features') THEN
        RAISE EXCEPTION 'Migração não foi aplicada: 2024-01-15_add_new_features';
    END IF;
END $$;

-- === INÍCIO DO ROLLBACK ===

-- Remover políticas
DROP POLICY IF EXISTS "Public can view active promotions" ON promotions;
DROP POLICY IF EXISTS "Admin can manage promotions" ON promotions;

-- Remover tabela
DROP TABLE IF EXISTS promotions;

-- Remover coluna
ALTER TABLE restaurantes 
DROP COLUMN IF EXISTS delivery_radius;

-- === FIM DO ROLLBACK ===

-- Remover registro de migração
DELETE FROM schema_migrations 
WHERE version = '2024-01-15_add_new_features';

RAISE NOTICE 'Rollback concluído para migração: 2024-01-15_add_new_features';
```

---

## ✅ Checklist de Manutenção Mensal

### Tarefas Obrigatórias

- [ ] **Backup Completo**
  - [ ] Executar backup do banco de dados
  - [ ] Backup das configurações (.env files)
  - [ ] Backup do storage (imagens)
  - [ ] Testar restauração em ambiente de teste

- [ ] **Auditoria de Segurança**
  - [ ] Revisar lista de administradores
  - [ ] Verificar políticas RLS
  - [ ] Analisar logs de acesso
  - [ ] Atualizar senhas se necessário

- [ ] **Performance**
  - [ ] Analisar queries lentas
  - [ ] Verificar uso de índices
  - [ ] Executar ANALYZE nas tabelas principais
  - [ ] Revisar logs de performance

- [ ] **Integridade de Dados**
  - [ ] Executar auditoria de dados
  - [ ] Verificar relacionamentos órfãos
  - [ ] Validar coordenadas GPS
  - [ ] Limpar dados inconsistentes

- [ ] **Atualizações**
  - [ ] Verificar atualizações do Supabase
  - [ ] Atualizar dependências do admin-panel
  - [ ] Atualizar dependências do Flutter
  - [ ] Aplicar patches de segurança

- [ ] **Monitoramento**
  - [ ] Revisar alertas do sistema
  - [ ] Analisar métricas de uso
  - [ ] Verificar capacidade de storage
  - [ ] Monitorar crescimento da base de dados

### Tarefas Opcionais

- [ ] **Otimização**
  - [ ] Revisar e otimizar queries
  - [ ] Implementar novos índices se necessário
  - [ ] Otimizar imagens no storage
  - [ ] Revisar cache strategies

- [ ] **Documentação**
  - [ ] Atualizar documentação técnica
  - [ ] Revisar procedimentos de troubleshooting
  - [ ] Documentar mudanças recentes
  - [ ] Atualizar guias de usuário

---

**📞 Contatos de Emergência:**
- Suporte Supabase: https://supabase.com/support
- Documentação: https://supabase.com/docs
- Status Page: https://status.supabase.com

**🔧 Ferramentas Úteis:**
- Supabase CLI: `npm install -g supabase`
- PostgreSQL Client: `psql`
- Backup Tools: `pg_dump`, `pg_restore`
- Monitoring: Supabase Dashboard Analytics