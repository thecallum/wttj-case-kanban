import { ApolloClient, InMemoryCache, HttpLink, split, ApolloLink } from '@apollo/client'
import { getMainDefinition } from '@apollo/client/utilities'
import { Socket as PhoenixSocket } from 'phoenix'
import * as AbsintheSocket from '@absinthe/socket'
import { createAbsintheSocketLink } from '@absinthe/socket-apollo-link'

const httpLink = new HttpLink({
  uri: __API_URL__,
})

const phoenixSocket = new PhoenixSocket(__WS_URL__)

const absintheSocket = AbsintheSocket.create(phoenixSocket)

const wsLink = createAbsintheSocketLink(absintheSocket) as unknown as ApolloLink

const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query)
    return definition.kind === 'OperationDefinition' && definition.operation === 'subscription'
  },
  wsLink,
  httpLink
)

const apolloClient = new ApolloClient({
  link: splitLink,
  cache: new InMemoryCache(),
})

export default apolloClient
