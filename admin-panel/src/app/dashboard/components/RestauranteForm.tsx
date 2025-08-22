'use client'

import { useState, useEffect } from 'react'
import { restaurantesAPI, storage, categoriesAPI, type Restaurante, type Category } from '@/lib/supabase'
import { geocodeAddress, ensureGoogleMapsLoaded, validateAddress, type GeocodeResult } from '@/lib/geocoding'

interface RestauranteFormProps {
  restaurante?: Restaurante | null
  onSubmit: () => void
  onCancel: () => void
}

export default function RestauranteForm({ restaurante, onSubmit, onCancel }: RestauranteFormProps) {
  const [formData, setFormData] = useState({
    nome: '',
    category_id: '',
    descricao: '',
    latitude: 0,
    longitude: 0,
    endereco: '',
    telefone: '',
    emoji: '🍽️',
    faixa_preco: '$$',
    imagem_url: ''
  })
  const [loading, setLoading] = useState(false)
  const [uploadingImage, setUploadingImage] = useState(false)
  const [geocoding, setGeocoding] = useState(false)
  const [geocodeResult, setGeocodeResult] = useState<GeocodeResult | null>(null)
  const [showManualCoords, setShowManualCoords] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [categories, setCategories] = useState<Category[]>([])
  const [loadingCategories, setLoadingCategories] = useState(true)

  // Carregar categorias do Supabase
  useEffect(() => {
    const loadCategories = async () => {
      try {
        setLoadingCategories(true)
        const categoriesData = await categoriesAPI.listActive()
        setCategories(categoriesData)
      } catch (error) {
        console.error('Erro ao carregar categorias:', error)
        setError('Erro ao carregar categorias')
      } finally {
        setLoadingCategories(false)
      }
    }

    loadCategories()
  }, [])

  useEffect(() => {
    if (restaurante) {
      setFormData({
        nome: restaurante.name,
        category_id: restaurante.category_id || '',
        descricao: restaurante.description,
        latitude: restaurante.latitude,
        longitude: restaurante.longitude,
        endereco: restaurante.address || '',
        telefone: restaurante.phone || '',
        emoji: restaurante.emoji || '🍽️',
        faixa_preco: restaurante.price_range || '$$',
        imagem_url: restaurante.image_url || ''
      })
    }
  }, [restaurante])

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: name === 'latitude' || name === 'longitude' ? parseFloat(value) || 0 : value
    }))
  }

  // Lista de emojis para seleção
  const emojiOptions = [
    { emoji: '🍽️', label: 'Geral' },
    { emoji: '🍕', label: 'Pizza' },
    { emoji: '🍔', label: 'Hambúrguer' },
    { emoji: '🍜', label: 'Sopa/Ramen' },
    { emoji: '🥗', label: 'Salada' },
    { emoji: '🍗', label: 'Frango' },
    { emoji: '🍰', label: 'Doces' },
    { emoji: '🍺', label: 'Bar/Bebidas' },
    { emoji: '☕', label: 'Café' },
    { emoji: '🍣', label: 'Japonês' },
    { emoji: '🥙', label: 'Mexicano' },
    { emoji: '🍝', label: 'Massas' },
    { emoji: '🥩', label: 'Sanduíche' },
    { emoji: '🍦', label: 'Sorvete' },
    { emoji: '🍟', label: 'Batata Frita' },
    { emoji: '🌮', label: 'Taco' }
  ]

  // Função para geocodificar endereço
  const handleGeocodeAddress = async () => {
    if (!formData.endereco.trim()) {
      setError('Digite um endereço antes de buscar as coordenadas')
      return
    }

    const validation = validateAddress(formData.endereco)
    if (validation) {
      setError(validation)
      return
    }

    setGeocoding(true)
    setError('')
    setGeocodeResult(null)

    try {
      // Garantir que Google Maps está carregado
      const isLoaded = await ensureGoogleMapsLoaded()
      if (!isLoaded) {
        throw new Error('Não foi possível carregar o Google Maps. Verifique sua conexão.')
      }

      const result = await geocodeAddress(formData.endereco)
      setGeocodeResult(result)
      
      // Atualizar coordenadas no formulário
      setFormData(prev => ({
        ...prev,
        latitude: result.lat,
        longitude: result.lng
      }))

      setSuccess(`✅ Coordenadas encontradas: ${result.formattedAddress}`)
      
    } catch (err: any) {
      setError(err.message)
      setShowManualCoords(true) // Mostrar campos manuais se falhar
    } finally {
      setGeocoding(false)
    }
  }

  // Geocodificar automaticamente quando o endereço mudar (com debounce)
  useEffect(() => {
    if (!formData.endereco || formData.endereco.length < 15) return

    const timeoutId = setTimeout(() => {
      if (validateAddress(formData.endereco) === null) {
        handleGeocodeAddress()
      }
    }, 2000) // 2 segundos de debounce

    return () => clearTimeout(timeoutId)
  }, [formData.endereco])

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    try {
      setUploadingImage(true)
      const imageUrl = await storage.uploadImage(file)
      setFormData(prev => ({ ...prev, imagem_url: imageUrl }))
    } catch (error) {
      console.error('Erro ao fazer upload da imagem:', error)
      setError('Erro ao fazer upload da imagem')
    } finally {
      setUploadingImage(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    setSuccess('')

    try {
      // Validações
      if (!formData.nome.trim()) {
        throw new Error('Nome é obrigatório')
      }
      if (!formData.category_id.trim()) {
        throw new Error('Categoria é obrigatória')
      }
      if (!formData.descricao.trim()) {
        throw new Error('Descrição é obrigatória')
      }
      if (!formData.endereco.trim()) {
        throw new Error('Endereço é obrigatório')
      }
      if (formData.latitude === 0 || formData.longitude === 0) {
        throw new Error('Não foi possível obter as coordenadas. Clique em "Buscar Coordenadas" ou digite um endereço mais específico.')
      }
      
      // Validar limites de coordenadas geográficas do Brasil
      if (formData.latitude < -35 || formData.latitude > 5) {
        throw new Error('Latitude deve estar dentro do território brasileiro (-35 a 5)')
      }
      if (formData.longitude < -75 || formData.longitude > -30) {
        throw new Error('Longitude deve estar dentro do território brasileiro (-75 a -30)')
      }
      
      // Validar formato do telefone apenas se fornecido
      if (formData.telefone.trim()) {
        const phoneRegex = /^\(?\d{2}\)?\s?\d{4,5}-?\d{4}$/
        if (!phoneRegex.test(formData.telefone.replace(/\s/g, ''))) {
          throw new Error('Telefone deve estar no formato (41) 99999-9999')
        }
      }

      const dados = {
        name: formData.nome.trim(),
        category_id: formData.category_id.trim(),
        description: formData.descricao.trim(),
        latitude: parseFloat(formData.latitude.toFixed(6)), // Limitar a 6 casas decimais 
        longitude: parseFloat(formData.longitude.toFixed(6)), // Limitar a 6 casas decimais
        address: formData.endereco.trim(),
        phone: formData.telefone.trim(),
        emoji: formData.emoji,
        price_range: formData.faixa_preco,
        image_url: formData.imagem_url || undefined,
        // Campos obrigatórios da interface com valores padrão
        rating: 0,
        review_count: 0,
        delivery_time: '30-45 min',
        delivery_fee: 0,
        min_order_value: 0,
        has_promotion: false,
        is_open: true,
        is_featured: false
      }

      if (restaurante) {
        // Atualizar restaurante existente
        await restaurantesAPI.update(restaurante.id, dados)
        setSuccess('Restaurante atualizado com sucesso!')
      } else {
        // Criar novo restaurante
        await restaurantesAPI.create(dados)
        setSuccess('Restaurante criado com sucesso!')
      }

      // Aguardar um pouco para mostrar a mensagem de sucesso
      setTimeout(() => {
        onSubmit()
      }, 1500)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-orange-50">
      <div className="max-w-4xl mx-auto py-8 px-6 sm:px-8 lg:px-12">
        <div className="bg-white rounded-2xl shadow-xl border border-orange-200 overflow-hidden">
          <div className="px-8 py-6 max-h-[80vh] overflow-y-auto">
            {/* Header Elegante */}
            <div className="flex justify-between items-center mb-6 pb-4 border-b border-orange-200">
              <div>
                <h3 className="text-xl font-bold text-blue-600">
                  {restaurante ? 'Editar Restaurante' : 'Adicionar Novo Restaurante'}
                </h3>
                <p className="text-sm text-blue-600/60 mt-1">
                  {restaurante ? 'Atualize as informações do restaurante' : 'Preencha os dados do novo restaurante'}
                </p>
              </div>
              <button
                onClick={onCancel}
                className="text-blue-600/40 hover:text-blue-600 transition-all duration-200 p-2 rounded-lg hover:bg-orange-100"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Nome - Campo Principal */}
              <div>
                <label htmlFor="nome" className="block text-sm font-semibold text-blue-600 mb-2">
                  Nome do Restaurante *
                </label>
                <input
                  type="text"
                  id="nome"
                  name="nome"
                  value={formData.nome}
                  onChange={handleInputChange}
                  className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                  placeholder="Digite o nome do restaurante"
                  required
                />
              </div>

              {/* Categoria - Seleção Elegante */}
              <div>
                <label htmlFor="category_id" className="block text-sm font-semibold text-blue-600 mb-2">
                  Categoria do Restaurante *
                </label>
                <select
                  id="category_id"
                  name="category_id"
                  value={formData.category_id}
                  onChange={handleInputChange}
                  className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600"
                  required
                  disabled={loadingCategories}
                >
                  <option value="" className="text-blue-600/60">
                    {loadingCategories ? 'Carregando categorias...' : 'Selecione a categoria'}
                  </option>
                  {categories.map(category => (
                    <option key={category.id} value={category.id} className="text-blue-600">
                      {category.icon} {category.name}
                    </option>
                  ))}
                </select>
                {loadingCategories && (
                  <p className="text-sm text-blue-600/60 mt-1">Carregando categorias do banco de dados...</p>
                )}
              </div>

              {/* Descrição */}
              <div>
                <label htmlFor="descricao" className="block text-sm font-semibold text-blue-600 mb-2">
                  Descrição *
                </label>
                <textarea
                  id="descricao"
                  name="descricao"
                  value={formData.descricao}
                  onChange={handleInputChange}
                  rows={4}
                  className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40 resize-none"
                  placeholder="Descreva o restaurante, sua especialidade, ambiente..."
                  required
                />
              </div>

              {/* Status da Geocodificação */}
              {geocodeResult && (
                <div className="p-4 bg-green-50 border border-green-200 rounded-xl">
                  <div className="flex items-start gap-3">
                    <span className="text-green-600 text-lg">📍</span>
                    <div className="flex-1">
                      <p className="text-green-800 font-medium text-sm">Localização encontrada!</p>
                      <p className="text-green-700 text-sm mt-1">{geocodeResult.formattedAddress}</p>
                      <p className="text-green-600 text-xs mt-1">
                        Coordenadas: {geocodeResult.lat.toFixed(6)}, {geocodeResult.lng.toFixed(6)}
                      </p>
                    </div>
                    <button
                      type="button"
                      onClick={() => {
                        const url = `https://www.google.com/maps?q=${geocodeResult.lat},${geocodeResult.lng}`
                        window.open(url, '_blank')
                      }}
                      className="text-green-600 hover:text-green-800 text-xs bg-green-100 hover:bg-green-200 px-2 py-1 rounded"
                    >
                      Ver no Mapa
                    </button>
                  </div>
                </div>
              )}

              {/* Coordenadas Manuais (ocultas por padrão) */}
              {showManualCoords && (
                <div className="border border-orange-200 rounded-xl p-4 bg-orange-50">
                  <div className="flex justify-between items-center mb-3">
                    <h4 className="text-sm font-semibold text-blue-600">Coordenadas Manuais</h4>
                    <button
                      type="button"
                      onClick={() => setShowManualCoords(false)}
                      className="text-blue-600/60 hover:text-blue-600 text-sm"
                    >
                      ✕ Fechar
                    </button>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label htmlFor="latitude" className="block text-sm font-medium text-blue-600 mb-2">
                        Latitude
                      </label>
                      <input
                        type="number"
                        id="latitude"
                        name="latitude"
                        value={formData.latitude || ''}
                        onChange={handleInputChange}
                        step="any"
                        className="w-full px-3 py-2 border border-orange-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 text-sm"
                        placeholder="Ex: -25.4284"
                      />
                    </div>
                    <div>
                      <label htmlFor="longitude" className="block text-sm font-medium text-blue-600 mb-2">
                        Longitude
                      </label>
                      <input
                        type="number"
                        id="longitude"
                        name="longitude"
                        value={formData.longitude || ''}
                        onChange={handleInputChange}
                        step="any"
                        className="w-full px-3 py-2 border border-orange-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 text-sm"
                        placeholder="Ex: -49.2733"
                      />
                    </div>
                  </div>
                  <p className="text-xs text-blue-600/60 mt-2">
                    Use apenas se a geocodificação automática falhar. As coordenadas devem estar no Brasil.
                  </p>
                </div>
              )}

              {/* Endereço e Telefone */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="endereco" className="block text-sm font-semibold text-blue-600 mb-2">
                    Endereço Completo *
                  </label>
                  <div className="space-y-2">
                    <input
                      type="text"
                      id="endereco"
                      name="endereco"
                      value={formData.endereco}
                      onChange={handleInputChange}
                      className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                      placeholder="Rua, número, bairro, cidade, estado"
                      required
                    />
                    <div className="flex gap-2">
                      <button
                        type="button"
                        onClick={handleGeocodeAddress}
                        disabled={geocoding || !formData.endereco.trim()}
                        className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 text-sm font-medium"
                      >
                        {geocoding ? (
                          <>
                            <div className="animate-spin rounded-full h-4 w-4 border-2 border-white/20 border-t-white"></div>
                            Buscando...
                          </>
                        ) : (
                          <>
                            📍 Buscar Coordenadas
                          </>
                        )}
                      </button>
                      {!showManualCoords && (
                        <button
                          type="button"
                          onClick={() => setShowManualCoords(true)}
                          className="px-4 py-2 border border-blue-600 text-blue-600 rounded-lg hover:bg-blue-50 transition-all duration-200 text-sm font-medium"
                        >
                          ⚙️ Manual
                        </button>
                      )}
                    </div>
                  </div>
                </div>
                <div>
                  <label htmlFor="telefone" className="block text-sm font-semibold text-blue-600 mb-2">
                    Telefone <span className="text-blue-600/60 text-xs">(opcional)</span>
                  </label>
                  <input
                    type="tel"
                    id="telefone"
                    name="telefone"
                    value={formData.telefone}
                    onChange={handleInputChange}
                    className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                    placeholder="(41) 99999-9999 - opcional"
                  />
                </div>
              </div>

              {/* Emoji e Faixa de Preço */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="emoji" className="block text-sm font-semibold text-blue-600 mb-2">
                    Emoji para o Mapa
                  </label>
                  <select
                    id="emoji"
                    name="emoji"
                    value={formData.emoji}
                    onChange={handleInputChange}
                    className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600"
                  >
                    {emojiOptions.map(option => (
                      <option key={option.emoji} value={option.emoji}>
                        {option.emoji} {option.label}
                      </option>
                    ))}
                  </select>
                  <div className="mt-2 text-center">
                    <span className="text-4xl">{formData.emoji}</span>
                    <p className="text-xs text-blue-600/60 mt-1">Prévia do emoji no mapa</p>
                  </div>
                </div>
                <div>
                  <label htmlFor="faixa_preco" className="block text-sm font-semibold text-blue-600 mb-2">
                    Faixa de Preço
                  </label>
                  <select
                    id="faixa_preco"
                    name="faixa_preco"
                    value={formData.faixa_preco}
                    onChange={handleInputChange}
                    className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600"
                  >
                    <option value="$">$ - Econômico (até R$ 25)</option>
                    <option value="$$">$$ - Médio (R$ 25-50)</option>
                    <option value="$$$">$$$ - Premium (acima de R$ 50)</option>
                  </select>
                </div>
              </div>

              {/* Upload de Imagem */}
              <div>
                <label className="block text-sm font-semibold text-blue-600 mb-2">
                  Imagem do Restaurante
                </label>
                <div className="space-y-3">
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleImageUpload}
                    className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-orange-100 file:text-blue-600 hover:file:bg-orange-200"
                    disabled={uploadingImage}
                  />
                  
                  {formData.imagem_url && (
                    <div className="relative">
                      <img
                        src={formData.imagem_url}
                        alt="Preview"
                        className="w-full h-48 object-cover rounded-xl border border-orange-200"
                      />
                      <button
                        type="button"
                        onClick={() => setFormData(prev => ({ ...prev, imagem_url: '' }))}
                                                 className="absolute top-2 right-2 bg-red-500 text-white p-2 rounded-lg hover:bg-red-600 transition-colors"
                      >
                        🗑️
                      </button>
                    </div>
                  )}
                </div>
              </div>

              {/* Mensagem de Erro */}
              {error && (
                <div className="p-4 bg-red-50 border border-red-200 rounded-xl">
                  <p className="text-red-800 text-sm font-medium">❌ {error}</p>
                </div>
              )}

              {/* Mensagem de Sucesso */}
              {success && (
                <div className="p-4 bg-green-50 border border-green-200 rounded-xl">
                  <p className="text-green-800 text-sm font-medium">✅ {success}</p>
                </div>
              )}

              {/* Botões de Ação */}
              <div className="flex flex-col sm:flex-row gap-3 pt-6">
                <button
                  type="button"
                  onClick={onCancel}
                                     className="flex-1 px-6 py-3 border border-orange-300 text-blue-600 rounded-xl font-semibold hover:bg-orange-50 transition-all duration-200"
                >
                  ↩️ Cancelar
                </button>
                <button
                  type="submit"
                  disabled={loading || uploadingImage}
                                     className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-xl font-semibold hover:bg-blue-700 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                  {loading ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-2 border-white/20 border-t-white"></div>
                      Salvando...
                    </>
                  ) : (
                    <>
                      {restaurante ? '✏️ Atualizar' : '✨ Criar'}
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  )
}