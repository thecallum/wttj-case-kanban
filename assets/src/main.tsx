import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import { QueryClient, QueryClientProvider } from 'react-query'
import apolloClient from './configureApolloClient.ts'
import { ApolloProvider } from '@apollo/client'

const queryClient = new QueryClient()

const root = createRoot(document.getElementById('root')!)

root.render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <ApolloProvider client={apolloClient}>
        <App />
      </ApolloProvider>
    </QueryClientProvider>
  </StrictMode>
)
