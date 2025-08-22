'use client'

import { useState, useEffect } from 'react'
import Image from 'next/image'
import { Restaurante, categoriesAPI, Category } from '@/lib/supabase'



interface RestauranteTableProps {
  restaurantes: Restaurante[]
  onEdit: (restaurante: Restaurante) => void
  onDelete: (id: string) => void
}

// Componente separado para imagem para evitar re-renders
const RestauranteImage = ({ src, alt }: { src: string; alt: string }) => {
  const [imageError, setImageError] = useState(false)
  const [isLoading, setIsLoading] = useState(true)

  // URLs problemáticas que devem ser substituídas
  const isProblematicUrl = (url: string) => {
    return !url || 
           url.includes('exemplo.com') || 
           url.includes('example.com') || 
           url.includes('placeholder') ||
           url.includes('localhost') ||
           !url.startsWith('http')
  }

  // URL padrão para pizzarias ou genérica
  const getDefaultImageUrl = (alt: string) => {
    if (alt.toLowerCase().includes('pizza')) {
      return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=600&fit=crop&crop=center&q=80'
    }
    return 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=800&h=600&fit=crop&crop=center&q=80'
  }

  // Se a URL é problemática ou há erro, mostrar placeholder
  if (imageError || !src || isProblematicUrl(src)) {
    const defaultUrl = getDefaultImageUrl(alt)
    
    return (
      <div className="relative h-12 w-12 rounded-lg overflow-hidden bg-orange-100">
        {isLoading && (
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="animate-spin rounded-full h-4 w-4 border-2 border-orange-300 border-t-blue-600"></div>
          </div>
        )}
        <Image
          className="h-12 w-12 rounded-lg object-cover"
          src={defaultUrl}
          alt={alt}
          width={48}
          height={48}
          onLoad={() => setIsLoading(false)}
          unoptimized={true} // Desabilita otimização para evitar erros de domínio
        />
      </div>
    )
  }

  return (
    <div className="relative h-12 w-12 rounded-lg overflow-hidden bg-orange-100">
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="animate-spin rounded-full h-4 w-4 border-2 border-orange-300 border-t-blue-600"></div>
        </div>
      )}
      <Image
        className="h-12 w-12 rounded-lg object-cover"
        src={src}
        alt={alt}
        width={48}
        height={48}
        onError={() => setImageError(true)}
        onLoad={() => setIsLoading(false)}
        unoptimized={src.includes('example.com') || src.includes('unsplash.com') || src.includes('exemplo.com')} // Para URLs de exemplo e Unsplash
      />
    </div>
  )
}

export default function RestauranteTable({ restaurantes, onEdit, onDelete }: RestauranteTableProps) {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loadingCategories, setLoadingCategories] = useState(true);

  useEffect(() => {
    const loadCategories = async () => {
      try {
        const categoriesData = await categoriesAPI.listActive();
        setCategories(categoriesData);
      } catch (error) {
        console.error('Erro ao carregar categorias:', error);
      } finally {
        setLoadingCategories(false);
      }
    };

    loadCategories();
  }, []);

  const getCategoryName = (categoryId: string) => {
    const category = categories.find(cat => cat.id === categoryId);
    return category ? category.name : categoryId;
  };

  const getCategoryIcon = (categoryId: string) => {
    const category = categories.find(cat => cat.id === categoryId);
    return category ? category.icon : '🍽️';
  };

  const getCategoryColor = (categoryId: string) => {
    const category = categories.find(cat => cat.id === categoryId);
    return category ? category.color : '#FF6B47';
  };

  if (restaurantes.length === 0) {
    return (
      <div className="text-center py-12">
        <div className="mx-auto h-24 w-24 text-gray-400">
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
          </svg>
        </div>
        <h3 className="mt-2 text-sm font-semibold text-gray-900">Nenhum restaurante</h3>
        <p className="mt-1 text-sm text-gray-500">Comece criando o primeiro restaurante.</p>
      </div>
    )
  }

  return (
    <div className="overflow-hidden">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-blue-600">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-white uppercase tracking-wider">
                Restaurante
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-white uppercase tracking-wider">
                Tipo
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-white uppercase tracking-wider">
                Localização
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-white uppercase tracking-wider">
                Emoji & Contato
              </th>
              <th className="px-6 py-3 text-right text-xs font-medium text-white uppercase tracking-wider">
                Ações
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-orange-200">
            {restaurantes.map((restaurante, index) => (
              <tr 
                key={restaurante.id} 
                className={`hover:bg-orange-50 transition-colors ${
                  index % 2 === 0 ? 'bg-white' : 'bg-orange-25'
                }`}
              >
                {/* Coluna Restaurante */}
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center">
                    <div className="flex-shrink-0 h-12 w-12">
                      {restaurante.image_url ? (
                        <RestauranteImage src={restaurante.image_url} alt={restaurante.name} />
                      ) : (
                        <div className="h-12 w-12 rounded-lg bg-orange-100 flex items-center justify-center">
                          <svg className="h-6 w-6 text-blue-600/40" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                          </svg>
                        </div>
                      )}
                    </div>
                    <div className="ml-4">
                      <div className="text-sm font-semibold text-blue-600">
                        {restaurante.name}
                      </div>
                      <div className="text-sm text-blue-600/60 max-w-xs truncate">
                        {restaurante.description}
                      </div>
                    </div>
                  </div>
                </td>

                {/* Coluna Tipo */}
                <td className="px-6 py-4 whitespace-nowrap">
                  {loadingCategories ? (
                    <div className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-500">
                      Carregando...
                    </div>
                  ) : (
                    <span 
                      className="inline-flex items-center gap-1 px-2 py-1 text-xs font-semibold rounded-full text-white"
                      style={{ backgroundColor: getCategoryColor(restaurante.category_id) }}
                    >
                      <span>{getCategoryIcon(restaurante.category_id)}</span>
                      <span>{getCategoryName(restaurante.category_id)}</span>
                    </span>
                  )}
                </td>

                {/* Coluna Localização */}
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-blue-600">
                    {restaurante.latitude && restaurante.longitude ? (
                      <>
                        <div className="font-medium">📍 Localizado</div>
                        <div className="text-xs text-blue-600/60 mb-2">
                          {restaurante.latitude.toFixed(4)}, {restaurante.longitude.toFixed(4)}
                        </div>
                        <button
                          onClick={() => {
                            const url = `https://www.google.com/maps?q=${restaurante.latitude},${restaurante.longitude}`
                            window.open(url, '_blank')
                          }}
                          className="inline-flex items-center gap-1 px-2 py-1 text-xs bg-green-100 text-green-700 rounded-md hover:bg-green-200 transition-colors"
                          title="Ver no Google Maps"
                        >
                          🗺️ Ver no Mapa
                        </button>
                        {restaurante.address && (
                          <div className="text-xs text-blue-600/60 mt-1 max-w-xs truncate">
                            📍 {restaurante.address}
                          </div>
                        )}
                      </>
                    ) : (
                      <span className="text-gray-400">Sem coordenadas</span>
                    )}
                  </div>
                </td>

                {/* Coluna Emoji & Contato */}
                <td className="px-6 py-4">
                  <div className="space-y-2">
                    <div className="flex items-center gap-2">
                      <span className="text-2xl">{restaurante.emoji || '🍽️'}</span>
                      <span className="text-xs text-blue-600/60">Mapa</span>
                    </div>
                    <div className="text-xs text-blue-600/80">
                      <div className="flex items-center gap-1">
                        <span>📞</span>
                        <span>{restaurante.phone || 'N/A'}</span>
                      </div>
                      <div className="flex items-center gap-1 mt-1">
                        <span>💰</span>
                        <span>{restaurante.price_range}</span>
                      </div>
                    </div>
                  </div>
                </td>

                {/* Coluna Ações */}
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div className="flex justify-end space-x-2">
                    <button
                      onClick={() => onEdit(restaurante)}
                      className="text-blue-600 hover:text-blue-800 transition-colors p-2 hover:bg-blue-50 rounded-lg"
                      title="Editar restaurante"
                    >
                      <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>
                    <button
                      onClick={() => onDelete(restaurante.id)}
                      className="text-red-600 hover:text-red-800 transition-colors p-2 hover:bg-red-50 rounded-lg"
                      title="Deletar restaurante"
                    >
                      <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}