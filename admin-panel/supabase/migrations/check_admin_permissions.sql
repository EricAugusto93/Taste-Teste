-- Verificar permissões e RLS na tabela admins

-- Verificar se RLS está habilitado
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'admins' AND schemaname = 'public';

-- Verificar políticas RLS existentes
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'admins' AND schemaname = 'public';

-- Verificar permissões da tabela
SELECT 
  grantee,
  table_name,
  privilege_type
FROM information_schema.role_table_grants 
WHERE table_schema = 'public' 
  AND table_name = 'admins' 
  AND grantee IN ('anon', 'authenticated')
ORDER BY table_name, grantee;

-- Tentar inserir diretamente (para debug)
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
ON CONFLICT (email) DO NOTHING;

-- Verificar se o usuário existe agora
SELECT 'Usuários na tabela admins:' as status;
SELECT * FROM public.admins;