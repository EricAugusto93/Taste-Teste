# 🗄️ Database Migrations - Taste App

## Como executar a migração de Reviews

### 1. Acessar o Supabase Dashboard

1. Acesse [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Faça login na sua conta
3. Selecione o projeto do Taste App

### 2. Executar a Migração SQL

1. No dashboard, vá para **SQL Editor** (ícone de código SQL na barra lateral)
2. Clique em **New Query**
3. Copie todo o conteúdo do arquivo `migrations/review_enhancements.sql`
4. Cole no editor SQL
5. Clique em **Run** para executar a migração

### 3. Verificar se a migração foi executada

Execute esta query para verificar se as tabelas foram criadas:

```sql
-- Verificar se as tabelas foram criadas
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('review_replies', 'review_reports', 'review_helpful_votes', 'reply_reports');

-- Verificar se as funções foram criadas
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('toggle_helpful_vote', 'get_restaurant_review_stats');
```

### 4. Testar funcionalidades (após executar a migração)

Depois de executar a migração SQL, você pode testar:

- ✅ **Porcentagens nas estrelas** - Agora aparecem ao lado das barras
- ✅ **Comentários não duplicados** - Sistema remove duplicatas automaticamente
- ✅ **Botão "Útil"** - Funciona para marcar/desmarcar como útil
- ✅ **Botão "Responder"** - Funciona para responder avaliações
- ✅ **Botão "Reportar"** - Funciona para reportar conteúdo inadequado

### 5. Estrutura das novas tabelas

#### `review_replies`
- Armazena respostas às avaliações
- Suporte a respostas do dono do restaurante

#### `review_reports` 
- Armazena reportes de avaliações
- Previne múltiplos reportes do mesmo usuário

#### `review_helpful_votes`
- Controla votos "útil" nas avaliações  
- Chave primária composta (review_id, user_id)

#### `reply_reports`
- Armazena reportes de respostas
- Mesma estrutura dos reportes de reviews

### 6. Funções criadas

#### `toggle_helpful_vote(review_id, user_id)`
- Alterna voto útil (adiciona se não existe, remove se existe)
- Retorna `true` se adicionou, `false` se removeu
- Atualiza automaticamente o campo `helpful_count` na tabela `reviews`

#### `get_restaurant_review_stats(restaurant_id)`
- Retorna estatísticas completas de avaliações
- Inclui distribuição de ratings com porcentagens
- Usado para exibir gráficos de estatísticas

## 🚨 Importante

- **Execute a migração ANTES de testar** as funcionalidades no app
- As funcionalidades só funcionarão depois da migração SQL
- Se houver algum erro, verifique os logs no Supabase
- Todas as policies de RLS (Row Level Security) já estão configuradas