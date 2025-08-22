const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Iniciando ambiente de desenvolvimento Taste App');
console.log('================================================');

// Função para executar comandos
function runCommand(command, args, cwd, name) {
  const process = spawn(command, args, {
    cwd: cwd,
    shell: true,
    stdio: 'inherit'
  });

  process.on('error', (error) => {
    console.error(`❌ Erro ao iniciar ${name}:`, error.message);
  });

  process.on('close', (code) => {
    console.log(`📋 ${name} encerrado com código: ${code}`);
  });

  return process;
}

async function startServices() {
  try {
    // 1. Iniciar CORS Proxy Server
    console.log('🔄 1. Iniciando CORS Proxy Server...');
    const proxyServer = runCommand('npm', ['run', 'start'], __dirname, 'CORS Proxy Server');
    
    // Aguardar proxy server inicializar
    await new Promise(resolve => setTimeout(resolve, 3000));

    // 2. Iniciar Admin Panel
    console.log('🔄 2. Iniciando Admin Panel...');
    const adminPanel = runCommand('npm', ['run', 'dev'], 
      path.join(__dirname, 'admin-panel'), 'Admin Panel');
    
    // Aguardar admin panel inicializar
    await new Promise(resolve => setTimeout(resolve, 5000));

    // 3. Iniciar Flutter App
    console.log('🔄 3. Iniciando Flutter App...');
    const flutterApp = runCommand('flutter', ['run', '-d', 'chrome', '--dart-define=ENVIRONMENT=development'], 
      path.join(__dirname, 'taste_app'), 'Flutter App');

    console.log('\n✅ Todos os serviços iniciados!');
    console.log('📋 URLs disponíveis:');
    console.log('   • CORS Proxy: http://localhost:8080');
    console.log('   • Admin Panel: http://localhost:3000'); 
    console.log('   • Flutter App: http://localhost:61593 (ou similar)');
    console.log('\n🔧 Para parar todos os serviços, pressione Ctrl+C');

    // Tratar interrupção
    process.on('SIGINT', () => {
      console.log('\n🛑 Parando todos os serviços...');
      proxyServer.kill();
      adminPanel.kill();
      flutterApp.kill();
      process.exit(0);
    });

  } catch (error) {
    console.error('❌ Erro ao iniciar serviços:', error.message);
    process.exit(1);
  }
}

// Verificar se todas as dependências estão instaladas
async function checkDependencies() {
  console.log('🔍 Verificando dependências...');
  
  // Verificar se Flutter está instalado
  try {
    const flutterVersion = spawn('flutter', ['--version'], { stdio: 'pipe' });
    flutterVersion.on('close', (code) => {
      if (code !== 0) {
        console.error('❌ Flutter não está instalado ou não está no PATH');
        process.exit(1);
      }
    });
  } catch (error) {
    console.error('❌ Flutter não foi encontrado:', error.message);
    process.exit(1);
  }

  console.log('✅ Dependências verificadas');
}

// Exibir instruções iniciais
function showInstructions() {
  console.log('\n📋 INSTRUÇÕES DE USO:');
  console.log('===================');
  console.log('1. Este script iniciará automaticamente:');
  console.log('   • CORS Proxy Server (porta 8080)');
  console.log('   • Admin Panel Next.js (porta 3000)');
  console.log('   • Flutter App (porta dinâmica)');
  console.log('');
  console.log('2. Se houver problemas de CORS no Flutter:');
  console.log('   • Copie .env.development.proxy para .env.development');
  console.log('   • Reinicie o Flutter app');
  console.log('');
  console.log('3. Para acessar o admin panel:');
  console.log('   • Use um dos emails: admin@gastroapp.com, admin@tasteapp.com, user@example.com');
  console.log('   • Qualquer senha no modo desenvolvimento');
  console.log('');
  console.log('▶️ Iniciando em 3 segundos...\n');
}

// Função principal
async function main() {
  showInstructions();
  
  // Aguardar 3 segundos
  await new Promise(resolve => setTimeout(resolve, 3000));
  
  await checkDependencies();
  await startServices();
}

// Executar se chamado diretamente
if (require.main === module) {
  main().catch(console.error);
}

module.exports = { startServices, checkDependencies };