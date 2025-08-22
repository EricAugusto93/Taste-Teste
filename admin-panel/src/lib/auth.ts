import { supabase } from './supabase'

export async function signInWithEmail(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  return { data, error }
}

export async function signOut() {
  const { error } = await supabase.auth.signOut()
  return { error }
}

export async function getCurrentUser() {
  const { data: { user } } = await supabase.auth.getUser()
  return user
}

export async function isAdmin(email: string): Promise<boolean> {
  try {
    // Lista de emails de administradores permitidos
    const adminEmails = [
      'admin@gastroapp.com',
      'admin@tasteapp.com',
      'user@example.com' // Para desenvolvimento
    ]
    
    // Primeiro verifica se é um email de admin válido
    if (!adminEmails.includes(email)) {
      console.log('❌ Email não está na lista de admins:', email)
      return false
    }
    
    // Tenta verificar na tabela admins se existir
    const { data, error } = await supabase
      .from('admins')
      .select('email')
      .eq('email', email)
      .single()
    
    if (!error && !!data) {
      console.log('✅ Admin verificado na tabela admins:', email)
      return true
    }
    
    // Fallback: permite login para emails válidos mesmo se tabela não existir
    console.log('⚠️ Tabela admins não acessível, usando lista local para:', email)
    return true
    
  } catch (err) {
    console.log('🔄 Erro ao verificar admin, usando fallback para:', email, err)
    // Lista de emails de administradores para fallback
    const adminEmails = [
      'admin@gastroapp.com',
      'admin@tasteapp.com', 
      'user@example.com'
    ]
    return adminEmails.includes(email)
  }
}

export async function getAuthSession() {
  const { data: { session } } = await supabase.auth.getSession()
  return session
} 