'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { restaurantesAPI, auth, checkAdminAccess, type Restaurante } from '@/lib/supabase'
import RestauranteTable from './components/RestauranteTable'
import RestauranteForm from './components/RestauranteForm'

export default function DashboardPage() {
  const [restaurantes, setRestaurantes] = useState<Restaurante[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [editingRestaurante, setEditingRestaurante] = useState<Restaurante | null>(null)
  const [adminEmail, setAdminEmail] = useState('admin@teste.com')
  const router = useRouter()

  useEffect(() => {
    checkAuth()
    loadRestaurantes()
  }, [])

  const checkAuth = async () => {
    try {
      console.log('🔍 Verificando autenticação...')
      
      // Primeiro, tentar obter a sessão atual
      const { data: sessionData, error: sessionError } = await auth.getUser()
      
      if (sessionError) {
        console.log('❌ Erro na sessão:', sessionError.message)
        
        // Se o erro for relacionado a refresh token, tentar reautenticar
        if (sessionError.message.includes('refresh_token_not_found') || 
            sessionError.message.includes('Invalid Refresh Token')) {
          console.log('🔄 Tentando limpar sessão e redirecionar...')
          
          // Limpar dados locais
          localStorage.removeItem('admin-session')
          await auth.signOut()
          
          // Redirecionar para login
          router.push('/login')
          return
        }
        
        throw sessionError
      }

      if (sessionData.user?.email) {
        console.log('✅ Usuário autenticado:', sessionData.user.email)
        setAdminEmail(sessionData.user.email)
        
        // Verificar se é admin
        const isAdminUser = await checkAdminAccess(sessionData.user.email)
        if (!isAdminUser) {
          console.log('❌ Usuário não é admin')
          router.push('/acesso-negado')
          return
        }
        
      } else {
        // Verificar localStorage como fallback
        console.log('🔄 Verificando localStorage...')
        const session = localStorage.getItem('admin-session')
        if (session) {
          const parsed = JSON.parse(session)
          setAdminEmail(parsed.email)
        } else {
          console.log('❌ Sem sessão, redirecionando para login')
          router.push('/login')
        }
      }
    } catch (error: any) {
      console.error('❌ Erro na verificação de auth:', error)
      
      // Se for erro de token, limpar e redirecionar
      if (error.message?.includes('refresh_token') || 
          error.message?.includes('Invalid Refresh Token')) {
        localStorage.removeItem('admin-session')
        await auth.signOut()
      }
      
      router.push('/login')
    }
  }

  const loadRestaurantes = async () => {
    try {
      setLoading(true)
      const data = await restaurantesAPI.list()
      setRestaurantes(data)
    } catch (error) {
      console.error('Erro ao carregar restaurantes:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = async () => {
    await auth.signOut()
    localStorage.removeItem('admin-session')
    router.push('/login')
  }

  const handleAddRestaurante = () => {
    setEditingRestaurante(null)
    setShowForm(true)
  }

  const handleEditRestaurante = (restaurante: Restaurante) => {
    setEditingRestaurante(restaurante)
    setShowForm(true)
  }

  const handleDeleteRestaurante = async (id: string) => {
    if (!confirm('Tem certeza que deseja deletar este restaurante?')) {
      return
    }

    try {
      await restaurantesAPI.delete(id)
      await loadRestaurantes()
    } catch (error) {
      console.error('Erro ao deletar restaurante:', error)
      alert('Erro ao deletar restaurante')
    }
  }

  const handleFormSubmit = async () => {
    setShowForm(false)
    setEditingRestaurante(null)
    await loadRestaurantes()
  }

  const handleFormCancel = () => {
    setShowForm(false)
    setEditingRestaurante(null)
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-orange-50">
        <div className="text-center space-y-4">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="text-blue-600 font-medium">Carregando painel...</p>
        </div>
      </div>
    )
  }

  if (showForm) {
    return (
      <RestauranteForm
        restaurante={editingRestaurante}
        onSubmit={handleFormSubmit}
        onCancel={handleFormCancel}
      />
    )
  }

  return (
    <div className="min-h-screen bg-orange-50">
      {/* Header */}
      <header className="bg-blue-600 shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center py-4 sm:py-6 space-y-4 sm:space-y-0">
            <div className="flex flex-col sm:flex-row items-start sm:items-center space-y-3 sm:space-y-0 sm:space-x-4 w-full sm:w-auto">
              
              {/* Logo */}
              <div className="text-center sm:text-left">
                <div className="text-xl sm:text-2xl font-bold text-white">
                  Taste Test
                </div>
                <div className="text-xs text-white/70 font-medium tracking-wider">
                  ADMIN PANEL
                </div>
              </div>
              
              {/* Separador */}
              <div className="h-px w-full sm:h-8 sm:w-px bg-white/20 hidden sm:block"></div>
              
              {/* Info do painel */}
              <div className="w-full sm:w-auto">
                <h1 className="text-xl sm:text-2xl lg:text-3xl font-bold text-white">
                  Painel Administrativo
                </h1>
                <p className="text-xs sm:text-sm text-white/80 mt-1">
                  Logado como: <span className="font-medium text-yellow-200">{adminEmail}</span>
                </p>
              </div>
            </div>
            
            {/* Botão de Logout */}
            <button
              onClick={handleLogout}
              className="bg-yellow-400 hover:bg-yellow-500 text-blue-600 font-semibold py-2 px-4 rounded-lg transition-colors transform hover:scale-105 active:scale-95 shadow-lg hover:shadow-xl flex items-center space-x-2"
            >
              <span>🚪</span>
              <span className="hidden sm:inline">Sair</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-4 sm:py-6 px-4 sm:px-6 lg:px-8">
        <div className="space-y-6">
          
          {/* Header da seção */}
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center space-y-4 sm:space-y-0">
            <div>
              <h2 className="text-xl sm:text-2xl font-semibold text-blue-600">
                Restaurantes
              </h2>
              <p className="text-sm sm:text-base text-blue-600/70 mt-1">
                {restaurantes.length} restaurante{restaurantes.length !== 1 ? 's' : ''} cadastrado{restaurantes.length !== 1 ? 's' : ''}
              </p>
            </div>
            
            {/* Botão Principal */}
            <button
              onClick={handleAddRestaurante}
              className="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-lg flex items-center justify-center gap-2 transition-colors transform hover:scale-105 active:scale-95 shadow-lg hover:shadow-xl"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
              </svg>
              <span>Adicionar Restaurante</span>
            </button>
          </div>

          {/* Card da Tabela */}
          <div className="bg-white shadow-lg rounded-lg overflow-hidden border border-orange-200 transition-all hover:shadow-xl">
            <RestauranteTable
              restaurantes={restaurantes}
              onEdit={handleEditRestaurante}
              onDelete={handleDeleteRestaurante}
            />
          </div>
          
          {/* Estatísticas Rápidas */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
            <div className="bg-white p-4 rounded-lg shadow-md border border-orange-200 transition-all hover:shadow-lg">
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <span className="text-blue-600 text-xl">🍽️</span>
                </div>
                <div>
                  <p className="text-blue-600/70 text-sm font-medium">Total de Restaurantes</p>
                  <p className="text-blue-600 text-2xl font-bold">{restaurantes.length}</p>
                </div>
              </div>
            </div>
            
            <div className="bg-white p-4 rounded-lg shadow-md border border-orange-200 transition-all hover:shadow-lg">
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-yellow-100 rounded-lg">
                  <span className="text-yellow-600 text-xl">⭐</span>
                </div>
                <div>
                  <p className="text-blue-600/70 text-sm font-medium">Tipos Únicos</p>
                  <p className="text-blue-600 text-2xl font-bold">
                    {new Set(restaurantes.map(r => r.tipo)).size}
                  </p>
                </div>
              </div>
            </div>
            
            <div className="bg-white p-4 rounded-lg shadow-md border border-orange-200 transition-all hover:shadow-lg">
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-green-100 rounded-lg">
                  <span className="text-green-600 text-xl">📍</span>
                </div>
                <div>
                  <p className="text-blue-600/70 text-sm font-medium">Status</p>
                  <p className="text-blue-600 text-2xl font-bold">Ativo</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
} 