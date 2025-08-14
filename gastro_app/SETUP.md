# 🍽️ Gastro App - Guia de Configuração

## Pré-requisitos

1. **Flutter SDK** instalado e configurado no PATH
2. **Android Studio** com emulador ou dispositivo Android físico
3. **Git** para versionamento

## Configuração do Ambiente

### 1. Criar arquivo .env

Crie um arquivo `.env` na raiz do projeto gastro_app (gastro_app/.env) com o seguinte conteúdo:

```env
SUPABASE_URL=https://gnosarnyuiyrbcdwkfto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ

# Para usar com Google Maps (opcional)
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

### 2. Instalar dependências

```bash
flutter pub get
```

### 3. Verificar instalação

```bash
flutter doctor
```

### 4. Configurar Google Maps (Opcional)

Para usar a aba Mapa na tela de resultados:

1. **Obter API Key do Google Maps**:
   - Acesse [Google Cloud Console](https://console.cloud.google.com/)
   - Ative "Maps SDK for Android"
   - Crie uma API Key

2. **Configurar permissões Android**:
   - Veja o arquivo `CONFIGURACAO_ANDROID.md` para detalhes completos
   - Adicione permissões de localização no AndroidManifest.xml

3. **Adicionar API Key no .env**:
   ```env
   GOOGLE_MAPS_API_KEY=sua_api_key_aqui
   ```

### 5. Executar o projeto

```bash
flutter run
```

## Funcionalidades Implementadas

### ✅ Tela Inicial com Busca por Desejo

- **Campo de busca inteligente**: Digite frases como "lugar tranquilo pra café da manhã"
- **Processamento com IA simulada**: Analisa o texto e extrai:
  - Tipo de estabelecimento (café, pizzaria, bar, etc.)
  - Tags de ambiente (romântico, casual, família, etc.)
  - Localização (se mencionada)
- **Busca no Supabase**: Filtra restaurantes baseado na análise da IA
- **Interface amigável**: 
  - Loading durante a busca
  - Sugestões de busca clicáveis
  - Mensagem quando não há resultados
  - Navegação automática para resultados

### ✅ Sistema de Geolocalização Inteligente

- **Sugestões baseadas na localização**:
  - Widget "Sugestões Próximas" na tela inicial
  - Carregamento automático de restaurantes próximos
  - Tratamento inteligente de permissões negadas
  - Botões para reativar ou configurar localização
- **Indicadores de distância**:
  - Badges coloridos nos cards (verde=próximo, vermelho=longe)
  - Formatação inteligente (metros/quilômetros)
  - Atualização em tempo real ao mover no mapa
- **Controles avançados**:
  - Slider de distância (1-20 km) com feedback visual
  - Contador dinâmico de resultados filtrados
  - Círculo de proximidade no mapa (toggle on/off)
  - Mensagens contextuais baseadas no status da localização

### ✅ Tela de Resultados (Lista + Mapa)

- **TabBar com duas abas**: Lista e Mapa
- **Aba Lista**:
  - Cards com imagem, nome, descrição e tags
  - **🆕 Badges de distância coloridos**: Verde (≤500m), laranja (≤2km), vermelho (>5km)
  - Fallback para imagens indisponíveis
  - Botões para favoritar e ver detalhes
  - Loading de imagens com placeholder
- **Aba Mapa**:
  - Google Maps com markers dos restaurantes
  - **🆕 Círculo de raio**: Visualização da área de busca (toggle)
  - Clique no marker abre preview do restaurante
  - Localização atual do usuário com permissões robustas
  - Botão para atualizar resultados
- **Filtros inteligentes**:
  - Slider de distância (1-20 km) com indicadores visuais
  - **🆕 Labels contextuais**: "até X km de você" vs "do centro de SP"
  - Filtro em tempo real baseado na localização
  - Contador de resultados filtrados
- **Estados adaptativos**: 
  - Diferentes mensagens baseadas no status da localização
  - Fallback automático para localização padrão (São Paulo)
  - Feedback visual para cada estado (solicitando, negada, erro)

### 🎯 Exemplos de Busca

Teste essas frases no campo de busca:

1. **"lugar tranquilo pra café da manhã"**
   - Detecta: tipo=café, tags=[romântico, brunch, casual]

2. **"pizza artesanal com a família"**
   - Detecta: tipo=pizzaria, tags=[família, pizza artesanal]

3. **"bar descontraído no centro"**
   - Detecta: tipo=bar, tags=[casual, happy hour], localização=Centro

4. **"comida vegana saudável"**
   - Detecta: tipo=vegetariano, tags=[vegano, saudável, orgânico]

### 🎨 Interface

- **Design moderno**: Cores claras, fonte amigável
- **Cards informativos**: Nome, tipo, descrição, tags
- **Botões de ação**: Ver detalhes e favoritar
- **Feedback visual**: Loading, estados vazios, erros

## Estrutura do Código

```
lib/
├── models/
│   ├── restaurante.dart         # Modelo de dados
│   ├── usuario.dart
│   └── experiencia.dart
├── services/
│   ├── supabase_service.dart      # Configuração Supabase
│   ├── restaurante_service.dart   # CRUD restaurantes + filtros + proximidade
│   ├── localizacao_service.dart   # 🆕 Gerenciamento de geolocalização
│   ├── usuario_service.dart
│   └── ai_service.dart            # Simulação IA para busca
├── screens/
│   ├── home_screen.dart           # Tela inicial com busca + sugestões próximas
│   └── resultados_screen.dart     # Tela de resultados (Lista + Mapa + filtros)
├── widgets/
│   ├── restaurante_card.dart      # Card de restaurante (com badges de distância)
│   ├── restaurante_imagem.dart    # Widget de imagem com fallback
│   ├── sugestoes_proximas.dart    # 🆕 Widget de sugestões baseadas na localização
│   └── distancia_badge.dart       # 🆕 Badge colorido de distância
├── utils/
│   └── providers.dart           # Estados Riverpod
└── main.dart
```

## Database

O projeto usa as seguintes tabelas no Supabase:

- **restaurantes**: Nome, tipo, descrição, tags, localização
- **usuarios**: Dados do usuário e favoritos
- **experiencias**: Avaliações com emoji e comentários
- **admins**: Usuários administrativos

## Próximos Passos

- [x] ~~Tela de resultados com Lista e Mapa~~
- [x] ~~Integração com Google Maps~~
- [x] ~~Filtros por distância~~
- [ ] Implementar tela de detalhes do restaurante
- [ ] Sistema de favoritos funcionando
- [ ] Autenticação de usuários
- [ ] IA real (GPT/Claude) em vez da simulação
- [ ] Filtros avançados (preço, avaliação)
- [ ] Sistema de avaliações
- [ ] Notificações push
- [ ] Modo offline

## Troubleshooting

### Flutter não encontrado
```bash
# Verifique se o Flutter está no PATH
flutter --version

# Se não estiver, adicione ao PATH ou reinstale
```

### Erros de dependências
```bash
# Limpe o cache e reinstale
flutter clean
flutter pub get
```

### Problemas com Supabase
- Verifique se o arquivo .env foi criado corretamente
- Confirme se as credenciais estão corretas
- Teste a conexão no Supabase Dashboard

---

**Desenvolvido com Flutter + Supabase + Riverpod** 🚀 