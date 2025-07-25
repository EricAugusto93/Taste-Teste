# 🎨 Design System - Gastro App

## 📋 Visão Geral

Sistema de design completo baseado no **Material Design 3** com paleta personalizada dourada/bege para transmitir sofisticação e warmth gastronômico.

---

## 🎯 **Paleta de Cores**

### **Cores Principais**

```dart
// Core Colors - Sempre usar essas constantes
static const Color primary = Color(0xFF2C3985);       // Azul Profundo
static const Color secondary = Color(0xFFEE9D21);     // Amarelo Mostarda
static const Color danger = Color(0xFFD9502B);        // Vermelho Telha
static const Color background = Color(0xFFFBE9D2);    // Areia Clara
static const Color surface = Colors.white;            // Fundo de cards
```

### **Variações Automáticas (Material 3)**

```dart
// O sistema gera automaticamente:
primary10, primary20, primary30... primary100
secondary10, secondary20... secondary100
neutral10, neutral20... neutral100

// Para hover, pressed, disabled states
```

### **Cores Contextuais**

```dart
// Definidas em AppTheme.customColors
'success': Color(0xFF2E7D55),      // Verde
'warning': Color(0xFFF57C00),      // Laranja
'info': Color(0xFF1976D2),         // Azul informativo
'favorite': Color(0xFFE91E63),     // Pink para favoritos
```

---

## 📝 **Tipografia**

### **Hierarquia Definida**

```dart
// Títulos
heading1: 24px, Bold, #2C3985       // Títulos principais
headlineMedium: 20px, SemiBold      // Subtítulos seções
headlineSmall: 18px, SemiBold       // Subtítulos cards

// Corpo de texto
bodyLarge: 18px, Regular            // Textos importantes
bodyMedium: 16px, Regular           // Texto padrão
bodySmall: 14px, Regular            // Textos secundários

// Especiais
labelLarge: 16px, Medium            // Botões
labelMedium: 14px, Medium           // Labels
labelSmall: 12px, Medium            // Badges, tags
```

### **Uso Prático**

```dart
// Sempre usar AppTextStyles
Text('Título', style: AppTextStyles.heading1)
Text('Corpo', style: AppTextStyles.bodyMedium)
Text('Label', style: AppTextStyles.labelMedium)
```

---

## 📏 **Espaçamentos**

### **Escala Padronizada**

```dart
// Constantes em AppTheme
espacoPequeno: 8.0        // Espaçamentos mínimos
espacoMedio: 16.0         // Espaçamento padrão
espacoGrande: 24.0        // Seções importantes
espacoExtraGrande: 32.0   // Separações maiores

// Uso responsivo
double get espacoResponsivo => isTablet ? espacoGrande : espacoMedio;
```

---

## 🎨 **Componentes Visuais**

### **Cards e Containers**

```dart
// Padrão de cards
Container(
  decoration: BoxDecoration(
    color: AppTheme.branco,
    borderRadius: BorderRadius.circular(12),
    boxShadow: AppTheme.shadowLight,    // Elevação sutil
  ),
)

// Elevações definidas
shadowLight: elevation 2     // Cards normais
shadowMedium: elevation 4    // Cards hover
shadowHeavy: elevation 8     // Modals, dialogs
```

### **Botões**

```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)

// Secondary Button  
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: BorderSide(color: AppColors.primary),
  ),
)
```

### **Input Fields**

```dart
// Padrão de inputs
OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: BorderSide(color: AppColors.cinzaMedio),
)

// Focus state
focusedBorder: OutlineInputBorder(
  borderSide: BorderSide(color: AppColors.primary, width: 2),
)
```

---

## 🌈 **Gradientes e Efeitos**

### **Gradientes Principais**

```dart
// Gradiente primário (azul)
LinearGradient(
  colors: [AppColors.primary, AppColors.azulProfundoClaro],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Gradiente secundário (mostarda)
LinearGradient(
  colors: [AppColors.secondary, AppColors.mostardaClara],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
)

// Gradiente de fundo
LinearGradient(
  colors: [AppColors.background, AppColors.brancoQuente],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
)
```

### **Badges Coloridos (Distância)**

```dart
// Verde (próximo): ≤500m
Color(0xFF2E7D55)

// Laranja (médio): ≤2km  
Color(0xFFF57C00)

// Vermelho (longe): >5km
Color(0xFFD9502B)
```

---

## 📱 **Responsividade**

### **Breakpoints**

```dart
// Definidos em AppTheme
static bool isTablet(BuildContext context) => 
    MediaQuery.of(context).size.width > 768;

static bool isDesktop(BuildContext context) => 
    MediaQuery.of(context).size.width > 1024;
```

### **Adaptações**

```dart
// Espaçamentos responsivos
double get padding => isTablet ? 24.0 : 16.0;

// Cards responsivos
int get crossAxisCount => isTablet ? 3 : 2;

// Tipografia responsiva
double get fontSize => isTablet ? 18.0 : 16.0;
```

---

## 🎭 **Estados Visuais**

### **Feedback de Interação**

```dart
// Loading states
CircularProgressIndicator(color: AppColors.primary)

// Empty states
Icon(Icons.restaurant_outlined, 
     color: AppColors.cinzaClaro, 
     size: 64)

// Error states  
Icon(Icons.error_outline, 
     color: AppColors.danger, 
     size: 48)

// Success states
Icon(Icons.check_circle, 
     color: AppTheme.customColors['success'], 
     size: 48)
```

### **Hover e Pressed States**

```dart
// Material InkWell para feedback tátil
InkWell(
  borderRadius: BorderRadius.circular(12),
  onTap: () {},
  child: Container(...),
)

// Estados de botão automáticos via Material 3
```

---

## 🖼️ **Imagens e Ícones**

### **Placeholder de Imagens**

```dart
// Para restaurantes sem imagem
Container(
  decoration: BoxDecoration(
    color: AppColors.areiaMedia,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(
    Icons.restaurant,
    color: AppColors.cinzaMedio,
    size: 48,
  ),
)
```

### **Ícones Padronizados**

```dart
// Navegação
Icons.home_outlined        // Home
Icons.search              // Busca  
Icons.favorite_outline    // Favoritos
Icons.rate_review         // Experiências

// Ações
Icons.add                 // Adicionar
Icons.edit                // Editar
Icons.delete_outline      // Excluir
Icons.share               // Compartilhar

// Estados
Icons.location_on         // Localização
Icons.wifi                // Wi-Fi
Icons.family_restroom     // Família
Icons.romantic_dinner     // Romântico (custom ou emoji)
```

---

## 🎨 **Implementação Prática**

### **Exemplo de Card Completo**

```dart
Container(
  margin: EdgeInsets.all(AppTheme.espacoMedio),
  decoration: BoxDecoration(
    color: AppTheme.branco,
    borderRadius: BorderRadius.circular(12),
    boxShadow: AppTheme.shadowLight,
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppTheme.espacoMedio),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: AppTextStyles.headlineSmall,
            ),
            SizedBox(height: AppTheme.espacoPequeno),
            Text(
              descricao,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.cinzaEscuro,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)
```

### **Dark Mode (Futuro)**

```dart
// Preparado para implementação futura
ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.dark,  // Toggle aqui
)
```

---

**🎯 Objetivo:** Manter consistência visual em toda aplicação e facilitar manutenção e expansão do design system.

**📱 Aplicação:** Cada componente deve seguir estes padrões para garantir experiência unificada e profissional. 