# Gastro App - Descoberta de Experiências Gastronômicas

Este repositório contém dois projetos integrados:

- **`gastro_app/`** - Aplicativo móvel Flutter
- **`admin-panel/`** - Painel administrativo Next.js

## 🏗️ Estrutura do Projeto

```
APP/
├── gastro_app/          # App móvel Flutter
│   ├── lib/
│   │   ├── models/      # Modelos de dados
│   │   ├── screens/     # Telas do app
│   │   ├── services/    # Serviços (Supabase, APIs)
│   │   ├── widgets/     # Componentes reutilizáveis
│   │   └── utils/       # Utilitários e providers
│   └── pubspec.yaml
├── admin-panel/         # Painel admin Next.js
│   ├── src/
│   │   ├── app/         # Páginas (App Router)
│   │   ├── components/  # Componentes React
│   │   └── lib/         # Utilitários e configurações
│   └── package.json
└── README.md
```

## 🗄️ Banco de Dados (Supabase)

### Tabelas Criadas:

- **`restaurantes`** - Dados dos estabelecimentos
- **`usuarios`** - Perfis dos usuários do app
- **`experiencias`** - Avaliações/comentários dos usuários
- **`admins`** - E-mails autorizados no painel admin

## ⚙️ Configuração

### 1. Variáveis de Ambiente

**Flutter (`gastro_app/.env`):**
```env
SUPABASE_URL=https://gnosarnyuiyrbcdwkfto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

**Next.js (`admin-panel/.env.local`):**
```env
NEXT_PUBLIC_SUPABASE_URL=https://gnosarnyuiyrbcdwkfto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ
```

### 2. Executar os Projetos

**Flutter:**
```bash
cd gastro_app
flutter pub get
flutter run
```

**Next.js:**
```bash
cd admin-panel
npm install
npm run dev
```

## 👤 Acesso Admin

- Email padrão: `admin@gastroapp.com`
- Para adicionar novos admins, insira o e-mail na tabela `admins` do Supabase

## 🚀 Próximos Passos

1. **Configurar Google Maps API Key** para o Flutter
2. **Implementar funcionalidades de upload de imagens**
3. **Adicionar mais filtros de busca**
4. **Implementar sistema de notificações**
5. **Criar testes automatizados**

## 📱 Tecnologias Utilizadas

- **Flutter** + Riverpod (Estado)
- **Next.js 14** + TypeScript + Tailwind CSS
- **Supabase** (Backend, Auth, Database)
- **shadcn/ui** (Componentes UI)

---

**Estrutura criada com sucesso!** ✅ 