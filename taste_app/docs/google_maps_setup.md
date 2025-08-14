# Configuração do Google Maps

Este documento explica como configurar o Google Maps no aplicativo Taste.

## 1. Obter API Key do Google Maps

### Passo 1: Acessar o Google Cloud Console
1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um novo projeto ou selecione um existente
3. Ative a API do Google Maps

### Passo 2: Criar API Key
1. Vá para "APIs & Services" > "Credentials"
2. Clique em "Create Credentials" > "API Key"
3. Copie a API key gerada

### Passo 3: Configurar Restrições (Recomendado)
1. Clique na API key criada
2. Em "Application restrictions", selecione:
   - **HTTP referrers (web sites)** para web
   - **Android apps** para Android
   - **iOS apps** para iOS
3. Configure os domínios/pacotes permitidos

## 2. Configurar no Projeto

### Arquivo .env
Edite o arquivo `.env` na raiz do projeto:

```env
# Google Maps API Keys
GOOGLE_MAPS_API_KEY=sua_api_key_aqui

# Outras configurações...
SUPABASE_URL=https://msjzktnkvyycwahpalhb.supabase.co
SUPABASE_ANON_KEY=...
```

### Android (AndroidManifest.xml)
O arquivo `android/app/src/main/AndroidManifest.xml` já está configurado para usar a API key do .env:

```xml
<!-- Google Maps API Key -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

**Nota**: Para produção, substitua `YOUR_GOOGLE_MAPS_API_KEY` pela API key real ou configure via build script.

### iOS (AppDelegate.swift)
O arquivo `ios/Runner/AppDelegate.swift` já está configurado:

```swift
// Configure Google Maps
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

**Nota**: Para produção, substitua `YOUR_GOOGLE_MAPS_API_KEY` pela API key real ou configure via build script.

### Web (index.html)
O arquivo `web/index.html` já está configurado:

```html
<!-- Google Maps API -->
<script async defer
  src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places">
</script>
```

**Nota**: Para produção, substitua `YOUR_API_KEY` pela API key real ou configure via build script.

## 3. APIs Necessárias

Certifique-se de que as seguintes APIs estão habilitadas no Google Cloud Console:

- **Maps JavaScript API** (para web)
- **Maps SDK for Android** (para Android)
- **Maps SDK for iOS** (para iOS)
- **Places API** (para busca de lugares)
- **Geocoding API** (para conversão de endereços)
- **Geolocation API** (para localização)

## 4. Configuração Automática

O projeto inclui um sistema de configuração automática:

### GoogleMapsConfig
A classe `GoogleMapsConfig` gerencia a configuração automaticamente:

```dart
// Inicialização automática no main.dart
await GoogleMapsConfig.initialize();

// Verificações disponíveis
GoogleMapsConfig.isAvailable;     // Verifica se está disponível
GoogleMapsConfig.hasValidApiKey;  // Verifica se a API key é válida
GoogleMapsConfig.apiKey;          // Obtém a API key
```

### Fallback Widget
O `MapFallbackWidget` mostra mensagens apropriadas quando o mapa não está disponível:

- Detecta automaticamente se a API key está configurada
- Mostra instruções específicas para cada problema
- Inclui informações de debug em modo desenvolvimento

## 5. Teste da Configuração

### Desenvolvimento
1. Configure a API key no arquivo `.env`
2. Execute o app: `flutter run`
3. Navegue para uma página com mapa
4. Verifique se o mapa carrega corretamente

### Debug
Em modo debug, informações adicionais são exibidas:

```dart
// Informações de debug
print(GoogleMapsConfig.debugInfo);
```

### Logs
Verifique os logs do console para mensagens de status:

- ✅ "Google Maps API carregada com sucesso"
- ⚠️ "Google Maps API Key não configurada"
- ⚠️ "Timeout ao carregar Google Maps API"

## 6. Solução de Problemas

### Problema: Mapa não carrega na web
**Solução**:
1. Verifique se a API key está no arquivo `.env`
2. Verifique se a "Maps JavaScript API" está habilitada
3. Verifique as restrições de domínio na API key

### Problema: Mapa não carrega no mobile
**Solução**:
1. Verifique se a API key está configurada no AndroidManifest.xml/AppDelegate.swift
2. Verifique se as APIs móveis estão habilitadas
3. Verifique as restrições de pacote/bundle na API key

### Problema: Erro de permissão
**Solução**:
1. Verifique se todas as APIs necessárias estão habilitadas
2. Verifique se a API key tem as permissões corretas
3. Verifique se não há restrições bloqueando o acesso

## 7. Segurança

### Restrições Recomendadas
- **Web**: Restringir por domínio (ex: `localhost:*`, `*.taste.app`)
- **Android**: Restringir por package name e SHA-1
- **iOS**: Restringir por bundle identifier

### Variáveis de Ambiente
- Nunca commite API keys no código
- Use variáveis de ambiente para diferentes ambientes
- Configure API keys separadas para dev/staging/prod

### Monitoramento
- Configure alertas de uso no Google Cloud Console
- Monitore o uso da API para detectar uso anômalo
- Configure limites de uso para evitar custos excessivos