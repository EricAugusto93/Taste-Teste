# Taste - Estrutura do Projeto e Escopo

## 1. Visão Geral do Projeto

O **Taste** é um aplicativo mobile inovador que revoluciona a descoberta de restaurantes através de busca inteligente com IA interpretativa. O app permite que usuários façam buscas em linguagem natural (ex: "jantar romântico no Moinhos de Vento") e recebam sugestões personalizadas baseadas em geolocalização, preferências e contexto.

### 1.1 Objetivos Principais
- Simplificar a descoberta de restaurantes através de busca inteligente
- Oferecer recomendações contextuais baseadas em localização e preferências
- Criar uma experiência de usuário intuitiva e personalizada
- Construir uma base de dados curada de estabelecimentos gastronômicos

### 1.2 Proposta de Valor
- **Busca Natural**: Interface conversacional que entende intenções complexas
- **Geolocalização Inteligente**: Sugestões priorizadas por proximidade
- **Curadoria Especializada**: Conteúdo organizado por temas e ocasiões
- **Sistema de Avaliações**: Feedback rápido e eficiente dos usuários

## 2. Funcionalidades Principais

### 2.1 Busca Inteligente com IA (Core Feature)
**Descrição**: Sistema híbrido que combina IA interpretativa com base de dados própria

**Fluxo de Funcionamento**:
1. Usuário digita busca em linguagem natural
2. IA interpreta intenção, tipo de comida, ocasião, localização
3. Sistema converte em filtros estruturados
4. Busca na base própria de restaurantes
5. Aplica filtro de geolocalização
6. Exibe resultados em lista ou mapa

**Tecnologias**: API de IA (GPT/Claude), processamento de linguagem natural

### 2.2 Geolocalização
**Descrição**: Priorização automática baseada na localização do usuário

**Funcionalidades**:
- Permissão de localização no app
- Cálculo de distância dos estabelecimentos
- Opção de alteração manual de bairro/cidade
- Integração com mapas (Google Maps/Waze)

### 2.3 Visualização de Resultados
**Descrição**: Interface dupla para exibição de sugestões

**Modos de Visualização**:
- **Lista**: Cards empilhados com informações detalhadas
- **Mapa**: Pins geográficos com emojis representativos

**Informações por Card**:
- Nome do estabelecimento
- Descrição resumida
- Tags temáticas ("para dates", "delivery", "pet friendly")
- Distância e endereço
- Horário de funcionamento
- Botão favoritar
- Acesso direto a navegação

### 2.4 Sistema de Favoritos e Avaliações
**Descrição**: Gestão de experiências salvas com avaliação rápida

**Funcionalidades**:
- Marcação de locais como "visitado"
- Interface de avaliação (1-5 estrelas ou emojis)
- Uma avaliação por usuário por estabelecimento
- Cálculo automático de média geral
- Comentários opcionais (fora do MVP)

### 2.5 Exploração por Temas
**Descrição**: Curadoria manual organizada por categorias temáticas

**Categorias Planejadas**:
- "Para ir sozinho"
- "Para sair com a galera"
- "Restaurantes baratos e bons"
- "Melhor date da cidade"

**Características**:
- Curadoria manual controlada
- Atualizável via banco de dados
- Potencial para parcerias com influenciadores

### 2.6 Sistema de Autenticação (Opcional MVP)
**Descrição**: Perfil de usuário para personalização e histórico

**Funcionalidades**:
- Login/cadastro via Supabase Auth
- Sincronização de favoritos
- Histórico de buscas e visitas
- Preferências personalizadas

## 3. Arquitetura Geral

### 3.1 Stack Tecnológico
- **Frontend**: Flutter (multiplataforma)
- **Backend**: Supabase (BaaS completo)
- **Banco de Dados**: PostgreSQL (via Supabase)
- **Autenticação**: Supabase Auth
- **IA**: Integração via API (OpenAI/Anthropic)
- **Mapas**: Google Maps API
- **Geolocalização**: Flutter Geolocator

### 3.2 Arquitetura de Dados
**Entidades Principais**:
- Restaurantes (nome, localização, tags, horários)
- Usuários (perfil, preferências)
- Avaliações (nota, usuário, restaurante)
- Categorias Temáticas (curadoria manual)
- Histórico de Buscas (analytics e personalização)

### 3.3 Integrações Externas
- **API de IA**: Processamento de linguagem natural
- **Google Maps**: Visualização e navegação
- **Serviços de Geolocalização**: Posicionamento do usuário
- **APIs de Estabelecimentos**: Dados complementares (futuro)

## 4. User Interface Design

### 4.1 Design Style Baseado nas Referências Visuais

**Paleta de Cores Principal:**
- **Cor Primária**: Azul/Roxo gradiente (#4A5FBF → #6B73FF)
- **Cor Secundária**: Laranja vibrante (#FF6B47) para botões de ação
- **Cor de Fundo**: Azul escuro (#2D3561) para backgrounds principais
- **Texto Principal**: Branco (#FFFFFF)
- **Texto Secundário**: Amarelo/Dourado (#FFD700) para destaques
- **Cards**: Branco com bordas arredondadas

**Tipografia:**
- **Fonte Principal**: Poppins (conforme especificado)
- **Logo**: Script cursiva elegante para "taste"
- **Títulos**: Poppins Medium/SemiBold
- **Corpo**: Poppins Regular
- **Tamanhos**: 24px (títulos), 16px (corpo), 14px (legendas)

**Estilo de Botões:**
- **Primários**: Laranja (#FF6B47) com bordas arredondadas (radius: 25px)
- **Secundários**: Outline branco com texto branco
- **Categorias**: Cards coloridos com bordas arredondadas e gradientes

**Layout e Componentes:**
- **Cards**: Bordas arredondadas (radius: 15px), sombra sutil
- **Mapa**: Integrado diretamente nas telas, pins com emojis
- **Grid de Categorias**: 2x4 com cores vibrantes e gradientes
- **Bottom Navigation**: 3 tabs principais (Descubra, Mapa, Perfil)

### 4.2 Especificações Detalhadas por Tela

| Tela | Componente | Especificações Visuais |
|------|------------|------------------------|
| **Onboarding 1** | Background | Gradiente azul/roxo, imagem de comida centralizada |
| **Onboarding 1** | Título | "Busca inteligente" em branco, subtítulo explicativo |
| **Onboarding 1** | Botões | Login/Cadastro laranja, divididos verticalmente |
| **Onboarding 2** | Mapa | Google Maps integrado com pins de emoji |
| **Onboarding 2** | Texto | "Mapa + localização" com explicação sobre descoberta |
| **Onboarding 3** | Imagem | Pessoa usando celular, foco em listas personalizadas |
| **Home Principal** | Header | Logo "ti" minimalista, pergunta "Qual a sua vibe hoje?" |
| **Home Principal** | Busca | Campo laranja com placeholder conversacional |
| **Home Principal** | Mapa | Seção integrada mostrando localização atual |
| **Home Principal** | Categorias | Grid 2x4 com cores: laranja, azul, verde, roxo, amarelo |
| **Home Principal** | Bottom Nav | 3 tabs: Descubra (ativo), Mapa, Perfil |
| **Estado Vazio** | Background | Fundo azul gradiente igual ao padrão |
| **Estado Vazio** | Emoji | Emoji triste 😞 centralizado |
| **Estado Vazio** | Mensagem | "Hmm.. não encontramos nada com esse perfil por aqui." |
| **Estado Vazio** | Sugestão | "Que tal tentar em outro bairro ou ajustar sua busca?" |
| **Mapa com Busca** | Header | "Veja a que está por perto (ou onde você quiser)" |
| **Mapa com Busca** | Busca | Campo laranja "Sushi" com ícone de lupa |
| **Mapa com Busca** | Mapa | Google Maps com múltiplos pins de emoji de comida |
| **Mapa com Busca** | Pins | Emojis variados (🍕🍜🍔🥗) representando tipos de comida |
| **Detalhes Restaurante** | Header | Foto hero ocupando 40% da tela |
| **Detalhes Restaurante** | Título | Nome do restaurante em branco sobre a foto |
| **Detalhes Restaurante** | Avaliação | 5 estrelas amarelas com símbolo $ |
| **Detalhes Restaurante** | Descrição | Texto branco sobre fundo azul |
| **Detalhes Restaurante** | Mapa Pequeno | Seção de mapa integrada mostrando localização |
| **Detalhes Restaurante** | Botões Ação | 4 botões circulares: Instagram, Horário, Menu, Telefone |
| **Perfil** | Saudação | "Oie, [Nome]" personalizado |
| **Perfil** | Descrição | Texto explicativo sobre favoritos e descobertas |
| **Perfil** | Minhas Listas | Título em amarelo/dourado |
| **Perfil** | Lista 1 | "🍪 Quero conhecer" |
| **Perfil** | Lista 2 | "⭐ Meus favoritos" |
| **Perfil** | Lista 3 | "😐 Não sei se volto" |
| **Perfil** | Background | Ondas decorativas na parte inferior |
| **Lista Expandida** | Header | Título da lista em amarelo |
| **Lista Expandida** | Cards | Foto circular, nome do restaurante, descrição breve |
| **Lista Expandida** | Layout | Cards empilhados com divisores sutis |
| **Resultados** | Layout | Mapa no topo (1/3), lista de restaurantes embaixo (2/3) |
| **Resultados** | Cards | Foto, nome, descrição, avaliação com estrelas |
| **Resultados** | Header | "Encontramos lugares com a sua cara" |

### 4.3 Especificações de Categorias (Grid Colorido)

| Categoria | Cor de Fundo | Texto | Posição |
|-----------|--------------|-------|-----------|
| Date night | Laranja (#FF6B47) | Branco | Top-left |
| Para comer à toa | Vermelho (#E74C3C) | Branco | Top-right |
| Com vibe leve | Azul claro (#3498DB) | Branco | Row 2-left |
| Clássicos POA | Cinza (#95A5A6) | Branco | Row 2-right |
| Vontade de doce | Roxo (#9B59B6) | Branco | Row 3-left |
| Almoço de domingo | Amarelo (#F1C40F) | Preto | Row 3-right |
| Happy hour da firma | Verde (#2ECC71) | Branco | Row 4-left |
| Para comemorar aniversário | Laranja escuro (#E67E22) | Branco | Row 4-right |

### 4.4 Fluxo de Onboarding Visual

**Tela 1 - Busca Inteligente:**
- Background: Gradiente azul/roxo
- Logo: "taste TEST" em script + sans-serif
- Tagline: "Sua curadoria de experiências. Tudo em um só lugar"
- Imagem: Prato de comida com bebidas
- Descrição: Explicação sobre IA interpretativa
- Indicador: 3 pontos (primeiro ativo)

**Tela 2 - Mapa + Localização:**
- Mesmo background e header
- Imagem: Mapa do Google Maps com pins
- Título: "Mapa + localização"
- Descrição: Sobre descoberta por proximidade

**Tela 3 - Listas Personalizadas:**
- Mesmo padrão visual
- Imagem: Pessoa segurando celular
- Título: "Listas personalizadas"
- Descrição: Sobre organização de favoritos

### 4.5 Responsividade e Interações

- **Plataforma**: Mobile-first (iOS/Android)
- **Orientação**: Portrait principal
- **Gestos**: Swipe para onboarding, tap para seleção
- **Animações**: Transições suaves entre telas
- **Feedback**: Haptic feedback em botões importantes
- **Acessibilidade**: Contraste adequado, tamanhos de toque mínimos

## 5. Público-Alvo

### 5.1 Usuário Primário
- **Demografia**: Jovens adultos 25-40 anos
- **Comportamento**: Ativos digitalmente, valorizam experiências gastronômicas
- **Necessidades**: Descoberta rápida, recomendações confiáveis, conveniência

### 5.2 Casos de Uso Principais
- Busca por tipo específico de culinária
- Planejamento de encontros românticos
- Descoberta de novos lugares no bairro
- Recomendações para grupos e ocasiões especiais

## 6. Diferenciais Competitivos

### 5.1 Inovações Técnicas
- **IA Interpretativa**: Compreensão de contexto e intenção
- **Busca Híbrida**: Combinação de IA com base curada
- **Interface Conversacional**: Interação natural e intuitiva

### 5.2 Vantagens de Negócio
- **Curadoria Especializada**: Qualidade sobre quantidade
- **Foco Local**: Conhecimento profundo do mercado regional
- **Experiência Simplificada**: Menos cliques, mais resultados

## 7. Roadmap de Desenvolvimento

### 6.1 MVP (Versão 1.0)
- Busca inteligente básica
- Geolocalização e mapas
- Sistema de favoritos
- Curadoria temática inicial
- Autenticação opcional

### 6.2 Versões Futuras
- Sistema de reviews completo
- Integração com delivery
- Recomendações por ML
- Parcerias com estabelecimentos
- Programa de fidelidade

## 8. Métricas de Sucesso

### 7.1 Métricas Técnicas
- Tempo de resposta da busca < 2s
- Precisão da geolocalização > 95%
- Disponibilidade do sistema > 99%

### 7.2 Métricas de Negócio
- Taxa de conversão busca → visita
- Frequência de uso semanal
- Satisfação do usuário (NPS)
- Crescimento da base de dados

## 9. Considerações de Implementação

### 8.1 Desafios Técnicos
- Otimização de performance da IA
- Sincronização offline/online
- Escalabilidade da base de dados
- Precisão da geolocalização

### 8.2 Riscos e Mitigações
- **Dependência de APIs externas**: Implementar fallbacks
- **Qualidade dos dados**: Processo de curadoria rigoroso
- **Performance mobile**: Otimização contínua
- **Privacidade**: Compliance com LGPD

Este documento serve como guia principal para o desenvolvimento do projeto Taste, estabelecendo a visão, escopo e diretrizes técnicas para toda a equipe de desenvolvimento.