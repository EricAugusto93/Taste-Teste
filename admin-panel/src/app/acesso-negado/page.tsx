'use client'

import { useRouter } from 'next/navigation'
import { auth } from '@/lib/supabase'

export default function AcessoNegadoPage() {
  const router = useRouter()

  const handleLogout = async () => {
    await auth.signOut()
    router.push('/login')
  }

  const handleGoBack = () => {
    router.push('/login')
  }

  return (
    <div className="min-h-screen bg-orange-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div className="bg-white shadow-xl rounded-2xl p-8 border border-red-200">
          <div className="text-center">
            <div className="mx-auto h-16 w-16 bg-red-500 rounded-full flex items-center justify-center mb-4">
              <span className="text-white text-2xl font-bold">🚫</span>
            </div>
            
            <h1 className="text-2xl font-bold text-red-600 mb-2">
              Acesso Negado
            </h1>
            
            <p className="text-red-600/70 text-sm mb-6">
              Você não tem permissão para acessar o painel administrativo.
            </p>
            
            <div className="bg-red-50 border border-red-200 rounded-xl p-4 mb-6">
              <p className="text-red-800 text-sm">
                ❌ <strong>Erro:</strong> Usuário não autorizado como administrador
              </p>
            </div>
            
            <div className="space-y-3">
              <button
                onClick={handleLogout}
                className="w-full px-6 py-3 bg-red-600 text-white rounded-xl font-semibold hover:bg-red-700 transition-all duration-200 flex items-center justify-center gap-2"
              >
                🚪 Fazer Logout
              </button>
              
              <button
                onClick={handleGoBack}
                className="w-full px-6 py-3 border border-red-300 text-red-600 rounded-xl font-semibold hover:bg-red-50 transition-all duration-200 flex items-center justify-center gap-2"
              >
                ↩️ Voltar ao Login
              </button>
            </div>
            
            <div className="mt-6 text-center">
              <p className="text-xs text-red-500/60">
                Entre em contato com o administrador do sistema para obter acesso
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
} 