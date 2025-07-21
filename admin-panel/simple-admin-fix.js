const { createClient } = require('@supabase/supabase-js')

const supabase = createClient(
  'https://gnosarnyuiyrbcdwkfto.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ'
)

async function createSimpleAdmin() {
  console.log('🔧 Método simples: criando admin via signup...')
  
  try {
    // Método 1: Tentar signup
    const { data: signupData, error: signupError } = await supabase.auth.signUp({
      email: 'admin@gastroapp.com',
      password: 'admin123',
      options: {
        emailRedirectTo: undefined // Não enviar email
      }
    })

    if (signupError && !signupError.message.includes('already registered')) {
      console.log('❌ Erro no signup:', signupError.message)
      
      // Método 2: Se signup falhou, tentar login direto
      console.log('🔄 Tentando login direto...')
      const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
        email: 'admin@gastroapp.com',
        password: 'admin123'
      })
      
      if (loginError) {
        console.log('❌ Login também falhou:', loginError.message)
        console.log('🔧 Código do erro:', loginError.status)
        return false
      }
      
      console.log('✅ Login direto funcionou!')
      console.log('👤 Usuário:', loginData.user.email)
      await supabase.auth.signOut()
      return true
    }

    console.log('✅ Signup funcionou!')
    if (signupData.user) {
      console.log('👤 Usuário criado:', signupData.user.email)
      console.log('📧 Confirmado:', signupData.user.email_confirmed_at ? 'Sim' : 'Não')
      
      // Adicionar à tabela admins
      const { error: adminError } = await supabase
        .from('admins')
        .upsert({ email: 'admin@gastroapp.com' })
      
      if (!adminError) {
        console.log('✅ Adicionado à tabela admins!')
      }
      
      await supabase.auth.signOut()
    }
    
    return true
    
  } catch (error) {
    console.log('❌ Erro geral:', error.message)
    return false
  }
}

createSimpleAdmin().then(success => {
  if (success) {
    console.log('\n🎉 ADMIN CONFIGURADO!')
    console.log('📧 Email: admin@gastroapp.com')
    console.log('🔑 Senha: admin123')
    console.log('🌐 Acesse: http://localhost:3000/login')
  } else {
    console.log('\n❌ Não foi possível configurar o admin')
    console.log('💡 Tente criar manualmente no dashboard do Supabase')
  }
}) 