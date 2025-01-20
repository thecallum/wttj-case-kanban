import { gql } from '@apollo/client'

export const MOVE_CANDIDATE = gql`
mutation MoveCandidate(
  $candidateId: ID!, 
  $afterIndex: DisplayOrder, 
  $beforeIndex: DisplayOrder, 
  $destinationStatusId: ID,
  $clientId: String!) {
  moveCandidate(
    candidateId: $candidateId, 
    afterIndex: $afterIndex, 
    beforeIndex: $beforeIndex, 
    destinationStatusId: $destinationStatusId,
    clientId: $clientId) {
    id
    email
    jobId
    position
    displayOrder
    statusId
  }
}

`
