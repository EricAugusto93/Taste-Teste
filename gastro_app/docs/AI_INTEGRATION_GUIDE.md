# Guia de Integração com IA - Gastro App

## 📋 Visão Geral

O Gastro App agora suporta interpretação inteligente de buscas usando múltiplos provedores de IA (OpenAI, Claude, Cohere) para transformar linguagem natural em filtros estruturados de busca.

## 🔧 Configuração

### 1. Variáveis de Ambiente

Copie o arquivo `env.example` para `.env` e configure suas chaves de API:

```bash
# OpenAI (Recomendado)
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_MODEL=gpt-3.5-turbo
OPENAI_MAX_TOKENS=200
OPENAI_TEMPERATURE=0.3

# Claude/Anthropic (Alternativa)
CLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
CLAUDE_MODEL=claude-3-haiku-20240307

# Cohere (Alternativa)
COHERE_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 2. Métodos de Implementação

#### Opção A: Cliente Direto (Desenvolvimento)
```dart
// Configurar chaves no .env
await dotenv.load();
final resultado = await AiService.processarBuscaPorDesejo("pizza romântica");
```

#### Opção B: Edge Function (Produção - Recomendado)
```bash
# Deploy da Edge Function
supabase functions deploy ai-interpret-search

# Configurar URL no .env
AI_EDGE_FUNCTION_URL=https://seu-projeto.supabase.co/functions/v1/ai-interpret-search
```

## 🚀 Como Usar

### 1. Busca Básica
```dart
// Busca simples
final resultado = await AiService.processarBuscaPorDesejo(
  "lugar tranquilo para café da manhã"
);

print(resultado['tipo']); // "café"
print(resultado['tags']); // ["tranquilo", "brunch"]
```

### 2. Busca com Debounce (Recomendado)
```dart
// Para campos de busca em tempo real
await AiService.interpretarBuscaComDebounce(
  "pizza artesanal com família",
  (interpretacao) {
    // Resultado da interpretação
    print(interpretacao.resumo);
  },
  onError: (erro) {
    // Tratar erro
    print("Erro: $erro");
  },
);
```

### 3. Usando Categorias Predefinidas
```dart
// As categorias já executam busca automática
void _handleCategoriaSelected(Categoria categoria) async {
  await _handleSearch(categoria.queryBusca);
}
```

## 📊 Estrutura de Resposta

```dart
class BuscaInterpretada {
  final String? tipo;           // "café", "pizzaria", "bar"
  final List<String> tags;      // ["romântico", "família"]
  final String? localizacao;    // "Centro", "Vila Madalena"
  final String? ambiente;       // "tranquilo", "agitado"
  final double? faixaPreco;     // 25.0, 50.0, 100.0
  final String? horario;        // "manhã", "tarde", "noite"
  final double confianca;       // 0.0 a 1.0
  final Map<String, dynamic> metadados;
}
```

## 🔍 Exemplos de Interpretação

| Input do Usuário | Tipo | Tags | Ambiente | Faixa Preço |
|-------------------|------|------|----------|-------------|
| "café tranquilo para trabalhar" | café | [tranquilo, Wi-Fi] | tranquilo | - |
| "pizza artesanal com a família" | pizzaria | [família, artesanal] | familiar | - |
| "bar descontraído para happy hour" | bar | [happy hour, casual] | agitado | - |
| "jantar romântico em lugar caro" | restaurante | [romântico, premium] | romântico | 100.0 |
| "comida vegana barata e saudável" | vegetariano | [vegano, saudável] | - | 25.0 |

## ⚙️ Configurações Avançadas

### Cache e Performance
```dart
// Configurar cache
AI_CACHE_ENABLED=true
AI_CACHE_DURATION_MINUTES=30
AI_CACHE_MAX_SIZE=100

// Debounce
AI_DEBOUNCE_MILLISECONDS=800
AI_MIN_QUERY_LENGTH=3
```

### Rate Limiting
```dart
AI_RATE_LIMIT_PER_MINUTE=60
AI_RATE_LIMIT_PER_HOUR=1000
```

### Fallback e Segurança
```dart
AI_FALLBACK_ENABLED=true
AI_FALLBACK_CONFIDENCE_THRESHOLD=0.3
AI_TIMEOUT_SECONDS=10
AI_MAX_RETRIES=3
```

## 🛡️ Segurança

### ⚠️ Nunca no Cliente
```dart
// ❌ NUNCA faça isso - expõe API keys
const openaiKey = "sk-xxxxxxxx";
```

### ✅ Recomendações
1. **Edge Functions**: Use Supabase Edge Functions para esconder chaves de API
2. **Rate Limiting**: Implemente limitações de uso
3. **Validação**: Valide inputs do usuário
4. **Logs**: Monitore uso para detectar abusos

## 📈 Monitoramento

### Estatísticas
```dart
final stats = AiService.estatisticas;
print("Provider: ${stats['provider']}");
print("Cache hits: ${stats['cache']['tamanhoCache']}");
print("Requests/min: ${stats['rateLimit']['requestsThisMinute']}");
```

### Debug Mode
```dart
AI_DEBUG_MODE=true
AI_LOG_REQUESTS=true
```

## 🔧 Troubleshooting

### Problemas Comuns

1. **"Não entendi muito bem"**
   - Input muito curto (< 3 caracteres)
   - Linguagem não reconhecida
   - Problema de conectividade

2. **Rate Limit Excedido**
   - Muitas requisições em pouco tempo
   - Configurar debounce maior
   - Implementar cache local

3. **Confiança Baixa**
   - Input ambíguo
   - Usar fallback keyword matching
   - Sugerir ser mais específico

### Fallback Strategies
```dart
// Se IA falhar, usar lógica de keywords
if (resultado.confianca < 0.3) {
  resultado = await _aplicarFallback(input);
}
```

## 🚀 Edge Function Deploy

### 1. Setup Supabase
```bash
npm install -g supabase
supabase login
supabase init
```

### 2. Deploy Function
```bash
supabase functions deploy ai-interpret-search
```

### 3. Configurar Secrets
```bash
supabase secrets set OPENAI_API_KEY=sk-xxxxxxxx
supabase secrets set CLAUDE_API_KEY=sk-ant-xxxxxxxx
```

### 4. Testar
```bash
curl -X POST https://seu-projeto.supabase.co/functions/v1/ai-interpret-search \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"input": "pizza romântica"}'
```

## 📝 Logs e Analytics

### Tabela de Analytics (SQL)
```sql
CREATE TABLE ai_usage_logs (
  id SERIAL PRIMARY KEY,
  input_text TEXT NOT NULL,
  provider VARCHAR(50) NOT NULL,
  confidence DECIMAL(3,2),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Consultas Úteis
```sql
-- Interpretações com baixa confiança
SELECT * FROM ai_usage_logs WHERE confidence < 0.5;

-- Inputs mais populares
SELECT input_text, COUNT(*) as count 
FROM ai_usage_logs 
GROUP BY input_text 
ORDER BY count DESC 
LIMIT 10;
```

## 🎯 Próximos Passos

1. **Analytics Avançados**: Implementar métricas de satisfação do usuário
2. **ML Personalizado**: Treinar modelo específico para gastronomia brasileira
3. **Múltiplos Idiomas**: Suporte a inglês e espanhol
4. **Voice Input**: Integração com speech-to-text
5. **Context Awareness**: Usar localização e histórico do usuário

## 🤝 Contribuição

Para contribuir com melhorias na interpretação de IA:

1. Adicione novos exemplos em `AiService.exemplosResposta()`
2. Melhore o sistema de fallback
3. Otimize prompts para melhor precisão
4. Implemente novos provedores de IA

## 📚 Recursos Adicionais

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Claude API Documentation](https://docs.anthropic.com/claude/reference)
- [Cohere API Documentation](https://docs.cohere.ai/)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions) 