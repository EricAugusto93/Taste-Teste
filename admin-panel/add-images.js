const { createClient } = require('@supabase/supabase-js');

// Configuração direta do Supabase
const supabaseUrl = 'https://gnosarnyuiyrbcdwkfto.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ';
const supabase = createClient(supabaseUrl, supabaseKey);

const ADMIN_EMAIL = 'admin@gastroapp.com';
const ADMIN_PASSWORD = 'admin123';

// Mapeamento de tipos para palavras-chave do Unsplash
const imagensMap = {
  'Japonesa': 'sushi,restaurant,japanese',
  'Mexicano': 'tacos,mexican,food',
  'Italiano': 'pasta,italian,restaurant',
  'Chinesa': 'chinese,food,restaurant',
  'Saudável': 'salad,healthy,food',
  'Cafeteria': 'coffee,cafe,breakfast',
  'Buffet': 'buffet,food,restaurant',
  'Churrascaria': 'barbecue,meat,brazilian',
  'Uruguaia': 'latin,food,restaurant',
  'Árabe': 'middle-eastern,food,restaurant',
  'Indiano': 'indian,curry,food',
  'Doceria': 'dessert,cake,sweet',
  'Hamburgueria': 'burger,fast-food,restaurant',
  'Lancheria': 'sandwich,snack,food'
};

function gerarImagemUrl(tipo) {
  const palavrasChave = imagensMap[tipo] || 'restaurant,food';
  return `https://source.unsplash.com/800x600/?${palavrasChave}`;
}

async function fazerLogin() {
  console.log('🔐 Fazendo login como admin...');
  
  const { data, error } = await supabase.auth.signInWithPassword({
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD,
  });

  if (error) {
    console.error('❌ Erro no login:', error);
    return false;
  }

  if (data.user) {
    console.log('✅ Login realizado com sucesso:', data.user.email);
    return true;
  }

  return false;
}

async function buscarRestaurantes() {
  console.log('🔍 Buscando restaurantes existentes...');
  
  const { data, error } = await supabase
    .from('restaurantes')
    .select('id, nome, tipo, imagem_url')
    .order('nome', { ascending: true });

  if (error) {
    console.error('❌ Erro ao buscar restaurantes:', error);
    return [];
  }

  console.log(`📊 Encontrados ${data.length} restaurantes`);
  return data;
}

async function atualizarLote(restaurantes, numeroLote) {
  console.log(`\n🖼️  Atualizando lote ${numeroLote} (${restaurantes.length} registros)...`);
  
  const updates = restaurantes.map(rest => ({
    id: rest.id,
    imagem_url: gerarImagemUrl(rest.tipo)
  }));

  // Atualizar cada restaurante individualmente para melhor controle
  let sucessos = 0;
  for (const update of updates) {
    const { error } = await supabase
      .from('restaurantes')
      .update({ imagem_url: update.imagem_url })
      .eq('id', update.id);

    if (error) {
      console.error(`❌ Erro ao atualizar restaurante ${update.id}:`, error);
    } else {
      sucessos++;
    }
  }

  console.log(`✅ Lote ${numeroLote} atualizado! ${sucessos}/${restaurantes.length} registros com sucesso.`);
  
  // Mostrar detalhes das atualizações
  updates.forEach((update, index) => {
    const rest = restaurantes[index];
    console.log(`   📸 ${rest.nome} (${rest.tipo}) → ${update.imagem_url}`);
  });

  return sucessos;
}

async function adicionarImagensATodos() {
  console.log('🚀 Iniciando atualização de imagens dos restaurantes...\n');

  // Fazer login primeiro
  const loginSucesso = await fazerLogin();
  if (!loginSucesso) {
    console.error('❌ Falha no login. Processo cancelado.');
    return;
  }

  // Buscar todos os restaurantes
  const restaurantes = await buscarRestaurantes();
  if (restaurantes.length === 0) {
    console.log('⚠️ Nenhum restaurante encontrado.');
    return;
  }

  // Dividir em lotes de 4
  const lotes = [];
  for (let i = 0; i < restaurantes.length; i += 4) {
    lotes.push(restaurantes.slice(i, i + 4));
  }

  let totalAtualizados = 0;

  // Atualizar cada lote
  for (let i = 0; i < lotes.length; i++) {
    const sucessosLote = await atualizarLote(lotes[i], i + 1);
    totalAtualizados += sucessosLote;
    
    // Pausa entre lotes
    if (i < lotes.length - 1) {
      await new Promise(resolve => setTimeout(resolve, 500));
    }
  }

  console.log(`\n🎉 Processo concluído! ${totalAtualizados} de ${restaurantes.length} restaurantes atualizados com imagens.`);

  // Verificação final
  const { data: verificacao } = await supabase
    .from('restaurantes')
    .select('nome, tipo, imagem_url')
    .order('nome', { ascending: true });

  if (verificacao) {
    const comImagem = verificacao.filter(r => r.imagem_url && r.imagem_url.trim() !== '');
    console.log(`📊 Restaurantes com imagem: ${comImagem.length}/${verificacao.length}`);
    
    // Mostrar resumo por tipo
    const tiposComImagem = [...new Set(comImagem.map(r => r.tipo))];
    console.log(`🏷️  Tipos com imagem: ${tiposComImagem.length} (${tiposComImagem.join(', ')})`);
  }

  // Logout
  await supabase.auth.signOut();
  console.log('🚪 Logout realizado.');
}

// Executar
adicionarImagensATodos().catch(console.error); 