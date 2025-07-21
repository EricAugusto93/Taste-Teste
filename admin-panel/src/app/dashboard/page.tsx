'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { restaurantesAPI, auth, type Restaurante } from '@/lib/supabase'
import RestauranteTable from './components/RestauranteTable'
import RestauranteForm from './components/RestauranteForm'

export default function DashboardPage() {
  const [restaurantes, setRestaurantes] = useState<Restaurante[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [editingRestaurante, setEditingRestaurante] = useState<Restaurante | null>(null)
  const [adminEmail, setAdminEmail] = useState('')
  const router = useRouter()

  useEffect(() => {
    checkAuth()
    loadRestaurantes()
  }, [])

  const checkAuth = async () => {
    try {
      const { data } = await auth.getUser()
      if (data.user?.email) {
        setAdminEmail(data.user.email)
      } else {
        // Verificar localStorage como fallback
        const session = localStorage.getItem('admin-session')
        if (session) {
          const parsed = JSON.parse(session)
          setAdminEmail(parsed.email)
        } else {
          router.push('/login')
        }
      }
    } catch (error) {
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
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-600"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center py-4 sm:py-6 space-y-4 sm:space-y-0">
            <div className="flex flex-col sm:flex-row items-start sm:items-center space-y-3 sm:space-y-0 sm:space-x-4 w-full sm:w-auto">
              {/* Logo Taste Test */}
              <div className="text-center sm:text-left">
                <div className="text-xl sm:text-2xl font-bold bg-gradient-to-r from-orange-500 to-red-500 bg-clip-text text-transparent">
                  Taste Test
                </div>
                <div className="text-xs text-gray-400 font-medium tracking-wider">
                  ADMIN PANEL
                </div>
              </div>
              
              {/* Separador */}
              <div className="h-px w-full sm:h-8 sm:w-px bg-gray-300 hidden sm:block"></div>
              
              {/* Info do painel */}
              <div className="w-full sm:w-auto">
                <h1 className="text-xl sm:text-2xl lg:text-3xl font-bold text-gray-900">
                  Painel Administrativo
                </h1>
                <p className="text-xs sm:text-sm text-gray-600 mt-1">
                  Logado como: <span className="font-medium">{adminEmail}</span>
                </p>
              </div>
            </div>
            <button
              onClick={handleLogout}
              className="bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-lg transition-all duration-200 transform hover:scale-105 active:scale-95 shadow-md hover:shadow-lg flex items-center space-x-2"
              aria-label="Sair do painel administrativo"
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
              <h2 className="text-xl sm:text-2xl font-semibold text-gray-900">
                Restaurantes
              </h2>
              <p className="text-sm sm:text-base text-gray-600 mt-1">
                {restaurantes.length} restaurante{restaurantes.length !== 1 ? 's' : ''} cadastrado{restaurantes.length !== 1 ? 's' : ''}
              </p>
            </div>
            
            <button
              onClick={handleAddRestaurante}
              className="w-full sm:w-auto bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 text-white font-medium py-3 px-4 rounded-lg flex items-center justify-center gap-2 transition-all duration-200 transform hover:scale-105 active:scale-95 shadow-lg hover:shadow-xl"
              aria-label="Adicionar novo restaurante"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
              </svg>
              <span>Adicionar Restaurante</span>
            </button>
          </div>

          {/* Tabela de restaurantes */}
          <div className="bg-white shadow-sm rounded-xl overflow-hidden">
            <RestauranteTable
              restaurantes={restaurantes}
              onEdit={handleEditRestaurante}
              onDelete={handleDeleteRestaurante}
            />
          </div>
        </div>
      </main>

      {/* Modal do formulário */}
      {showForm && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-11/12 max-w-4xl shadow-lg rounded-md bg-white">
            <RestauranteForm
              restaurante={editingRestaurante}
              onSubmit={handleFormSubmit}
              onCancel={handleFormCancel}
            />
          </div>
        </div>
      )}

      {/* FAB para mobile */}
      <button
        onClick={handleAddRestaurante}
        className="fixed bottom-6 right-6 bg-orange-600 hover:bg-orange-700 text-white p-3 rounded-full shadow-lg transition duration-200 md:hidden"
      >
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
        </svg>
      </button>
    </div>
  )
} 