# 🔧 Configuração do Supabase para o Painel Admin

## 1. Configurar Variáveis de Ambiente

Crie o arquivo `.env.local` na raiz do projeto:

```env
NEXT_PUBLIC_SUPABASE_URL=https://SUA_URL_AQUI.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=SUA_CHAVE_ANONIMA_AQUI
```

> ⚠️ **Importante**: Substitua os valores pelas suas credenciais reais do Supabase!

## 2. Criar Tabelas no Supabase

### Tabela `restaurantes`
```sql
CREATE TABLE restaurantes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  imagem_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_restaurantes_updated_at 
    BEFORE UPDATE ON restaurantes 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

### Tabela `admins`
```sql
CREATE TABLE admins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 3. Configurar Storage

### Criar Bucket para Imagens
1. Vá para **Storage** no painel do Supabase
2. Clique em **New bucket**
3. Nome: `images`
4. **Public bucket**: ✅ Marque como público

### Configurar Políticas de Storage
Execute no SQL Editor:

```sql
-- Política para permitir upload de imagens (usuários autenticados)
INSERT INTO storage.policies (name, bucket_id, policy_definition, check)
VALUES (
    'Admin Upload Policy',
    'images',
    'bucket_id = ''images''',
    '(auth.role() = ''authenticated'')'
);

-- Política para leitura pública das imagens
INSERT INTO storage.policies (name, bucket_id, policy_definition, check)
VALUES (
    'Public Read Policy',
    'images',
    'bucket_id = ''images''',
    'true'
);
```

## 4. Configurar Autenticação

### Habilitar Email/Password
1. Vá para **Authentication > Settings**
2. Em **Auth Providers**, certifique-se que **Email** está habilitado

### Adicionar Primeiro Admin
Execute no SQL Editor:

```sql
-- Substitua 'seu-email@exemplo.com' pelo seu email real
INSERT INTO admins (email) 
VALUES ('seu-email@exemplo.com');
```

### Criar Usuário de Teste (Opcional)
1. Vá para **Authentication > Users**
2. Clique em **Add user**
3. Preencha:
   - **Email**: mesmo email que você adicionou na tabela `admins`
   - **Password**: sua senha escolhida
   - **Auto Confirm User**: ✅ Marque

## 5. Configurar Row Level Security (RLS)

### Para Restaurantes
```sql
-- Habilitar RLS
ALTER TABLE restaurantes ENABLE ROW LEVEL SECURITY;

-- Política para admin ler todos os restaurantes
CREATE POLICY "Admin can view all restaurants" ON restaurantes
    FOR SELECT 
    USING (
        auth.role() = 'authenticated' AND 
        auth.jwt() ->> 'email' IN (SELECT email FROM admins)
    );

-- Política para admin inserir restaurantes
CREATE POLICY "Admin can insert restaurants" ON restaurantes
    FOR INSERT 
    WITH CHECK (
        auth.role() = 'authenticated' AND 
        auth.jwt() ->> 'email' IN (SELECT email FROM admins)
    );

-- Política para admin atualizar restaurantes
CREATE POLICY "Admin can update restaurants" ON restaurantes
    FOR UPDATE 
    USING (
        auth.role() = 'authenticated' AND 
        auth.jwt() ->> 'email' IN (SELECT email FROM admins)
    );

-- Política para admin deletar restaurantes
CREATE POLICY "Admin can delete restaurants" ON restaurantes
    FOR DELETE 
    USING (
        auth.role() = 'authenticated' AND 
        auth.jwt() ->> 'email' IN (SELECT email FROM admins)
    );
```

### Para Admins
```sql
-- Habilitar RLS
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Política para admin ver outros admins
CREATE POLICY "Admin can view admins" ON admins
    FOR SELECT 
    USING (
        auth.role() = 'authenticated' AND 
        auth.jwt() ->> 'email' IN (SELECT email FROM admins)
    );
```

## 6. Testar a Configuração

### No Terminal:
```bash
# Instalar dependências
npm install

# Executar em desenvolvimento
npm run dev
```

### No Navegador:
1. Acesse `http://localhost:3000`
2. Deve redirecionar para `/login`
3. Faça login com suas credenciais
4. Se tudo estiver certo, será redirecionado para `/dashboard`

## 7. Dados de Exemplo (Opcional)

Para testar a funcionalidade, você pode inserir alguns restaurantes de exemplo:

```sql
INSERT INTO restaurantes (nome, tipo, descricao, latitude, longitude, tags) VALUES
('Restaurante Exemplo 1', 'Italiana', 'Deliciosa comida italiana no coração da cidade', -23.5505, -46.6333, ARRAY['pizza', 'massa', 'italiano']),
('Restaurante Exemplo 2', 'Brasileira', 'Autêntica culinária brasileira', -23.5489, -46.6388, ARRAY['feijoada', 'churrasco', 'brasileiro']),
('Restaurante Exemplo 3', 'Japonesa', 'Sushi fresco e pratos japoneses tradicionais', -23.5505, -46.6333, ARRAY['sushi', 'sashimi', 'japonês']);
```

## ✅ Checklist Final

- [ ] Arquivo `.env.local` criado com credenciais corretas
- [ ] Tabela `restaurantes` criada
- [ ] Tabela `admins` criada  
- [ ] Bucket `images` criado como público
- [ ] Políticas de storage configuradas
- [ ] Email/password habilitado na autenticação
- [ ] Primeiro admin adicionado na tabela `admins`
- [ ] Usuário criado no Auth com mesmo email
- [ ] RLS configurado para segurança
- [ ] Projeto testado com `npm run dev`

Se todos os itens estiverem marcados, seu painel administrativo está pronto para uso! 🎉 