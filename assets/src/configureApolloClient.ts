import { ApolloClient, InMemoryCache, HttpLink, split, ApolloLink } from '@apollo/client'
import { getMainDefinition } from '@apollo/client/utilities'
import { Socket as PhoenixSocket } from 'phoenix'
import * as AbsintheSocket from '@absinthe/socket'
import { createAbsintheSocketLink } from '@absinthe/socket-apollo-link'


// const API_URL = import.meta.env.VITE_API_URL
// const WS_URL = import.meta.env.VITE_WS_URL

// const API_URL = ""
// const WS_URL = ""

console.log({__API_URL__, __WS_URL__})

console.log(process.env)

console.log(import.meta.env)
console.log(import.meta.env.CALLUM)
console.log(import.meta.env.VITE_API_URL)
console.log(import.meta.env.TEST)

// Create the HTTP link
const httpLink = new HttpLink({
  uri: __API_URL__,
})

// Initialize Phoenix Socket
const phoenixSocket = new PhoenixSocket(__WS_URL__, {
  // params: { token: window.userToken },
})

// Create Absinthe Socket
const absintheSocket = AbsintheSocket.create(phoenixSocket)

// Create WebSocket link with proper type assertion
const wsLink = createAbsintheSocketLink(absintheSocket) as unknown as ApolloLink

// Split traffic between WebSocket and HTTP
const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query)
    return (
      definition.kind === 'OperationDefinition' && 
      definition.operation === 'subscription'
    )
  },
  wsLink,
  httpLink
)

// Initialize Apollo Client
const apolloClient = new ApolloClient({
  link: splitLink,
  cache: new InMemoryCache(),
})

export default apolloClient