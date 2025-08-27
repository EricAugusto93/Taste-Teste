// Serviço de Geocodificação usando Google Maps API

// Declaração global para Google Maps
declare global {
  interface Window {
    google: typeof google;
  }
  
  namespace google {
    namespace maps {
      class Geocoder {
        geocode(
          request: google.maps.GeocoderRequest,
          callback: (
            results: google.maps.GeocoderResult[] | null,
            status: google.maps.GeocoderStatus
          ) => void
        ): void;
      }
      
      interface GeocoderRequest {
        address?: string;
        componentRestrictions?: {
          country?: string;
        };
      }
      
      interface GeocoderResult {
        geometry: {
          location: {
            lat(): number;
            lng(): number;
          };
        };
        formatted_address: string;
        address_components?: Array<{
          long_name: string;
          short_name: string;
          types: string[];
        }>;
      }
      
      enum GeocoderStatus {
        OK = 'OK',
        ZERO_RESULTS = 'ZERO_RESULTS',
        OVER_QUERY_LIMIT = 'OVER_QUERY_LIMIT',
        REQUEST_DENIED = 'REQUEST_DENIED',
        INVALID_REQUEST = 'INVALID_REQUEST',
        UNKNOWN_ERROR = 'UNKNOWN_ERROR'
      }
    }
  }
}

export interface GeocodeResult {
  lat: number
  lng: number
  formattedAddress: string
  addressComponents: {
    street?: string
    neighborhood?: string
    city?: string
    state?: string
    country?: string
    postalCode?: string
  }
}

export interface GeocodeError {
  code: 'NOT_FOUND' | 'INVALID_REQUEST' | 'OVER_QUERY_LIMIT' | 'REQUEST_DENIED' | 'UNKNOWN_ERROR'
  message: string
}

// Cache para evitar requests desnecessários
const geocodeCache = new Map<string, GeocodeResult>()

// Função para normalizar endereço para cache
function normalizeAddress(address: string): string {
  return address.toLowerCase().trim().replace(/\s+/g, ' ')
}

// Função principal de geocodificação
export async function geocodeAddress(address: string): Promise<GeocodeResult> {
  if (!address || address.trim().length < 10) {
    throw new Error('Endereço muito curto. Digite o endereço completo com rua, número e cidade.')
  }

  const normalizedAddress = normalizeAddress(address)
  
  // Verificar cache primeiro
  if (geocodeCache.has(normalizedAddress)) {
    console.log('🗄️ Geocoding: Resultado encontrado no cache')
    return geocodeCache.get(normalizedAddress)!
  }

  // Verificar se o Google Maps está disponível
  if (typeof google === 'undefined' || !google.maps || !google.maps.Geocoder) {
    throw new Error('Google Maps não está carregado. Recarregue a página e tente novamente.')
  }

  console.log('🔍 Geocoding: Buscando coordenadas para:', address)

  return new Promise((resolve, reject) => {
    const geocoder = new google.maps.Geocoder()
    
    geocoder.geocode(
      {
        address: address,
        componentRestrictions: {
          country: 'BR' // Restringir ao Brasil
        }
      },
      (results, status) => {
        if (status === google.maps.GeocoderStatus.OK && results && results[0]) {
          const result = results[0]
          const location = result.geometry.location
          
          // Extrair componentes do endereço
          const addressComponents: GeocodeResult['addressComponents'] = {}
          
          result.address_components?.forEach(component => {
            const types = component.types
            
            if (types.includes('street_number') || types.includes('route')) {
              addressComponents.street = (addressComponents.street || '') + ' ' + component.long_name
            }
            if (types.includes('sublocality') || types.includes('neighborhood')) {
              addressComponents.neighborhood = component.long_name
            }
            if (types.includes('locality') || types.includes('administrative_area_level_2')) {
              addressComponents.city = component.long_name
            }
            if (types.includes('administrative_area_level_1')) {
              addressComponents.state = component.short_name
            }
            if (types.includes('country')) {
              addressComponents.country = component.long_name
            }
            if (types.includes('postal_code')) {
              addressComponents.postalCode = component.long_name
            }
          })

          const geocodeResult: GeocodeResult = {
            lat: location.lat(),
            lng: location.lng(),
            formattedAddress: result.formatted_address,
            addressComponents
          }

          // Validar se está no Brasil
          if (geocodeResult.lat < -35 || geocodeResult.lat > 5 || 
              geocodeResult.lng < -75 || geocodeResult.lng > -30) {
            reject(new Error('Endereço deve estar localizado no Brasil'))
            return
          }

          // Armazenar no cache
          geocodeCache.set(normalizedAddress, geocodeResult)
          
          console.log('✅ Geocoding: Coordenadas encontradas:', geocodeResult)
          resolve(geocodeResult)
          
        } else {
          let errorMessage = 'Não foi possível encontrar o endereço'
          let errorCode: GeocodeError['code'] = 'UNKNOWN_ERROR'
          
          switch (status) {
            case google.maps.GeocoderStatus.ZERO_RESULTS:
              errorMessage = 'Endereço não encontrado. Verifique se está correto e tente novamente.'
              errorCode = 'NOT_FOUND'
              break
            case google.maps.GeocoderStatus.OVER_QUERY_LIMIT:
              errorMessage = 'Limite de consultas excedido. Tente novamente em alguns minutos.'
              errorCode = 'OVER_QUERY_LIMIT'
              break
            case google.maps.GeocoderStatus.REQUEST_DENIED:
              errorMessage = 'Acesso negado à API de geocodificação. Verifique a configuração.'
              errorCode = 'REQUEST_DENIED'
              break
            case google.maps.GeocoderStatus.INVALID_REQUEST:
              errorMessage = 'Endereço inválido. Digite o endereço completo.'
              errorCode = 'INVALID_REQUEST'
              break
          }
          
          console.error('❌ Geocoding: Erro:', status, errorMessage)
          reject(new Error(errorMessage))
        }
      }
    )
  })
}

// Função para carregar a API do Google Maps (se ainda não estiver carregada)
export async function ensureGoogleMapsLoaded(): Promise<boolean> {
  // Se já está carregado, retornar true
  if (typeof google !== 'undefined' && google.maps && google.maps.Geocoder) {
    return true
  }

  // Se não está carregado, tentar carregar
  return new Promise((resolve) => {
    const script = document.createElement('script')
    script.src = `https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY}&libraries=places`
    script.async = true
    script.defer = true
    
    script.onload = () => {
      console.log('✅ Google Maps API carregada')
      resolve(true)
    }
    
    script.onerror = () => {
      console.error('❌ Erro ao carregar Google Maps API')
      resolve(false)
    }
    
    document.head.appendChild(script)
  })
}

// Função para validar endereço antes de geocodificar
export function validateAddress(address: string): string | null {
  if (!address || address.trim().length < 10) {
    return 'Endereço muito curto. Digite o endereço completo.'
  }
  
  // Verificar se tem pelo menos alguns componentes básicos
  const hasNumber = /\d/.test(address)
  const hasComma = address.includes(',')
  
  if (!hasNumber && !hasComma) {
    return 'Digite o endereço completo com número e cidade.'
  }
  
  return null
}

// Função para limpar cache (útil para desenvolvimento)
export function clearGeocodeCache(): void {
  geocodeCache.clear()
  console.log('🗑️ Cache de geocodificação limpo')
}