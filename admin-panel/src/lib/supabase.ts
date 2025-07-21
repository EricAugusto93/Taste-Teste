import { createClient } from '@supabase/supabase-js'

// Configurações fixas do Supabase (fallback para problemas de .env)
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://gnosarnyuiyrbcdwkfto.supabase.co'
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

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
  created_at: string
  updated_at: string
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
  
  signOut: () => 
    supabase.auth.signOut(),
  
  getUser: () => 
    supabase.auth.getUser(),
  
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

// Funções CRUD de restaurantes
export const restaurantesAPI = {
  // Listar todos os restaurantes
  list: async () => {
    const { data, error } = await supabase
      .from('restaurantes')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (error) throw error
    return data as Restaurante[]
  },

  // Buscar restaurante por ID
  getById: async (id: string) => {
    const { data, error } = await supabase
      .from('restaurantes')
      .select('*')
      .eq('id', id)
      .single()
    
    if (error) throw error
    return data as Restaurante
  },

  // Criar novo restaurante
  create: async (restaurante: Omit<Restaurante, 'id' | 'created_at' | 'updated_at'>) => {
    const { data, error } = await supabase
      .from('restaurantes')
      .insert([restaurante])
      .select()
      .single()
    
    if (error) throw error
    return data as Restaurante
  },

  // Atualizar restaurante
  update: async (id: string, restaurante: Partial<Omit<Restaurante, 'id' | 'created_at' | 'updated_at'>>) => {
    const { data, error } = await supabase
      .from('restaurantes')
      .update(restaurante)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return data as Restaurante
  },

  // Deletar restaurante
  delete: async (id: string) => {
    const { error } = await supabase
      .from('restaurantes')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }
}

// Funções para upload de imagens
export const storage = {
  uploadImage: async (file: File, folder: string = 'restaurantes') => {
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
  },

  deleteImage: async (url: string) => {
    // Extrair o caminho da URL
    const urlParts = url.split('/storage/v1/object/public/images/')
    if (urlParts.length < 2) return

    const filePath = urlParts[1]
    
    const { error } = await supabase.storage
      .from('images')
      .remove([filePath])

    if (error) throw error
  }
} 