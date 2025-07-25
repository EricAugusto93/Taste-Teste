-- ============================================================================
-- CORREÇÃO CRÍTICA: ERROS PGRST204 E 42703 - REGISTRO DE EXPERIÊNCIAS
-- ============================================================================
-- 
-- ERROS IDENTIFICADOS:
-- 1. PGRST204: Could not find the 'nome' column of 'usuarios' in the schema cache
-- 2. 42703: record "new" has no field "updated_at"
-- 
-- SOLUÇÃO: Recriar completamente a estrutura da tabela usuarios
--

-- 1. REMOVER TABELA E TRIGGERS EXISTENTES (para recriação limpa)
DROP TRIGGER IF EXISTS trigger_criar_usuario ON auth.users;
DROP FUNCTION IF EXISTS criar_usuario_automatico();
DROP TABLE IF EXISTS usuarios CASCADE;

-- 2. RECRIAR TABELA USUARIOS COM ESTRUTURA CORRETA
CREATE TABLE usuarios (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    nome VARCHAR(255),
    favoritos UUID[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    -- Removido updated_at para evitar erro 42703
);

-- 3. CONFIGURAR RLS (ROW LEVEL SECURITY)
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS RLS
CREATE POLICY "Usuários podem ver apenas seus próprios dados" ON usuarios
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Usuários podem atualizar apenas seus próprios dados" ON usuarios
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Usuários podem inserir apenas seus próprios dados" ON usuarios
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 5. CRIAR FUNÇÃO DE TRIGGER SIMPLIFICADA (sem updated_at)
CREATE OR REPLACE FUNCTION criar_usuario_automatico()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO usuarios (id, email, nome)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        nome = COALESCE(EXCLUDED.nome, usuarios.nome);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. CRIAR TRIGGER
CREATE TRIGGER trigger_criar_usuario
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION criar_usuario_automatico();

-- 7. SINCRONIZAR USUÁRIOS EXISTENTES
INSERT INTO usuarios (id, email, nome)
SELECT 
    u.id,
    u.email,
    COALESCE(u.raw_user_meta_data->>'name', split_part(u.email, '@', 1))
FROM auth.users u
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    nome = COALESCE(EXCLUDED.nome, usuarios.nome);

-- 8. FORÇAR REFRESH DO SCHEMA CACHE
NOTIFY pgrst, 'reload schema';

-- 9. VERIFICAR RESULTADO
DO $$
DECLARE
    total_auth_users INTEGER;
    total_usuarios INTEGER;
    usuarios_sem_nome INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_auth_users FROM auth.users;
    SELECT COUNT(*) INTO total_usuarios FROM usuarios;
    SELECT COUNT(*) INTO usuarios_sem_nome FROM usuarios WHERE nome IS NULL OR nome = '';
    
    RAISE NOTICE '📊 RESULTADO DA CORREÇÃO:';
    RAISE NOTICE '   • Total usuários auth.users: %', total_auth_users;
    RAISE NOTICE '   • Total usuários tabela usuarios: %', total_usuarios;
    RAISE NOTICE '   • Usuários sem nome: %', usuarios_sem_nome;
    
    IF total_auth_users = total_usuarios AND usuarios_sem_nome = 0 THEN
        RAISE NOTICE '✅ CORREÇÃO APLICADA COM SUCESSO!';
        RAISE NOTICE '✅ Registro de experiências deve funcionar agora!';
    ELSE
        RAISE NOTICE '⚠️ Pode haver problemas remanescentes';
    END IF;
END $$;

-- 10. EXIBIR ESTRUTURA FINAL DA TABELA
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position; 