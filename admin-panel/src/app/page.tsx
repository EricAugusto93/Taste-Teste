export default function Home() {
  return (
    <html>
      <head>
        <title>Taste Test - Admin Panel</title>
      </head>
      <body style={{ 
        minHeight: '100vh', 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center',
        backgroundColor: '#f3f4f6',
        fontFamily: 'system-ui, sans-serif',
        margin: 0,
        padding: '20px'
      }}>
        <div style={{
          maxWidth: '400px',
          width: '100%',
          backgroundColor: 'white',
          borderRadius: '8px',
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          padding: '32px',
          textAlign: 'center'
        }}>
          <h1 style={{
            fontSize: '32px',
            fontWeight: 'bold',
            color: '#2563eb',
            marginBottom: '8px'
          }}>
            Taste Test
          </h1>
          <p style={{
            color: '#6b7280',
            marginBottom: '24px'
          }}>
            Admin Panel
          </p>
          
          <p style={{
            color: '#374151',
            marginBottom: '24px'
          }}>
            Sistema de administração para restaurantes
          </p>
          
          <a 
            href="/login"
            style={{
              display: 'block',
              width: '100%',
              backgroundColor: '#2563eb',
              color: 'white',
              fontWeight: '600',
              padding: '12px 16px',
              borderRadius: '8px',
              textDecoration: 'none',
              boxSizing: 'border-box'
            }}
          >
            Acessar Painel Administrativo
          </a>
          
          <div style={{
            fontSize: '12px',
            color: '#9ca3af',
            marginTop: '16px'
          }}>
            Status: ✅ Sistema funcionando
          </div>
        </div>
      </body>
    </html>
  )
} 