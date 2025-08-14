-- Criação da tabela user_profiles para complementar auth.users
-- Esta tabela armazena informações adicionais do perfil do usuário

CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT,
  birth_date DATE,
  city TEXT,
  bio TEXT,
  avatar_url TEXT,
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar Row Level Security (RLS)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Política para permitir que usuários vejam apenas seu próprio perfil
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

-- Política para permitir que usuários atualizem apenas seu próprio perfil
CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

-- Política para permitir que usuários insiram seu próprio perfil
CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Política para permitir que usuários deletem apenas seu próprio perfil
CREATE POLICY "Users can delete own profile" ON user_profiles
  FOR DELETE USING (auth.uid() = id);

-- Função para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para atualizar updated_at automaticamente
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Função para criar perfil automaticamente quando um usuário se registra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, full_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar perfil automaticamente
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Conceder permissões para as roles anon e authenticated
GRANT SELECT ON user_profiles TO anon;
GRANT ALL PRIVILEGES ON user_profiles TO authenticated;

-- Comentários para documentação
COMMENT ON TABLE user_profiles IS 'Tabela de perfis de usuário que complementa auth.users com informações adicionais';
COMMENT ON COLUMN user_profiles.id IS 'ID do usuário (referência para auth.users.id)';
COMMENT ON COLUMN user_profiles.full_name IS 'Nome completo do usuário';
COMMENT ON COLUMN user_profiles.phone IS 'Telefone do usuário (opcional)';
COMMENT ON COLUMN user_profiles.birth_date IS 'Data de nascimento do usuário (opcional)';
COMMENT ON COLUMN user_profiles.city IS 'Cidade do usuário (opcional)';
COMMENT ON COLUMN user_profiles.bio IS 'Biografia/descrição do usuário (opcional)';
COMMENT ON COLUMN user_profiles.avatar_url IS 'URL do avatar do usuário (opcional)';
COMMENT ON COLUMN user_profiles.preferences IS 'Preferências do usuário em formato JSON';