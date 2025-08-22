-- Corrigir permissões RLS na tabela admins

-- Conceder permissões básicas para anon e authenticated
GRANT SELECT, INSERT, UPDATE, DELETE ON public.admins TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.admins TO authenticated;

-- Verificar se RLS está habilitado
SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'admins';

-- Criar política RLS para permitir acesso aos usuários autenticados
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.admins;
CREATE POLICY "Enable read access for authenticated users" ON public.admins
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.admins;
CREATE POLICY "Enable insert for authenticated users" ON public.admins
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.admins;
CREATE POLICY "Enable update for authenticated users" ON public.admins
    FOR UPDATE USING (true);

-- Inserir o usuário administrador
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
  '$2b$10$rQZ8kHWKQVz8kHWKQVz8kO',
  'Administrador do Sistema',
  'admin',
  true,
  NOW(),
  NOW()
)
ON CONFLICT (email) DO UPDATE SET
  password_hash = EXCLUDED.password_hash,
  full_name = EXCLUDED.full_name,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- Verificar se foi inserido
SELECT 'Verificação final:' as status;
SELECT * FROM public.admins WHERE email = 'admin@gastroapp.com';