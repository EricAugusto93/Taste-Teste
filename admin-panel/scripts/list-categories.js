// Script para listar todas as categorias do banco de dados
const { createClient } = require('@supabase/supabase-js');

// Configuração do Supabase (usando variáveis de ambiente)
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Variáveis de ambiente do Supabase não encontradas!');
  console.log('Certifique-se de que NEXT_PUBLIC_SUPABASE_URL e NEXT_PUBLIC_SUPABASE_ANON_KEY estão definidas.');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function listCategories() {
  try {
    console.log('🔍 Consultando categorias no banco de dados...');
    
    // Buscar todas as categorias
    const { data: allCategories, error: allError } = await supabase
      .from('categories')
      .select('*')
      .order('sort_order', { ascending: true });
    
    if (allError) {
      console.error('❌ Erro ao buscar categorias:', allError);
      return;
    }
    
    console.log('\n📊 TODAS AS CATEGORIAS:');
    console.log('========================');
    console.table(allCategories.map(cat => ({
      ID: cat.id.substring(0, 8) + '...',
      Nome: cat.name,
      Ícone: cat.icon,
      Cor: cat.color,
      Ativo: cat.is_active ? '✅' : '❌',
      Ordem: cat.sort_order
    })));
    
    // Buscar apenas categorias ativas
    const { data: activeCategories, error: activeError } = await supabase
      .from('categories')
      .select('*')
      .eq('is_active', true)
      .order('sort_order', { ascending: true });
    
    if (activeError) {
      console.error('❌ Erro ao buscar categorias ativas:', activeError);
      return;
    }
    
    console.log('\n🟢 CATEGORIAS ATIVAS:');
    console.log('=====================');
    console.table(activeCategories.map(cat => ({
      ID: cat.id.substring(0, 8) + '...',
      Nome: cat.name,
      Ícone: cat.icon,
      Cor: cat.color,
      Ordem: cat.sort_order
    })));
    
    // Estatísticas
    const totalCategories = allCategories.length;
    const activeCategoriesCount = activeCategories.length;
    const inactiveCategoriesCount = totalCategories - activeCategoriesCount;
    
    console.log('\n📈 ESTATÍSTICAS:');
    console.log('================');
    console.log(`Total de categorias: ${totalCategories}`);
    console.log(`Categorias ativas: ${activeCategoriesCount}`);
    console.log(`Categorias inativas: ${inactiveCategoriesCount}`);
    
  } catch (error) {
    console.error('❌ Erro inesperado:', error);
  }
}

// Executar o script
listCategories();