# Gastro App - Painel Administrativo

Painel administrativo para gerenciamento de restaurantes do Gastro App, construído com Next.js 14, TypeScript, Tailwind CSS e Supabase.

## 🚀 Funcionalidades

- **Autenticação Segura**: Login via email com verificação na tabela `admins`
- **CRUD Completo**: Criar, editar, visualizar e excluir restaurantes
- **Upload de Imagens**: Upload direto para Supabase Storage
- **Interface Responsiva**: Design adaptável para desktop, tablet e mobile
- **Validação de Dados**: Validação completa no frontend e backend
- **Feedback Visual**: Toast notifications e estados de loading

## 🛠️ Tecnologias

- **Next.js 14** - Framework React com App Router
- **TypeScript** - Tipagem estática
- **Tailwind CSS** - Framework CSS utilitário
- **Supabase** - Backend as a Service (autenticação, banco de dados, storage)
- **Sonner** - Toast notifications

## 📋 Pré-requisitos

- Node.js 18+ 
- npm ou yarn
- Projeto Supabase configurado
- Tabelas `restaurantes` e `admins` criadas no Supabase

## ⚙️ Configuração

### 1. Instalar dependências
\`\`\`bash
npm install
\`\`\`

### 2. Configurar variáveis de ambiente
Crie um arquivo \`.env.local\` na raiz do projeto:

\`\`\`env
NEXT_PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua-chave-anonima
\`\`\`

### 3. Estrutura do banco de dados

#### Tabela \`restaurantes\`
\`\`\`sql
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
\`\`\`

#### Tabela \`admins\`
\`\`\`sql
CREATE TABLE admins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
\`\`\`

#### Storage bucket \`images\`
- Criar bucket público chamado \`images\`
- Configurar políticas de upload para usuários autenticados

### 4. Adicionar administradores
Insira emails na tabela \`admins\`:
\`\`\`sql
INSERT INTO admins (email) VALUES ('admin@exemplo.com');
\`\`\`

## 🚀 Como executar

### Desenvolvimento
\`\`\`bash
npm run dev
\`\`\`

### Build para produção
\`\`\`bash
npm run build
npm start
\`\`\`

## 📱 Páginas e Funcionalidades

### `/login`
- Autenticação via email/senha
- Verificação automática se o usuário é admin
- Redirecionamento para acesso negado se não autorizado

### `/dashboard`
- Listagem de todos os restaurantes
- Ações de editar e excluir por linha
- Botão para adicionar novo restaurante
- Informações exibidas:
  - Nome e descrição
  - Imagem (miniatura)
  - Tipo de cozinha
  - Coordenadas (latitude/longitude)
  - Tags
  - Data de criação

### Modal de Formulário
- Campos para todos os dados do restaurante
- Upload de imagem com preview
- Sistema de tags com adição/remoção
- Validação em tempo real
- Tipos de cozinha predefinidos

### `/acesso-negado`
- Página exibida quando usuário não é admin
- Botão para logout e retorno ao login

## 🔒 Segurança

- **Autenticação**: Supabase Auth com verificação de email
- **Autorização**: Verificação na tabela `admins`
- **Middleware**: Proteção de rotas sensíveis
- **Validação**: Dados validados no frontend e backend
- **Storage**: Upload seguro para Supabase Storage

## 📂 Estrutura do Projeto

\`\`\`
admin-panel/
├── src/
│   ├── app/
│   │   ├── dashboard/
│   │   │   ├── components/
│   │   │   │   ├── RestauranteForm.tsx
│   │   │   │   └── RestauranteTable.tsx
│   │   │   └── page.tsx
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── acesso-negado/
│   │   │   └── page.tsx
│   │   ├── layout.tsx
│   │   └── globals.css
│   ├── lib/
│   │   └── supabase.ts
│   └── middleware.ts
├── .env.local
├── package.json
└── README.md
\`\`\`

## 🎨 Design System

### Cores
- **Primária**: Orange 600 (#EA580C)
- **Secundária**: Gray 900 (#111827)
- **Sucesso**: Green 600
- **Erro**: Red 600
- **Background**: Gray 50

### Componentes
- Botões com estados hover e disabled
- Inputs com foco e validação
- Tabelas responsivas
- Modal overlay
- Toast notifications
- Loading spinners

## 📱 Responsividade

- **Desktop**: Layout completo com tabela expandida
- **Tablet**: Layout adaptado com scroll horizontal
- **Mobile**: FAB para adicionar, tabela compacta

## 🔧 Customização

### Adicionar novos tipos de restaurante
Edite o array \`tiposRestaurante\` em \`RestauranteForm.tsx\`

### Modificar validações
Edite as funções de validação em \`RestauranteForm.tsx\`

### Adicionar campos
1. Atualize a interface \`Restaurante\` em \`supabase.ts\`
2. Adicione campos no formulário
3. Atualize funções CRUD

## 🐛 Solução de Problemas

### Erro de autenticação
- Verifique se as variáveis de ambiente estão corretas
- Confirme se o email está na tabela \`admins\`

### Erro de upload
- Verifique se o bucket \`images\` existe
- Confirme as políticas de storage

### Erro de conexão
- Verifique a URL do Supabase
- Confirme se as tabelas foram criadas

## 📝 Licença

Este projeto faz parte do Gastro App e é propriedade intelectual da equipe de desenvolvimento.

## 🤝 Contribuição

Para contribuir com o projeto:
1. Faça um fork do repositório
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Abra um Pull Request

## 📞 Suporte

Para dúvidas e suporte, entre em contato com a equipe de desenvolvimento. 