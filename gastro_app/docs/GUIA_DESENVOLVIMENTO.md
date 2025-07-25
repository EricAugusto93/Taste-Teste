# 👨‍💻 Guia de Desenvolvimento - Gastro App

## 🎯 **Visão Geral**

Este documento fornece diretrizes práticas para desenvolvimento contínuo do Gastro App, incluindo padrões de código, como adicionar novas funcionalidades e melhores práticas.

---

## 🏗️ **Estrutura de Pastas e Convenções**

### **Organização de Arquivos**

```
lib/
├── config/           # Configurações globais (cores, temas)
├── models/           # Classes de dados (Restaurante, Usuario)
├── services/         # Lógica de negócio e APIs
├── screens/          # Telas principais do app
├── widgets/          # Componentes reutilizáveis
└── utils/           # Utilitários e providers
```

### **Convenções de Nomenclatura**

```dart
// Arquivos: snake_case
home_screen.dart
restaurante_service.dart

// Classes: PascalCase
class RestauranteService
class HomeScreen

// Variáveis e funções: camelCase
String nomeRestaurante
void buscarRestaurantes()

// Constantes: lowerCamelCase
static const primaryColor
```

---

## 🔧 **Adicionando Novas Funcionalidades**

### **1. Nova Tela (Screen)**

#### **Passo a Passo:**

```dart
// 1. Criar arquivo em screens/
// nova_funcionalidade_screen.dart

class NovaFuncionalidadeScreen extends ConsumerStatefulWidget {
  const NovaFuncionalidadeScreen({super.key});

  @override
  ConsumerState<NovaFuncionalidadeScreen> createState() => 
      _NovaFuncionalidadeScreenState();
}

// 2. Implementar estado com animações
class _NovaFuncionalidadeScreenState 
    extends ConsumerState<NovaFuncionalidadeScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cinzaClaro,
      appBar: HeaderBar(title: 'Nova Funcionalidade'),
      body: // Sua UI aqui
    );
  }
}

// 3. Adicionar navegação
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const NovaFuncionalidadeScreen(),
  ),
);
```

### **2. Novo Service**

```dart
// 1. Criar arquivo em services/
// nova_service.dart

class NovaService {
  static final SupabaseClient _supabase = SupabaseService.client;
  
  // Métodos sempre estáticos para facilitar uso
  static Future<List<Model>> buscarDados() async {
    try {
      final response = await _supabase
          .from('tabela')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((item) => Model.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar dados: $e');
      throw Exception('Erro ao carregar dados');
    }
  }
}

// 2. Criar Provider em utils/providers.dart
final novaServiceProvider = FutureProvider<List<Model>>((ref) {
  return NovaService.buscarDados();
});

// 3. Usar na UI
final dados = ref.watch(novaServiceProvider);
return dados.when(
  data: (lista) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Erro: $error'),
);
```

### **3. Novo Widget Reutilizável**

```dart
// 1. Criar arquivo em widgets/
// novo_widget.dart

class NovoWidget extends StatelessWidget {
  final String titulo;
  final VoidCallback? onTap;
  final bool isEnabled;

  const NovoWidget({
    super.key,
    required this.titulo,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Sempre usar AppTheme para cores e espaçamentos
      decoration: BoxDecoration(
        color: AppTheme.branco,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: AppTheme.shadowLight,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          onTap: isEnabled ? onTap : null,
          child: Padding(
            padding: EdgeInsets.all(AppTheme.espacoMedio),
            child: Text(
              titulo,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🎨 **Design System Guidelines**

### **Cores e Temas**

```dart
// SEMPRE usar AppColors em vez de valores hardcoded
✅ Correto:
Container(color: AppColors.primary)

❌ Incorreto:
Container(color: Color(0xFF2c3985))

// Para cores contextuais, usar AppTheme
AppTheme.customColors['success']  // Verde para sucesso
AppTheme.customColors['warning']  // Amarelo para avisos
AppTheme.customColors['danger']   // Vermelho para erros
```

### **Espaçamentos**

```dart
// Usar constantes padronizadas
AppTheme.espacoPequeno   // 8px
AppTheme.espacoMedio     // 16px
AppTheme.espacoGrande    // 24px
AppTheme.espacoExtraGrande  // 32px

// Para espaçamentos customizados
SizedBox(height: AppTheme.espacoMedio * 1.5)  // 24px
```

### **Tipografia**

```dart
// Hierarquia definida
AppTextStyles.heading1      // Títulos principais
AppTextStyles.headlineMedium // Subtítulos
AppTextStyles.bodyLarge     // Texto de corpo grande
AppTextStyles.bodyMedium    // Texto padrão
AppTextStyles.bodySmall     // Texto secundário
```

---

## 🔄 **Gerenciamento de Estado (Riverpod)**

### **Padrões de Providers**

```dart
// 1. FutureProvider para dados assíncronos
final restaurantesProvider = FutureProvider<List<Restaurante>>((ref) {
  return RestauranteService.listarTodos();
});

// 2. StateProvider para valores simples
final filtroTipoProvider = StateProvider<String>((ref) => '');

// 3. StateNotifierProvider para estados complexos
final buscaStateProvider = StateNotifierProvider<BuscaNotifier, BuscaState>((ref) {
  return BuscaNotifier();
});

// 4. Provider para valores computados
final restaurantesFiltradosProvider = Provider<List<Restaurante>>((ref) {
  final restaurantes = ref.watch(restaurantesProvider).value ?? [];
  final filtro = ref.watch(filtroTipoProvider);
  
  if (filtro.isEmpty) return restaurantes;
  return restaurantes.where((r) => r.tipo.contains(filtro)).toList();
});
```

### **Invalidação e Refresh**

```dart
// Para refresh manual
ref.invalidate(restaurantesProvider);

// Para refresh automático (polling)
Timer.periodic(Duration(minutes: 5), (_) {
  ref.invalidate(restaurantesProvider);
});

// Para dependências entre providers
final dadosDependentesProvider = FutureProvider<List<Data>>((ref) {
  // Watch automaticamente re-executa quando usuário muda
  final usuario = ref.watch(usuarioAtualProvider).value;
  if (usuario == null) return [];
  
  return DataService.buscarPorUsuario(usuario.id);
});
```

---

## 🗄️ **Trabalhando com Supabase**

### **Padrões de Query**

```dart
// 1. Select simples
final response = await _supabase
    .from('restaurantes')
    .select()
    .order('created_at', ascending: false);

// 2. Filtros
final response = await _supabase
    .from('restaurantes')
    .select()
    .eq('tipo', 'Japonesa')
    .ilike('nome', '%sushi%')
    .in_('tags', ['romântico', 'casual']);

// 3. Joins
final response = await _supabase
    .from('experiencias')
    .select('*, restaurante:restaurantes(*), usuario:usuarios(*)')
    .eq('usuario_id', userId);

// 4. Agregações
final response = await _supabase
    .from('experiencias')
    .select('emoji', count: CountOption.exact)
    .eq('restaurante_id', restauranteId);
```

### **Error Handling**

```dart
// Padrão para tratamento de erros
static Future<List<Restaurante>> buscarRestaurantes() async {
  try {
    final response = await _supabase
        .from('restaurantes')
        .select();
    
    return (response as List)
        .map((item) => Restaurante.fromJson(item))
        .toList();
        
  } on PostgrestException catch (e) {
    debugPrint('Erro PostgreSQL: ${e.message}');
    throw Exception('Erro no banco de dados: ${e.message}');
    
  } on SocketException catch (e) {
    debugPrint('Erro de conexão: $e');
    throw Exception('Erro de conexão. Verifique sua internet.');
    
  } catch (e) {
    debugPrint('Erro desconhecido: $e');
    throw Exception('Erro inesperado. Tente novamente.');
  }
}
```

---

## 🧪 **Testing Guidelines**

### **Unit Tests**

```dart
// Exemplo para services
void main() {
  group('RestauranteService', () {
    test('deve buscar restaurantes corretamente', () async {
      // Arrange
      // Setup mock if needed
      
      // Act
      final restaurantes = await RestauranteService.listarTodos();
      
      // Assert
      expect(restaurantes, isA<List<Restaurante>>());
      expect(restaurantes.length, greaterThan(0));
    });
  });
}
```

### **Widget Tests**

```dart
void main() {
  testWidgets('RestauranteCard deve exibir informações', (tester) async {
    // Arrange
    final restaurante = Restaurante(
      id: '1',
      nome: 'Teste',
      tipo: 'Italiana',
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: RestauranteCard(restaurante: restaurante),
      ),
    );
    
    // Assert
    expect(find.text('Teste'), findsOneWidget);
    expect(find.text('Italiana'), findsOneWidget);
  });
}
```

---

## 🔧 **Performance Best Practices**

### **Flutter Optimizations**

```dart
// 1. Usar const constructors sempre que possível
const SizedBox(height: 16)
const Text('Título fixo')

// 2. Lazy loading para listas grandes
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// 3. Cache de imagens
Image.network(
  url,
  cacheWidth: 300,  // Redimensionar para economizar memória
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return CircularProgressIndicator();
  },
)

// 4. Dispose de recursos
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}
```

### **Database Optimizations**

```sql
-- Índices para queries frequentes
CREATE INDEX idx_restaurantes_tipo ON restaurantes(tipo);
CREATE INDEX idx_restaurantes_tags ON restaurantes USING gin(tags);

-- Limit para evitar queries muito grandes
SELECT * FROM restaurantes LIMIT 50;

-- Use select específico em vez de *
SELECT nome, tipo, latitude, longitude FROM restaurantes;
```

---

## 🐛 **Debugging Tips**

### **Flutter DevTools**

```dart
// 1. Debug prints estruturados
debugPrint('🔍 [BuscaService] Iniciando busca: $termo');
debugPrint('✅ [BuscaService] Encontrados ${resultados.length} restaurantes');

// 2. Assertions para desenvolvimento
assert(restaurante.id.isNotEmpty, 'ID do restaurante não pode ser vazio');

// 3. Inspector widget
Widget build(BuildContext context) {
  return Inspector(
    enabled: kDebugMode,
    child: YourWidget(),
  );
}
```

### **Network Debugging**

```dart
// Log de requests Supabase
void _logSupabaseRequest(String endpoint, Map<String, dynamic> params) {
  if (kDebugMode) {
    debugPrint('📡 Supabase Request: $endpoint');
    debugPrint('📋 Params: $params');
  }
}
```

---

## 📚 **Convenções de Código**

### **Estrutura de Métodos**

```dart
class ExemploService {
  // 1. Constantes primeiro
  static const String _baseUrl = 'https://api.exemplo.com';
  
  // 2. Variáveis privadas
  static final SupabaseClient _supabase = SupabaseService.client;
  
  // 3. Métodos públicos (estáticos)
  static Future<List<Item>> listarTodos() async {
    // implementação
  }
  
  // 4. Métodos privados no final
  static List<Item> _processarResponse(dynamic response) {
    // implementação
  }
}
```

### **Comentários Úteis**

```dart
/// Busca restaurantes baseado em critérios de IA
/// 
/// [desejo] - Texto natural do usuário (ex: "pizza romântica")
/// [localizacao] - Coordenadas para filtro de proximidade
/// 
/// Retorna lista de restaurantes ordenada por relevância
static Future<List<Restaurante>> buscarPorDesejo(
  String desejo, {
  LatLng? localizacao,
}) async {
  // TODO: Integrar IA real (OpenAI/Claude)
  // FIXME: Melhorar algoritmo de relevância
  
  // Processa o desejo usando IA simulada
  final analise = await AiService.analisarDesejo(desejo);
  
  // Aplica filtros baseados na análise
  return await _aplicarFiltros(analise, localizacao);
}
```

---

## 🔄 **Git Workflow**

### **Branches e Commits**

```bash
# Padrão de branches
feature/nova-funcionalidade
fix/corrigir-bug-login
hotfix/erro-critico-producao
docs/atualizar-readme

# Padrão de commits (Conventional Commits)
feat: adiciona sistema de notificações push
fix: corrige erro de login com email inválido
docs: atualiza guia de instalação
style: ajusta espaçamento dos cards
refactor: reorganiza estrutura do RestauranteService
test: adiciona testes para busca de restaurantes
```

### **Pull Request Template**

```markdown
## 📝 Descrição
Breve descrição do que foi implementado

## 🔧 Tipo de Mudança
- [ ] Nova funcionalidade
- [ ] Correção de bug
- [ ] Documentação
- [ ] Refatoração

## 🧪 Testes
- [ ] Testado manualmente
- [ ] Testes automatizados adicionados
- [ ] Todos os testes passando

## 📱 Screenshots (se UI)
[Adicionar capturas de tela]

## ✅ Checklist
- [ ] Código segue padrões do projeto
- [ ] Documentação atualizada
- [ ] Não há breaking changes
```

---

## 🚀 **Deploy e Release**

### **Preparação para Release**

```bash
# 1. Atualizar versão no pubspec.yaml
version: 1.0.0+1

# 2. Gerar release build
flutter build web --release
flutter build apk --release

# 3. Testar build de produção
flutter run --release

# 4. Atualizar CHANGELOG.md
## [1.0.0] - 2024-01-15
### Added
- Sistema de busca inteligente
- Integração com Google Maps
### Fixed
- Correção no sistema de favoritos
```

---

**💡 Lembre-se:** Sempre priorize código limpo, testável e bem documentado. O futuro você (e sua equipe) agradecerá! 