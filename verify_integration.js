#!/usr/bin/env node

/**
 * Script de verificação da integração entre taste_app e admin-panel
 * Verifica se ambos acessam os mesmos dados no Supabase
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: './admin-panel/.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('❌ Configurações do Supabase não encontradas.');
  console.log('Configure o arquivo admin-panel/.env.local com:');
  console.log('NEXT_PUBLIC_SUPABASE_URL=your-url');
  console.log('NEXT_PUBLIC_SUPABASE_ANON_KEY=your-key');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function verifyIntegration() {
  console.log('🔍 Verificando integração entre taste_app e admin-panel...\n');
  
  try {
    // Verificar tabela de categorias
    console.log('📋 Verificando tabela categories...');
    const { data: categories, error: categoriesError } = await supabase
      .from('categories')
      .select('*')
      .limit(5);
      
    if (categoriesError) {
      console.error('❌ Erro ao acessar categories:', categoriesError.message);
    } else {
      console.log(`✅ Categories encontradas: ${categories.length}`);
      if (categories.length > 0) {
        console.log(`   - Exemplo: ${categories[0].name} (${categories[0].icon})`);
      }
    }
    
    // Verificar tabela de restaurantes
    console.log('\n🍽️  Verificando tabela restaurants...');
    const { data: restaurants, error: restaurantsError } = await supabase
      .from('restaurants')
      .select('*')
      .limit(5);
      
    if (restaurantsError) {
      console.error('❌ Erro ao acessar restaurants:', restaurantsError.message);
    } else {
      console.log(`✅ Restaurants encontrados: ${restaurants.length}`);
      if (restaurants.length > 0) {
        console.log(`   - Exemplo: ${restaurants[0].name} (${restaurants[0].address || 'sem endereço'})`);
      }
    }
    
    // Verificar tabela de admins
    console.log('\n👤 Verificando tabela admins...');
    const { data: admins, error: adminsError } = await supabase
      .from('admins')
      .select('*')
      .limit(5);
      
    if (adminsError) {
      console.error('❌ Erro ao acessar admins:', adminsError.message);
    } else {
      console.log(`✅ Admins encontrados: ${admins.length}`);
      if (admins.length > 0) {
        console.log(`   - Admin: ${admins[0].email}`);
      }
    }
    
    // Verificar storage de imagens
    console.log('\n📸 Verificando storage de imagens...');
    const { data: buckets, error: bucketsError } = await supabase.storage.listBuckets();
    
    if (bucketsError) {
      console.error('❌ Erro ao acessar storage:', bucketsError.message);
    } else {
      const imagesBucket = buckets.find(bucket => bucket.name === 'images');
      if (imagesBucket) {
        console.log('✅ Bucket "images" encontrado');
      } else {
        console.log('⚠️  Bucket "images" não encontrado');
      }
    }
    
    console.log('\n🎉 Verificação concluída!');
    console.log('\n📝 Próximos passos:');
    console.log('1. Configure o arquivo taste_app/.env com as mesmas credenciais');
    console.log('2. Execute "flutter pub get" no taste_app');
    console.log('3. Execute "npm install" no admin-panel');
    console.log('4. Teste criar um restaurante no admin-panel');
    console.log('5. Verifique se aparece no taste_app');
    
  } catch (error) {
    console.error('💥 Erro durante verificação:', error.message);
  }
}

verifyIntegration();