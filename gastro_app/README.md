# Gastro App - Flutter Mobile

Aplicativo móvel para descoberta de experiências gastronômicas.

## 📱 Funcionalidades

- **Busca de restaurantes** por localização e tipo
- **Mapa interativo** com restaurantes próximos
- **Sistema de favoritos** para salvar estabelecimentos
- **Avaliações com emojis** e comentários
- **Autenticação** via Supabase

## 🛠️ Configuração

### 1. Dependências

```bash
flutter pub get
```

### 2. Variáveis de Ambiente

Crie o arquivo `.env` baseado no `.env.example`:

```env
SUPABASE_URL=sua_url_do_supabase
SUPABASE_ANON_KEY=sua_chave_anonima
GOOGLE_MAPS_API_KEY=sua_chave_do_google_maps
```

### 3. Executar o App

```bash
flutter run
```

## 📁 Estrutura

```
lib/
├── main.dart                 # Ponto de entrada
├── models/                   # Modelos de dados
│   ├── restaurante.dart
│   ├── usuario.dart
│   └── experiencia.dart
├── screens/                  # Telas do aplicativo
│   └── home_screen.dart
├── services/                 # Serviços externos
│   ├── supabase_service.dart
│   ├── restaurante_service.dart
│   └── usuario_service.dart
├── widgets/                  # Componentes reutilizáveis
└── utils/                    # Utilitários
    └── providers.dart        # Providers do Riverpod
```

## 🔧 Gerenciamento de Estado

Utiliza **Riverpod** para gerenciamento de estado reativo:

- `authStateProvider` - Estado de autenticação
- `restaurantesProvider` - Lista de restaurantes
- `usuarioAtualProvider` - Dados do usuário logado
- `localizacaoAtualProvider` - Localização atual do usuário

## 🗄️ Integração com Supabase

- **Autenticação** - Login/registro de usuários
- **CRUD** - Operações com restaurantes e experiências
- **Row Level Security** - Políticas de acesso configuradas
- **Real-time** - Atualizações em tempo real (futuro)

## 📍 Google Maps

Para configurar o Google Maps:

1. Obtenha uma API Key no Google Cloud Console
2. Configure no arquivo `.env`
3. Adicione as permissões necessárias no Android

## 🚀 Deploy

Para gerar o APK:

```bash
flutter build apk --release
```

## 📚 Próximas Funcionalidades

- [ ] Mapa com marcadores de restaurantes
- [ ] Filtros avançados de busca
- [ ] Sistema de notificações
- [ ] Compartilhamento de experiências
- [ ] Suporte offline básico 