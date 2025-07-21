# 📱 Configuração Android - Google Maps & Localização

## Permissões Necessárias

Adicione as seguintes permissões no arquivo `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.gastro_app">

    <!-- Permissões de localização -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application
        android:label="Gastro App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- API Key do Google Maps -->
        <meta-data android:name="com.google.android.geo.API_KEY"
                   android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to be the theme of the Activity until the Flutter app is ready to display its first screen. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## Google Maps API Key

1. **Obter API Key**:
   - Acesse o [Google Cloud Console](https://console.cloud.google.com/)
   - Crie um novo projeto ou selecione um existente
   - Ative a "Maps SDK for Android"
   - Crie credenciais -> API Key
   - Restrinja a key para Android apps (opcional, mas recomendado)

2. **Configurar no projeto**:
   - Substitua `YOUR_GOOGLE_MAPS_API_KEY` pela sua API key real
   - Adicione também no arquivo `.env`:
     ```
     GOOGLE_MAPS_API_KEY=your_actual_api_key_here
     ```

## Configuração iOS (Futuro)

Para iOS, adicione no `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Este app precisa da localização para mostrar restaurantes próximos</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Este app precisa da localização para mostrar restaurantes próximos</string>
```

## Troubleshooting

### Erro: "MissingPluginException"
```bash
flutter clean
flutter pub get
flutter run
```

### Erro: "Google Maps não carrega"
- Verifique se a API Key está correta
- Confirme se a "Maps SDK for Android" está ativada
- Verifique se há cobrança ativa na conta Google Cloud (maps requer billing)

### Erro: "Localização negada"
- Certifique-se de que as permissões estão no AndroidManifest.xml
- Teste em dispositivo físico (emulador pode ter limitações)
- Verifique se o usuário permitiu a localização nas configurações do app

---

⚠️ **Importante**: Para testar o Google Maps, use um dispositivo físico ou emulador com Google Play Services instalados. 