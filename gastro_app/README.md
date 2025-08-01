# 🍽️ Gastro App - Descoberta Gastronômica Inteligente

> Aplicativo Flutter para descoberta de experiências gastronômicas com sistema de categorias inteligente e busca por proximidade.

## ✨ Funcionalidades Principais

### 🎯 Sistema de Categorias Inteligente
- **8 categorias personalizadas** conectadas ao banco de dados real
- **Filtragem avançada** por tipo de estabelecimento e tags
- **Navegação fluida** entre categorias e resultados

### 📍 Descoberta por Proximidade
- **Geolocalização precisa** com raio de busca configurável
- **Indicadores visuais** de distância (1km, 3km, +3km)
- **Mapa interativo** com restaurantes próximos

### 🔐 Autenticação Robusta
- **Login/Registro** via Supabase
- **Gestão de sessões** com limpeza automática
- **Proteção de rotas** para funcionalidades premium

### 🎨 Interface Moderna
- **Design system** com paleta sofisticada
- **Animações fluidas** e transições suaves
- **Componentes reutilizáveis** e modulares

## 🚀 Início Rápido

### Pré-requisitos
- Flutter 3.32.8 ou superior
- Dart 3.0+
- Conta Supabase configurada

### Instalação

1. **Clone o repositório**
```bash
git clone git@github.com:GouveiaZx/tassste.git
cd tassste/gastro_app
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure as variáveis de ambiente**
```bash
cp env.example .env
```

Edite o arquivo `.env` com suas credenciais:
```env
SUPABASE_URL=sua_url_do_supabase
SUPABASE_ANON_KEY=sua_chave_anonima
GOOGLE_MAPS_API_KEY=sua_chave_do_google_maps
```

4. **Execute o aplicativo**
```bash
flutter run
```

## 📁 Arquitetura do Projeto

```
lib/
├── config/                   # Configurações de tema e cores
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_theme.dart
├── models/                   # Modelos de dados
│   ├── restaurante.dart      # Modelo de restaurante
│   ├── categoria.dart        # Modelo de categoria
│   ├── usuario.dart          # Modelo de usuário
│   └── experiencia.dart      # Modelo de experiência
├── screens/                  # Telas do aplicativo
│   ├── home_screen.dart      # Tela principal
│   ├── categoria_screen.dart # Tela de categoria
│   ├── proximidade_screen.dart # Tela de proximidade
│   ├── auth_screen.dart      # Tela de autenticação
│   └── favoritos_screen.dart # Tela de favoritos
├── services/                 # Serviços e APIs
│   ├── supabase_service.dart # Configuração Supabase
│   ├── restaurante_service.dart # Serviço de restaurantes
│   ├── auth_service.dart     # Serviço de autenticação
│   └── localizacao_service.dart # Serviço de localização
├── widgets/                  # Componentes reutilizáveis
│   ├── restaurante_card.dart # Card de restaurante
│   ├── categoria_card.dart   # Card de categoria
│   └── filtro_slider.dart    # Slider de filtros
└── utils/                    # Utilitários
    ├── providers.dart        # Providers do Riverpod
    └── snackbar_utils.dart   # Utilitários de UI
```

## 🎯 Categorias Disponíveis

| Categoria | Descrição | Filtros |
|-----------|-----------|----------|
| 🍽️ Jantar Romântico | Restaurantes para ocasiões especiais | Tipo: contemporâneo, italiano |
| ☕ Cafés Tranquilos | Cafeterias e espaços aconchegantes | Tipo: café, cafeteria |
| 🍔 Mata-fome | Opções rápidas e satisfatórias | Tipo: hamburgueria, lancheria |
| 🍰 Doces & Sobremesas | Docerias e confeitarias | Tipo: doceria, confeitaria |
| 🥐 Brunch Domingo | Perfeito para o fim de semana | Tags: brunch, domingo |
| 🍻 Para Beber | Bares e cervejarias | Tipo: bar, cervejaria |
| 🐕 Pet Friendly | Estabelecimentos que aceitam pets | Tags: pet friendly |
| 🌱 Saudável | Opções nutritivas e balanceadas | Tipo: saudável, natural |

## 🛠️ Tecnologias Utilizadas

- **Flutter 3.32.8** - Framework de desenvolvimento
- **Dart 3.0+** - Linguagem de programação
- **Supabase** - Backend as a Service
- **Provider** - Gestão de estado
- **Geolocator** - Serviços de localização
- **HTTP** - Requisições de rede

## 📊 Banco de Dados

### Estrutura Principal
- **restaurantes** - Dados dos estabelecimentos
- **usuarios** - Informações dos usuários
- **experiencias** - Avaliações e comentários
- **categorias** - Categorias personalizadas

### Campos Principais do Restaurante
```sql
- id (UUID)
- nome (TEXT)
- tipo (TEXT) -- Ex: 'italiano', 'cafeteria', 'hamburgueria'
- tags (TEXT[]) -- Ex: ['pet friendly', 'brunch']
- latitude/longitude (NUMERIC)
- avaliacao_media (NUMERIC)
- preco_medio (NUMERIC)
```

## 🚀 Funcionalidades Implementadas

- ✅ Sistema de categorias inteligente
- ✅ Busca por proximidade
- ✅ Autenticação completa
- ✅ Interface moderna e responsiva
- ✅ Filtragem avançada
- ✅ Gestão de favoritos
- ✅ Tratamento de erros robusto

## 🔄 Próximas Funcionalidades

- [ ] Sistema de avaliações com emojis
- [ ] Integração com mapas nativos
- [ ] Notificações push
- [ ] Modo offline
- [ ] Compartilhamento social
- [ ] Recomendações por IA

## 🐛 Problemas Conhecidos

- Nenhum problema crítico conhecido
- Para reportar bugs, abra uma issue no GitHub

## 📝 Changelog

Veja [CHANGELOG.md](CHANGELOG.md) para detalhes das mudanças implementadas.

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Desenvolvedor

**GouveiaZx**
- Email: gouveiarx@hotmail.com
- GitHub: [@GouveiaZx](https://github.com/GouveiaZx)

---

⭐ **Se este projeto foi útil para você, considere dar uma estrela!**