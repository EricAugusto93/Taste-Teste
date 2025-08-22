# Migrações do Supabase

Este diretório contém todas as migrações necessárias para configurar o banco de dados do projeto Taste.

## Ordem de Execução

### Migrações Principais (Execute em ordem):

1. **001_create_initial_tables.sql** - Cria as tabelas principais (categories, restaurants, reviews, favorites, search_history)
2. **002_create_admin_user.sql** - Cria a tabela de admins e usuário inicial
3. **add_missing_restaurant_fields.sql** - Adiciona campos ausentes na tabela restaurants
4. **sync_categories_with_admin_panel.sql** - Sincroniza categorias com painel administrativo

### Migrações de Dados:

- **clear_and_insert_restaurants.sql** - Limpa e insere dados de restaurantes
- **insert_categories_and_update_restaurants.sql** - Insere categorias e atualiza restaurantes

### Scripts de Verificação:

- **check_user_profiles_permissions.sql** - Verifica permissões de perfis de usuário
- **list_all_categories.sql** - Lista todas as categorias
- **query_categories.sql** - Query de exemplo para categorias

## Estrutura das Tabelas

### Tabelas Principais:
- `categories` - Categorias de restaurantes
- `restaurants` - Dados dos restaurantes  
- `reviews` - Avaliações dos usuários
- `favorites` - Favoritos dos usuários
- `search_history` - Histórico de buscas
- `admins` - Usuários administradores

### Configurações de Segurança:
- Row Level Security (RLS) habilitado em todas as tabelas
- Políticas configuradas para acesso público em restaurants/categories
- Acesso restrito para dados de usuários (favorites, reviews, search_history)

## Como Usar

1. Execute as migrações principais em ordem
2. Configure as variáveis de ambiente nos apps
3. Execute o script de verificação: `node verify_integration.js`