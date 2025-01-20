import { ApolloClient, InMemoryCache, HttpLink, split } from '@apollo/client'
import { getMainDefinition } from '@apollo/client/utilities'
import { Socket as PhoenixSocket } from 'phoenix'
import * as AbsintheSocket from '@absinthe/socket'
import { createAbsintheSocketLink } from '@absinthe/socket-apollo-link'

const httpLink = new HttpLink({
  uri: 'http://localhost:4000/api/graphql/',
})

const phoenixSocket = new PhoenixSocket('ws://localhost:4000/socket', {
  params: { token: window.userToken },
})

const absintheSocket = AbsintheSocket.create(phoenixSocket)

const wsLink = createAbsintheSocketLink(absintheSocket)

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
