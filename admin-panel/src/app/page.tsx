export default function Home() {
  return (
    <div style={{ 
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
        <div style={{
          marginBottom: '24px'
        }}>
          <img 
            src="/taste-test-logo.png" 
            alt="Taste Test Logo" 
            style={{
              width: '200px',
              height: 'auto',
              margin: '0 auto',
              display: 'block'
            }}
          />
        </div>
        
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
    </div>
  )
}