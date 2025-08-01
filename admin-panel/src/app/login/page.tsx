'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { signInWithEmail, isAdmin } from '@/lib/auth'

export default function LoginPage() {
  const [email, setEmail] = useState('admin@gastroapp.com')
  const [password, setPassword] = useState('admin123')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const router = useRouter()

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      console.log('🔐 Iniciando processo de login...')
      console.log('📧 Email:', email)
      
      // Autenticação real com Supabase
      console.log('🔄 Tentando autenticar com Supabase...')
      const { data, error: authError } = await signInWithEmail(email, password)
      
      console.log('📊 Resultado da autenticação:', { 
        user: data?.user?.email, 
        session: !!data?.session,
        error: authError?.message 
      })
      
      if (authError) {
        console.error('❌ Erro de autenticação:', authError)
        throw new Error(`Erro de autenticação: ${authError.message}`)
      }

      if (!data.user) {
        console.error('❌ Usuário não encontrado na resposta')
        throw new Error('Usuário não encontrado')
      }

      console.log('✅ Usuário autenticado:', data.user.email)

      // Verificar se é admin
      console.log('🔍 Verificando se o usuário é admin...')
      const isAdminUser = await isAdmin(data.user.email!)
      console.log('👤 Resultado verificação admin:', isAdminUser)
      
      if (!isAdminUser) {
        console.error('❌ Usuário não é admin')
        throw new Error('Acesso negado: usuário não é administrador')
      }

      console.log('✅ Usuário é admin, salvando sessão...')

      // Salvar sessão no localStorage como backup
      localStorage.setItem('admin-session', JSON.stringify({
        email: data.user.email,
        id: data.user.id,
        timestamp: Date.now(),
        session: data.session
      }))

      console.log('🎯 Redirecionando para dashboard...')
      
      // Aguardar um pouco para garantir que os cookies sejam definidos
      setTimeout(() => {
        // Usar window.location para forçar uma navegação completa
        window.location.href = '/dashboard'
      }, 500)
      
    } catch (err: any) {
      console.error('💥 Erro no processo de login:', err)
      setError(err.message || 'Erro no login. Verifique suas credenciais.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-orange-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div className="bg-white shadow-xl rounded-2xl p-8 border border-orange-200">
          <div className="text-center mb-8">
            <div className="mx-auto h-24 w-auto mb-6 flex items-center justify-center">
              <img 
                src="/taste-test-logo.png" 
                alt="Logo" 
                className="h-24 w-auto object-contain"
              />
            </div>
            <p className="text-blue-600/60 text-sm font-medium">
              Painel Administrativo
            </p>
          </div>

          <form onSubmit={handleLogin} className="space-y-6">
            {error && (
              <div className="bg-red-50 border border-red-200 rounded-xl p-4">
                <div className="flex items-center">
                  <span className="text-red-600 mr-2">❌</span>
                  <p className="text-red-800 text-sm font-medium">{error}</p>
                </div>
              </div>
            )}

            <div>
              <label htmlFor="email" className="block text-sm font-semibold text-blue-600 mb-2">
                Email do Administrador
              </label>
              <input
                id="email"
                name="email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                placeholder="admin@gastroapp.com"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-semibold text-blue-600 mb-2">
                Senha
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                placeholder="••••••••"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full px-6 py-3 bg-blue-600 text-white rounded-xl font-semibold hover:bg-blue-700 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 shadow-lg hover:shadow-xl transform hover:scale-105 active:scale-95"
            >
              {loading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                  Entrando...
                </>
              ) : (
                <>
                  🔐 Entrar no Painel
                </>
              )}
            </button>


          </form>

          <div className="mt-6 text-center">
            <p className="text-xs text-blue-600/50">
              Apenas administradores autorizados podem acessar
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}