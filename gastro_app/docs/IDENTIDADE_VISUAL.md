# 🎨 Identidade Visual - Gastro App

## 📋 Visão Geral

Este documento define o sistema de design completo do Gastro App, incluindo cores, tipografia, componentes e diretrizes de uso baseadas no Material Design 3.

---

## 🎯 **Paleta de Cores**

### Cores Principais

#### 🔵 **Azul Profundo** - `#2C3985`
- **Uso**: Cor primária do app
- **Aplicação**: Botões principais, AppBar, ícones ativos, títulos importantes
- **Variações**:
  - Claro: `#4A5BA6` (hover states)
  - Escuro: `#1E2760` (pressed states)
  - Muito Claro: `#7A8BCF` (backgrounds sutis)

#### 🟡 **Amarelo Mostarda** - `#EE9D21`
- **Uso**: Cor secundária
- **Aplicação**: CTAs secundários, destaques, elementos interativos
- **Variações**:
  - Claro: `#F2B847` (highlights)
  - Escuro: `#B8741A` (texto em fundos claros)
  - Muito Claro: `#F5D18A` (backgrounds)

#### 🔴 **Vermelho Telha** - `#D9502B`
- **Uso**: Erro e ações intensas
- **Aplicação**: Erros, exclusões, alertas, chips de destaque
- **Variações**:
  - Claro: `#E6754F` (avisos suaves)
  - Escuro: `#B03A1F` (textos de erro)
  - Muito Claro: `#EDA487` (backgrounds de erro)

#### 🟤 **Areia Clara** - `#FBE9D2`
- **Uso**: Fundo principal
- **Aplicação**: Background do app, cards claros, superfícies
- **Variações**:
  - Média: `#F0D4B3`
  - Escura: `#E5BF94`
  - Muito Clara: `#FDF4E8`

### Cores Neutras

```
Branco: #FFFFFF
Branco Quente: #FFFBF7
Gelo: #F8F9FA
Cinza Muito Claro: #F5F5F5
Cinza Claro: #E0E0E0
Cinza Médio: #9E9E9E
Cinza Escuro: #616161
Cinza Muito Escuro: #424242
Preto Cinza: #2C2C2C
Preto: #000000
```

### Cores Funcionais

| Função | Cor | Hex | Uso |
|--------|-----|-----|-----|
| Sucesso | 🟢 | `#4CAF50` | Confirmações, feedback positivo |
| Aviso | 🟠 | `#FF9800` | Alertas, atenção |
| Informação | 🔵 | `#2196F3` | Dicas, informações neutras |
| Favorito | ❤️ | `#E91E63` | Curtidas, favoritos |
| Rating | ⭐ | `#FFC107` | Avaliações, estrelas |

---

## ✍️ **Tipografia**

### Família de Fonte
- **Primária**: SF Pro Display (iOS) / Roboto (Android) / System Font (Web)
- **Fallback**: Sans-serif padrão do sistema

### Hierarquia Tipográfica

#### Display (Títulos Grandes)
```
Display Large: 32px, Bold, -0.5 letter-spacing
Display Medium: 28px, Bold, -0.25 letter-spacing  
Display Small: 24px, SemiBold, 0 letter-spacing
```

#### Headlines (Títulos de Seção)
```
Headline Large: 22px, SemiBold, 0 letter-spacing
Headline Medium: 20px, SemiBold, 0.15 letter-spacing
Headline Small: 18px, Medium, 0.15 letter-spacing
```

#### Body (Corpo do Texto)
```
Body Large: 16px, Regular, 0.5 letter-spacing
Body Medium: 14px, Regular, 0.25 letter-spacing
Body Small: 12px, Regular, 0.4 letter-spacing
```

#### Labels (Botões e Tags)
```
Label Large: 16px, SemiBold, 0.1 letter-spacing
Label Medium: 14px, Medium, 0.5 letter-spacing
Label Small: 12px, Medium, 0.5 letter-spacing
```

### Estilos Especializados

#### Restaurantes
```dart
Restaurant Name: 18px, SemiBold, Azul Profundo
Price: 16px, Bold, Amarelo Mostarda
Rating: 14px, SemiBold, Rating (dourado)
Distance: 12px, Regular, Cinza Escuro
```

#### Formulários
```dart
Label: 14px, Medium, Azul Profundo
Input: 14px, Regular, Azul Profundo
Placeholder: 14px, Regular, Cinza Médio
Error: 12px, Medium, Vermelho Telha
Success: 12px, Medium, Sucesso
```

---

## 🧩 **Componentes**

### Botões

#### Elevated Button (Primário)
```dart
Background: Azul Profundo
Text: Branco
Border Radius: 16px
Padding: 24h x 16v
Min Size: 48x48 (acessibilidade)
```

#### Outlined Button (Secundário)
```dart
Border: Azul Profundo, 1.5px
Text: Azul Profundo
Border Radius: 16px
Padding: 20h x 14v
```

#### Text Button (Terciário)
```dart
Text: Azul Profundo
Border Radius: 12px
Padding: 16h x 12v
```

### Cards

#### Card Padrão
```dart
Background: Branco
Border Radius: 16px
Elevation: 4
Shadow: Sombra Leve (#000 8% opacity)
Margin: 8h x 4v
```

#### Card de Restaurante
```dart
Background: Branco
Border Radius: 16px
Padding: 16px
Tags: Areia Média + Borda Vermelho Telha
```

### Campos de Input

#### TextField
```dart
Background: Branco
Border: Cinza Claro, 1px
Focus Border: Azul Profundo, 2px
Error Border: Vermelho Telha, 1px
Border Radius: 12px
Padding: 16px
```

### Chips e Tags

#### Chip Padrão
```dart
Background: Areia Média
Border: Vermelho Telha (30% opacity), 1px
Text: Azul Profundo
Border Radius: 20px
Padding: 12h x 8v
```

---

## 📐 **Sistema de Espaçamento**

### Valores Padrão
```dart
XS: 4px   // Micro espaçamentos
S:  8px   // Pequeno
M:  16px  // Médio (padrão)
L:  24px  // Grande
XL: 32px  // Extra grande
XXL: 48px // Máximo
```

### Aplicação
- **Margin/Padding interno**: 16px (M)
- **Espaçamento entre seções**: 24px (L)
- **Espaçamento entre elementos**: 8px (S)
- **Espaçamento micro**: 4px (XS)

---

## 🔘 **Border Radius**

### Valores Padrão
```dart
XS: 4px   // Elementos pequenos
S:  8px   // Tags, chips pequenos
M:  12px  // Inputs, botões pequenos
L:  16px  // Cards, botões principais
XL: 20px  // Bottom sheets
XXL: 24px // Containers grandes
Circular: 999px // Elementos circulares
```

---

## 📊 **Elevação e Sombras**

### Níveis de Elevação
```dart
None: 0    // Elementos planos
XS: 1      // Divisores sutis
S: 2       // Chips, tags
M: 4       // Cards padrão
L: 6       // FAB, botões elevados
XL: 8      // Navigation bar
XXL: 16    // Modals, dialogs
```

### Sombras
```dart
Leve: #000 8% opacity, blur 8px, offset (0,2)
Média: #000 16% opacity, blur 16px, offset (0,4)
Forte: #000 24% opacity, blur 24px, offset (0,8)
```

---

## 🎨 **Gradientes**

### Gradiente Primário
```dart
LinearGradient(
  colors: [Azul Profundo, Azul Profundo Claro],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Gradiente Secundário
```dart
LinearGradient(
  colors: [Amarelo Mostarda, Amarelo Mostarda Claro],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Gradiente de Ação
```dart
LinearGradient(
  colors: [Vermelho Telha, Vermelho Telha Claro],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

---

## ♿ **Acessibilidade**

### Contraste
- **Mínimo WCAG 2.1 AA**: 4.5:1
- **Recomendado WCAG 2.1 AAA**: 7:1
- **Textos grandes (18pt+)**: 3:1 mínimo

### Tamanhos Mínimos
- **Fonte**: 12pt (16px)
- **Touch Target**: 44x44pt (iOS) / 48x48dp (Android)
- **Espaçamento entre toques**: 8pt mínimo

### Estados Interativos
```dart
Hover: Azul Profundo 8% opacity
Pressed: Azul Profundo 12% opacity
Focus: Amarelo Mostarda 12% opacity
Disabled Background: Cinza Muito Claro
Disabled Text: Cinza Médio
```

---

## 🚀 **Como Usar**

### 1. Importar Sistema de Design
```dart
import 'package:gastro_app/config/app_colors.dart';
import 'package:gastro_app/config/app_text_styles.dart';
import 'package:gastro_app/utils/app_theme.dart';
```

### 2. Usar Cores
```dart
// Cores principais
Container(color: AppColors.azulProfundo)

// Cores funcionais
Icon(Icons.favorite, color: AppColors.favorito)

// Gradientes
Container(decoration: BoxDecoration(
  gradient: AppColors.gradientePrimario,
))
```

### 3. Usar Tipografia
```dart
Text(
  'Título Principal',
  style: AppTextStyles.headlineLarge,
)

Text(
  'Nome do Restaurante',
  style: AppTextStyles.restaurantName,
)
```

### 4. Usar Espaçamentos
```dart
Padding(
  padding: EdgeInsets.all(AppTheme.spacingM),
  child: ...
)

SizedBox(height: AppTheme.spacingL)
```

### 5. Usar Border Radius
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppTheme.radiusL),
  ),
)
```

---

## 🔍 **Exemplos Práticos**

### Card de Restaurante
```dart
Card(
  elevation: AppTheme.elevationM,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppTheme.radiusL),
  ),
  child: Padding(
    padding: EdgeInsets.all(AppTheme.spacingM),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sushi Zen',
          style: AppTextStyles.restaurantName,
        ),
        SizedBox(height: AppTheme.spacingS),
        Text(
          'R\$ 80-120',
          style: AppTextStyles.price,
        ),
        SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingS,
          children: [
            Chip(
              label: Text('romântico', style: AppTextStyles.tag),
              backgroundColor: AppColors.areiaMedia,
            ),
          ],
        ),
      ],
    ),
  ),
)
```

### Botão Primário com Estado
```dart
ElevatedButton(
  onPressed: isLoading ? null : onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.azulProfundo,
    foregroundColor: AppColors.branco,
    padding: EdgeInsets.symmetric(
      horizontal: AppTheme.spacingL,
      vertical: AppTheme.spacingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusL),
    ),
  ),
  child: isLoading
      ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppColors.branco,
            strokeWidth: 2,
          ),
        )
      : Text(
          'Buscar Restaurantes',
          style: AppTextStyles.labelLarge,
        ),
)
```

---

## 🧪 **Showcase Interativo**

Para ver todos os componentes em ação, execute:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DesignShowcase(),
  ),
);
```

O showcase inclui:
- 🎨 Paleta de cores completa
- ✍️ Exemplos de tipografia
- 🔘 Todos os tipos de botões
- 📝 Formulários e inputs
- 🃏 Cards e componentes
- ♿ Demonstrações de acessibilidade

---

## 📱 **Responsividade**

### Breakpoints
```dart
Mobile: < 600px
Tablet: 600px - 1200px
Desktop: > 1200px
```

### Adaptações
- **Mobile**: Espaçamentos reduzidos (75%)
- **Tablet**: Espaçamentos normais
- **Desktop**: Espaçamentos aumentados (125%)

---

## 🔄 **Estados dos Componentes**

### Interações
| Estado | Opacidade | Cor de Fundo |
|--------|-----------|--------------|
| Normal | 100% | Cor padrão |
| Hover | 100% | +8% overlay |
| Pressed | 100% | +12% overlay |
| Focus | 100% | Borda amarela |
| Disabled | 60% | Cinza claro |

### Loading
- **Botões**: Spinner branco 20x20
- **Cards**: Skeleton com gradiente
- **Inputs**: Borda pulsante

---

## ✅ **Checklist de Implementação**

### Cores
- [ ] Todas as cores hardcoded substituídas
- [ ] Gradientes aplicados consistentemente
- [ ] Estados de hover/pressed configurados
- [ ] Contraste verificado em todos os componentes

### Tipografia
- [ ] Hierarquia consistente aplicada
- [ ] Tamanhos mínimos respeitados
- [ ] Line-height otimizado para legibilidade
- [ ] Letter-spacing aplicado corretamente

### Componentes
- [ ] Botões seguem especificação Material 3
- [ ] Cards têm elevação e radius corretos
- [ ] Inputs têm estados visuais claros
- [ ] Touch targets >= 48px

### Acessibilidade
- [ ] Contraste mínimo 4.5:1 verificado
- [ ] Focus indicators visíveis
- [ ] Estados disabled claros
- [ ] Textos alternativos em ícones

---

## 🔧 **Manutenção**

### Atualizações
1. Modificar apenas arquivos centrais (`app_colors.dart`, `app_text_styles.dart`)
2. Testar em pelo menos 3 telas diferentes
3. Verificar contraste com ferramentas WCAG
4. Atualizar documentação se necessário

### Novos Componentes
1. Seguir padrões existentes
2. Usar sistema de espaçamento
3. Aplicar cores da paleta
4. Documentar uso e variações

---

*📅 Última atualização: Dezembro 2024*
*👤 Responsável: Engenheiro de Software Sênior* 