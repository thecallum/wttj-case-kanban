import { gql } from '@apollo/client'

export const CANDIDATE_MOVED = gql`
subscription TestSubscription($jobId: ID!) {
  candidateMoved(jobId: $jobId) {
    candidate {
      id
      email
      jobId
      position
      displayOrder
      statusId
    }
    clientId
    sourceStatus {
      id
      lockVersion
    }
    destinationStatus {
      id
      lockVersion
    }
  }
}
`
