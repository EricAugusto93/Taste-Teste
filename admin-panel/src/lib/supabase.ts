import { createClient } from '@supabase/supabase-js'

// Configurações fixas do Supabase (fallback para problemas de .env)
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://gnosarnyuiyrbcdwkfto.supabase.co'
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ'

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false
  }
})

// Interceptar erros de autenticação
supabase.auth.onAuthStateChange((event, session) => {
  console.log('🔄 Auth state changed:', event, session?.user?.email)
  
  if (event === 'SIGNED_OUT' || event === 'TOKEN_REFRESHED') {
    console.log('📝 Evento de auth:', event)
  }
  
  if (event === 'SIGNED_IN') {
    console.log('✅ Usuário logado:', session?.user?.email)
  }
})

// Tipos para as tabelas do banco
export interface Restaurante {
  id: string
  nome: string
  tipo: string
  descricao: string
  imagem_url?: string
  latitude: number
  longitude: number
  tags: string[]
  created_at?: string
  updated_at?: string
}

export interface Admin {
  id: string
  email: string
  created_at: string
}

// Funções utilitárias de autenticação
export const auth = {
  signIn: (email: string, password: string) => 
    supabase.auth.signInWithPassword({ email, password }),
  
  signOut: async () => {
    console.log('🚪 Fazendo logout...')
    const { error } = await supabase.auth.signOut()
    if (!error) {
      // Limpar localStorage também
      if (typeof window !== 'undefined') {
        localStorage.removeItem('admin-session')
      }
      console.log('✅ Logout realizado com sucesso')
    }
    return { error }
  },
  
  getUser: async () => {
    try {
      const result = await supabase.auth.getUser()
      if (result.error && result.error.message.includes('refresh_token_not_found')) {
        console.log('🔄 Refresh token não encontrado, fazendo logout automático')
        await auth.signOut()
      }
      return result
    } catch (error) {
      console.error('❌ Erro ao obter usuário:', error)
      return { data: { user: null }, error }
    }
  },
  
  onAuthStateChange: (callback: (event: string, session: any) => void) =>
    supabase.auth.onAuthStateChange(callback)
}

// Funções para verificar se é admin
export const checkAdminAccess = async (email: string): Promise<boolean> => {
  try {
    const { data, error } = await supabase
      .from('admins')
      .select('email')
      .eq('email', email)
      .single()
    
    return !error && !!data
  } catch {
    return false
  }
}

// Função para interceptar erros de API
const handleApiError = async (error: any) => {
  if (error?.message?.includes('refresh_token') || 
      error?.message?.includes('Invalid Refresh Token')) {
    console.log('🔄 Token expirado detectado, fazendo logout automático')
    await auth.signOut()
    if (typeof window !== 'undefined') {
      window.location.href = '/login'
    }
  }
  throw error
}

// Funções CRUD de restaurantes com interceptação de erros
export const restaurantesAPI = {
  // Listar todos os restaurantes
  list: async () => {
    try {
      const { data, error } = await supabase
        .from('restaurantes')
        .select('*')
        .order('nome', { ascending: true })
      
      if (error) throw error
      return data as Restaurante[]
    } catch (error) {
      return handleApiError(error)
    }
  },

  // Buscar restaurante por ID
  getById: async (id: string) => {
    try {
      const { data, error } = await supabase
        .from('restaurantes')
        .select('*')
        .eq('id', id)
        .single()
      
      if (error) throw error
      return data as Restaurante
    } catch (error) {
      return handleApiError(error)
    }
  },

  // Criar novo restaurante
  create: async (restaurante: Omit<Restaurante, 'id'>) => {
    try {
      const { data, error } = await supabase
        .from('restaurantes')
        .insert([restaurante])
        .select()
        .single()
      
      if (error) throw error
      return data as Restaurante
    } catch (error) {
      return handleApiError(error)
    }
  },

  // Atualizar restaurante
  update: async (id: string, restaurante: Partial<Omit<Restaurante, 'id'>>) => {
    try {
      const { data, error } = await supabase
        .from('restaurantes')
        .update(restaurante)
        .eq('id', id)
        .select()
        .single()
      
      if (error) throw error
      return data as Restaurante
    } catch (error) {
      return handleApiError(error)
    }
  },

  // Deletar restaurante
  delete: async (id: string) => {
    try {
      const { error } = await supabase
        .from('restaurantes')
        .delete()
        .eq('id', id)
      
      if (error) throw error
    } catch (error) {
      return handleApiError(error)
    }
  }
}

// Funções para upload de imagens
export const storage = {
  uploadImage: async (file: File, folder: string = 'restaurantes') => {
    try {
      const fileExt = file.name.split('.').pop()
      const fileName = `${Date.now()}.${fileExt}`
      const filePath = `${folder}/${fileName}`

      const { data, error } = await supabase.storage
        .from('images')
        .upload(filePath, file)

      if (error) throw error

      const { data: { publicUrl } } = supabase.storage
        .from('images')
        .getPublicUrl(filePath)

      return publicUrl
    } catch (error) {
      return handleApiError(error)
    }
  },

  deleteImage: async (url: string) => {
    try {
      // Extrair o caminho da URL
      const urlParts = url.split('/storage/v1/object/public/images/')
      if (urlParts.length < 2) return

      const filePath = urlParts[1]
      
      const { error } = await supabase.storage
        .from('images')
        .remove([filePath])

      if (error) throw error
    } catch (error) {
      return handleApiError(error)
    }
  }
} 