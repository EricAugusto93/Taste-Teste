# Fase 10: Sistema de Autenticação - Plano Detalhado

## 📋 Visão Geral

**Status:** 📍 **PRÓXIMA PRIORIDADE**
**Estimativa:** 6-8 dias úteis
**Prioridade:** 🟡 Alto
**Dependências:** Fases 1-9 concluídas ✅

### 🎯 Objetivos da Fase

Implementar um sistema completo de autenticação usando Supabase Auth, permitindo que usuários:
- Criem contas e façam login
- Gerenciem seus perfis
- Tenham experiências personalizadas
- Sincronizem dados entre dispositivos

### 🔧 Tecnologias Utilizadas

- **Supabase Auth**: Sistema de autenticação principal
- **Flutter Secure Storage**: Armazenamento seguro de tokens
- **Provider/Riverpod**: Gerenciamento de estado de autenticação
- **GoRouter**: Navegação condicional baseada em auth

---

## 📱 Funcionalidades Detalhadas

### 10.1 Sistema de Autenticação Core

#### 10.1.1 Configuração Supabase Auth
- [x] 🔴 **Configurar Supabase Auth** (já configurado)
- [ ] 🔴 **Configurar providers de autenticação**
  - Email/senha (principal)
  - Google OAuth (opcional)
  - Apple Sign-In (iOS)
- [ ] 🔴 **Configurar políticas RLS para usuários**
- [ ] 🔴 **Setup de templates de email**

#### 10.1.2 AuthRepository
```dart
class AuthRepository {
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> signUpWithEmail(String email, String password, String name);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<User?> getCurrentUser();
  Stream<AuthState> get authStateChanges;
}
```

#### 10.1.3 AuthProvider/Notifier
```dart
class AuthNotifier extends StateNotifier<AuthState> {
  // Gerenciamento de estado de autenticação
  // Persistência de sessão
  // Navegação automática
}
```

### 10.2 Telas de Autenticação

#### 10.2.1 Login Page
**Rota:** `/login`

**Componentes:**
- Header com logo e título "Bem-vindo de volta!"
- Campo de email com validação
- Campo de senha com toggle de visibilidade
- Botão "Entrar" com loading state
- Link "Esqueci minha senha"
- Divisor "ou"
- Botão "Entrar com Google" (opcional)
- Link "Não tem conta? Cadastre-se"

**Validações:**
- Email formato válido
- Senha mínimo 6 caracteres
- Tratamento de erros específicos

#### 10.2.2 Register Page
**Rota:** `/register`

**Componentes:**
- Header com título "Criar conta"
- Campo nome completo
- Campo email com validação
- Campo senha com indicador de força
- Campo confirmar senha
- Checkbox termos de uso
- Botão "Criar conta" com loading
- Link "Já tem conta? Faça login"

**Validações:**
- Nome mínimo 2 caracteres
- Email único no sistema
- Senha forte (maiúscula, minúscula, número)
- Confirmação de senha
- Aceite dos termos obrigatório

#### 10.2.3 Forgot Password Page
**Rota:** `/forgot-password`

**Componentes:**
- Header explicativo
- Campo email
- Botão "Enviar link de recuperação"
- Mensagem de sucesso/erro
- Link "Voltar ao login"

### 10.3 Profile Management

#### 10.3.1 Profile Page
**Rota:** `/profile`

**Seções:**
1. **Header do Perfil**
   - Avatar do usuário (iniciais ou foto)
   - Nome e email
   - Botão editar perfil

2. **Estatísticas Pessoais**
   - Restaurantes visitados
   - Avaliações feitas
   - Favoritos salvos
   - Membro desde

3. **Configurações**
   - Notificações push
   - Privacidade
   - Tema (claro/escuro)
   - Idioma

4. **Ações**
   - Alterar senha
   - Exportar dados
   - Deletar conta
   - Sair

#### 10.3.2 Edit Profile Page
**Rota:** `/profile/edit`

**Campos Editáveis:**
- Nome completo
- Email (com verificação)
- Telefone (opcional)
- Data de nascimento (opcional)
- Cidade (opcional)
- Bio/descrição (opcional)

### 10.4 Navegação Condicional

#### 10.4.1 Auth Guard
```dart
class AuthGuard {
  static bool canAccess(String route, AuthState authState) {
    // Lógica de proteção de rotas
  }
}
```

#### 10.4.2 Rotas Protegidas
- `/profile` - Requer autenticação
- `/favorites` - Requer autenticação
- Avaliações - Requer autenticação
- Configurações - Requer autenticação

#### 10.4.3 Rotas Públicas
- `/` (home) - Acesso livre
- `/search` - Acesso livre
- `/restaurant/:id` - Acesso livre
- `/login` - Apenas não autenticados
- `/register` - Apenas não autenticados

---

## 🗄️ Estrutura de Dados

### 10.5 User Profile Schema

```sql
-- Tabela de perfis de usuário (complementa auth.users)
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT,
  birth_date DATE,
  city TEXT,
  bio TEXT,
  avatar_url TEXT,
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

### 10.6 Atualização de Tabelas Existentes

```sql
-- Adicionar user_id às tabelas existentes
ALTER TABLE favorites ADD COLUMN user_id UUID REFERENCES auth.users(id);
ALTER TABLE reviews ADD COLUMN user_id UUID REFERENCES auth.users(id);
ALTER TABLE search_history ADD COLUMN user_id UUID REFERENCES auth.users(id);

-- Atualizar RLS policies existentes
-- (Aplicar políticas baseadas em user_id)
```

---

## 🎨 Design e UX

### 10.7 Design System para Auth

#### 10.7.1 Cores Específicas
- **Primary Auth**: `#FF6B47` (laranja principal)
- **Success**: `#10B981` (verde para confirmações)
- **Error**: `#EF4444` (vermelho para erros)
- **Warning**: `#F59E0B` (amarelo para avisos)

#### 10.7.2 Componentes Específicos
- **AuthTextField**: Campo de entrada com validação visual
- **AuthButton**: Botão com estados de loading
- **SocialLoginButton**: Botão para login social
- **AuthHeader**: Header consistente para telas de auth
- **ValidationMessage**: Mensagens de erro/sucesso

### 10.8 Fluxos de UX

#### 10.8.1 Primeiro Acesso
1. Usuário abre app
2. Vê onboarding (se primeira vez)
3. Navega livremente como guest
4. Ao tentar favoritar/avaliar → direcionado para login
5. Opção de criar conta ou fazer login

#### 10.8.2 Usuário Retornando
1. App verifica token salvo
2. Se válido → login automático
3. Se inválido → permanece como guest
4. Opção de fazer login manual

---

## 🔧 Implementação Técnica

### 10.9 Cronograma Detalhado

#### Dia 1-2: Setup e Configuração
- [ ] Configurar Supabase Auth providers
- [ ] Criar AuthRepository e AuthNotifier
- [ ] Implementar AuthGuard e navegação condicional
- [ ] Criar componentes base de autenticação

#### Dia 3-4: Telas de Autenticação
- [ ] Implementar Login Page com validações
- [ ] Implementar Register Page com validações
- [ ] Implementar Forgot Password Page
- [ ] Testes de fluxo de autenticação

#### Dia 5-6: Profile Management
- [ ] Criar Profile Page com estatísticas
- [ ] Implementar Edit Profile Page
- [ ] Integrar com dados existentes (favoritos, reviews)
- [ ] Implementar configurações básicas

#### Dia 7-8: Integração e Polimento
- [ ] Integrar auth com funcionalidades existentes
- [ ] Implementar persistência de sessão
- [ ] Testes de integração completos
- [ ] Ajustes de UX e performance

### 10.10 Critérios de Aceitação

#### Funcionalidades Obrigatórias
- ✅ Usuário pode criar conta com email/senha
- ✅ Usuário pode fazer login com credenciais válidas
- ✅ Usuário pode recuperar senha via email
- ✅ Usuário pode editar perfil básico
- ✅ Usuário pode fazer logout
- ✅ Sessão persiste entre aberturas do app
- ✅ Rotas protegidas funcionam corretamente
- ✅ Dados do usuário são sincronizados

#### Funcionalidades Opcionais
- 🔄 Login com Google
- 🔄 Login com Apple (iOS)
- 🔄 Configurações avançadas
- 🔄 Gamificação básica

---

## 🧪 Testes

### 10.11 Testes Unitários
- AuthRepository methods
- AuthNotifier state management
- Validation functions
- AuthGuard logic

### 10.12 Testes de Widget
- Login Page interactions
- Register Page validations
- Profile Page display
- Navigation flows

### 10.13 Testes de Integração
- Complete auth flow
- Session persistence
- Route protection
- Data synchronization

---

## 🚀 Próximos Passos

Após conclusão da Fase 10, as próximas prioridades serão:

1. **Fase 11: Otimizações e Polimento** (6-10 dias)
   - Performance improvements
   - Error handling refinement
   - Offline support
   - Accessibility

2. **Fase 12: Testes e Qualidade** (9-13 dias)
   - Comprehensive testing
   - Quality assurance
   - Bug fixes

3. **Fase 13: Deploy e Lançamento** (5-8 dias)
   - Production setup
   - Store submission
   - Launch preparation

**🎯 Meta:** Ter o sistema de autenticação totalmente funcional e integrado, preparando o app para o lançamento oficial.