import { gql } from '@apollo/client'

export const CANDIDATE_MOVED = gql`
subscription TestSubscription($jobId: ID!) {
  candidateMoved(jobId: $jobId) {
    id
    email
    jobId
    position
    displayOrder
    statusId
  }
}
`
