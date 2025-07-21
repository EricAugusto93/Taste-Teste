'use client'

import { useRouter } from 'next/navigation'
import { auth } from '@/lib/supabase'

export default function AcessoNegadoPage() {
  const router = useRouter()

  const handleLogout = async () => {
    await auth.signOut()
    localStorage.removeItem('admin-session')
    router.push('/login')
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8 text-center">
        <div>
          <svg
            className="mx-auto h-16 w-16 text-red-500"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
            />
          </svg>
          <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
            Acesso Negado
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Você não tem permissão para acessar este painel administrativo.
          </p>
          <p className="mt-1 text-sm text-gray-500">
            Apenas usuários autorizados podem gerenciar o sistema.
          </p>
        </div>

        <div className="mt-8 space-y-4">
          <button
            onClick={handleLogout}
            className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition duration-200"
          >
            Sair e Voltar ao Login
          </button>
          
          <div className="text-center">
            <p className="text-xs text-gray-500">
              Se você acredita que deveria ter acesso, entre em contato com o administrador do sistema.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
} 