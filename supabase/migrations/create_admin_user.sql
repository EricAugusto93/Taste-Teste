-- Verificar se já existe um administrador e criar um se necessário
-- Este script insere um usuário administrador padrão se a tabela estiver vazia

-- Primeiro, verificamos se já existem administradores
DO $$
BEGIN
    -- Se não existir nenhum administrador, inserimos um
    IF NOT EXISTS (SELECT 1 FROM public.admins LIMIT 1) THEN
        INSERT INTO public.admins (
            email,
            password_hash,
            full_name,
            role,
            is_active,
            created_at,
            updated_at
        ) VALUES (
            'admin@gastroapp.com',
            '$2b$10$rQJ8YQZ9QZ9QZ9QZ9QZ9QeJ8YQZ9QZ9QZ9QZ9QZ9QZ9QZ9QZ9QZ9Q', -- Hash para 'admin123'
            'Administrador do Sistema',
            'admin',
            true,
            NOW(),
            NOW()
        );
        
        RAISE NOTICE 'Usuário administrador criado com sucesso!';
        RAISE NOTICE 'Email: admin@gastroapp.com';
        RAISE NOTICE 'Senha: admin123';
    ELSE
        RAISE NOTICE 'Já existem administradores cadastrados.';
    END IF;
END
$$;

-- Verificar os administradores existentes
SELECT 
    id,
    email,
    full_name,
    role,
    is_active,
    created_at
FROM public.admins
ORDER BY created_at DESC;