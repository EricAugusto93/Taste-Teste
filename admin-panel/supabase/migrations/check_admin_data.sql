-- Verificar se existe usuário administrador na tabela admins
SELECT 
  'Verificando dados na tabela admins:' as status;

SELECT 
  id,
  email,
  full_name,
  role,
  is_active,
  created_at
FROM public.admins;

-- Verificar se existe usuário no auth.users
SELECT 
  'Verificando dados no auth.users:' as status;

SELECT 
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email = 'admin@gastroapp.com';

-- Verificar permissões da tabela admins
SELECT 
  'Verificando permissões:' as status;

SELECT 
  grantee, 
  table_name, 
  privilege_type 
FROM information_schema.role_table_grants 
WHERE table_schema = 'public' 
  AND table_name = 'admins' 
  AND grantee IN ('anon', 'authenticated') 
ORDER BY table_name, grantee;