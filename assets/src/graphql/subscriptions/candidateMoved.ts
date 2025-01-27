import { gql } from '@apollo/client'

export const CANDIDATE_MOVED = gql`
subscription TestSubscription($jobId: ID!) {
  candidateMoved(jobId: $jobId) {
    candidate {
      id
      email
      jobId
      displayOrder
      columnId
    }
    clientId
    sourceColumn {
      id
      lockVersion
    }
    destinationColumn {
      id
      lockVersion
    }
  }
}
`
