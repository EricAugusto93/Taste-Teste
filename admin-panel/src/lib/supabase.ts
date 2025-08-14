import { createClient } from '@supabase/supabase-js'

// Configurações do Supabase - Unificadas com o aplicativo Flutter
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Configurações do Supabase não encontradas. Verifique o arquivo .env.local')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
    flowType: 'pkce',
    storage: typeof window !== 'undefined' ? window.localStorage : undefined
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
  name: string
  description: string
  category_id: string
  image_url?: string
  rating: number
  review_count: number
  delivery_time: string
  delivery_fee: number
  min_order_value: number
  distance?: number
  has_promotion: boolean
  price_range: string
  latitude: number
  longitude: number
  address: string
  phone: string
  is_open: boolean
  is_featured: boolean
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
        .from('restaurants')
        .select('*')
        .order('name', { ascending: true })
      
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
        .from('restaurants')
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
      console.log('🚀 Criando restaurante:', restaurante)
      
      // Verificar sessão atual
      const { data: { session } } = await supabase.auth.getSession()
      console.log('👤 Sessão atual:', session?.user?.email || 'NENHUMA')
      
      const { data, error } = await supabase
        .from('restaurants')
        .insert([restaurante])
        .select()
        .single()
      
      if (error) {
        console.error('❌ Erro na inserção:', error)
        throw error
      }
      
      console.log('✅ Restaurante criado com sucesso:', data)
      return data as Restaurante
    } catch (error) {
      console.error('💥 Erro geral na criação:', error)
      return handleApiError(error)
    }
  },

  // Atualizar restaurante
  update: async (id: string, restaurante: Partial<Omit<Restaurante, 'id'>>) => {
    try {
      const { data, error } = await supabase
        .from('restaurants')
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
        .from('restaurants')
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
      console.log('📁 Fazendo upload da imagem:', file.name, 'Tamanho:', file.size)
      
      // Verificar sessão atual
      const { data: { session } } = await supabase.auth.getSession()
      console.log('👤 Sessão para upload:', session?.user?.email || 'NENHUMA')
      
      const fileExt = file.name.split('.').pop()
      const fileName = `${Date.now()}.${fileExt}`
      const filePath = `${folder}/${fileName}`

      console.log('📂 Caminho do arquivo:', filePath)

      const { data, error } = await supabase.storage
        .from('images')
        .upload(filePath, file)

      if (error) {
        console.error('❌ Erro no upload:', error)
        throw error
      }

      console.log('✅ Upload realizado:', data.path)

      const { data: { publicUrl } } = supabase.storage
        .from('images')
        .getPublicUrl(filePath)

      console.log('🔗 URL pública gerada:', publicUrl)
      return publicUrl
    } catch (error) {
      console.error('💥 Erro geral no upload:', error)
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