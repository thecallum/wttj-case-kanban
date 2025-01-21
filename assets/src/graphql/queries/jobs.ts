import { gql } from '@apollo/client'

export const GET_JOBS = gql`
  query GetJobs {
    jobs {
      id
      name
    }
  }
`
