# Script para gerar ícones da aplicação em diferentes tamanhos
# Requer ImageMagick instalado: https://imagemagick.org/script/download.php#windows

Write-Host "🎨 Gerando Ícones da Aplicação - Taste App" -ForegroundColor Cyan
Write-Host "" 

# Verificar se ImageMagick está instalado
try {
    magick -version | Out-Null
} catch {
    Write-Host "❌ Erro: ImageMagick não encontrado." -ForegroundColor Red
    Write-Host "📥 Baixe em: https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
    Write-Host "💡 Ou use: winget install ImageMagick.ImageMagick" -ForegroundColor Yellow
    exit 1
}

# Verificar se arquivo fonte existe
$sourceIcon = "store_assets/shared/logos/app_icon_1024.png"
if (-not (Test-Path $sourceIcon)) {
    Write-Host "❌ Arquivo fonte não encontrado: $sourceIcon" -ForegroundColor Red
    Write-Host "📝 Crie um ícone de 1024x1024 px em: $sourceIcon" -ForegroundColor Yellow
    
    # Criar pasta se não existir
    $logoDir = "store_assets/shared/logos"
    if (-not (Test-Path $logoDir)) {
        New-Item -ItemType Directory -Path $logoDir -Force | Out-Null
        Write-Host "📁 Pasta criada: $logoDir" -ForegroundColor Green
    }
    
    # Criar um ícone de exemplo
    Write-Host "🎨 Criando ícone de exemplo..." -ForegroundColor Cyan
    
    # Criar um ícone simples com ImageMagick
    $iconCommand = @"
magick -size 1024x1024 xc:"#FF6B47" `
    -fill white -font Arial-Bold -pointsize 200 `
    -gravity center -annotate +0+0 "T" `
    -fill "#FF6B47" -stroke white -strokewidth 8 `
    -draw "circle 512,512 512,100" `
    -fill white -font Arial-Bold -pointsize 200 `
    -gravity center -annotate +0+0 "T" `
    "$sourceIcon"
"@
    
    try {
        Invoke-Expression $iconCommand
        Write-Host "✅ Ícone de exemplo criado: $sourceIcon" -ForegroundColor Green
        Write-Host "💡 Substitua por seu ícone personalizado antes de usar em produção" -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Erro ao criar ícone de exemplo: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Definir tamanhos para Android (Google Play Store)
$androidSizes = @(
    @{Size=512; Path="store_assets/android/icons/ic_launcher_512.png"},
    @{Size=192; Path="store_assets/android/icons/ic_launcher_192.png"},
    @{Size=144; Path="store_assets/android/icons/ic_launcher_144.png"},
    @{Size=96; Path="store_assets/android/icons/ic_launcher_96.png"},
    @{Size=72; Path="store_assets/android/icons/ic_launcher_72.png"},
    @{Size=48; Path="store_assets/android/icons/ic_launcher_48.png"}
)

# Definir tamanhos para iOS (App Store)
$iosSizes = @(
    @{Size=1024; Path="store_assets/ios/icons/AppIcon_1024.png"},
    @{Size=180; Path="store_assets/ios/icons/AppIcon_180.png"},
    @{Size=167; Path="store_assets/ios/icons/AppIcon_167.png"},
    @{Size=152; Path="store_assets/ios/icons/AppIcon_152.png"},
    @{Size=120; Path="store_assets/ios/icons/AppIcon_120.png"},
    @{Size=87; Path="store_assets/ios/icons/AppIcon_87.png"},
    @{Size=80; Path="store_assets/ios/icons/AppIcon_80.png"},
    @{Size=76; Path="store_assets/ios/icons/AppIcon_76.png"},
    @{Size=60; Path="store_assets/ios/icons/AppIcon_60.png"},
    @{Size=58; Path="store_assets/ios/icons/AppIcon_58.png"},
    @{Size=40; Path="store_assets/ios/icons/AppIcon_40.png"},
    @{Size=29; Path="store_assets/ios/icons/AppIcon_29.png"},
    @{Size=20; Path="store_assets/ios/icons/AppIcon_20.png"}
)

function Generate-Icons {
    param(
        [array]$Sizes,
        [string]$Platform
    )
    
    Write-Host "📱 Gerando ícones para $Platform..." -ForegroundColor Green
    
    foreach ($icon in $Sizes) {
        $size = $icon.Size
        $outputPath = $icon.Path
        
        # Criar diretório se não existir
        $dir = Split-Path $outputPath -Parent
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        
        try {
            # Redimensionar ícone
            magick "$sourceIcon" -resize "${size}x${size}" "$outputPath"
            Write-Host "  ✅ ${size}x${size} -> $outputPath" -ForegroundColor White
        } catch {
            Write-Host "  ❌ Erro ao gerar ${size}x${size}: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Gerar ícones para Android
Generate-Icons -Sizes $androidSizes -Platform "Android"

Write-Host "" 

# Gerar ícones para iOS
Generate-Icons -Sizes $iosSizes -Platform "iOS"

Write-Host "" 
Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Substitua os ícones do projeto:" -ForegroundColor White
Write-Host "   - Android: android/app/src/main/res/mipmap-*/ic_launcher.png" -ForegroundColor Gray
Write-Host "   - iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/" -ForegroundColor Gray
Write-Host "2. Teste os ícones em diferentes dispositivos" -ForegroundColor White
Write-Host "3. Valide nas diretrizes das lojas" -ForegroundColor White

Write-Host "" 
Write-Host "🎨 Geração de ícones concluída!" -ForegroundColor Cyan