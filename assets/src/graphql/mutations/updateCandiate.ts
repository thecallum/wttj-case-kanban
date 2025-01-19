import { gql } from '@apollo/client'

export const UPDATE_CANDIDATE = gql`
mutation MoveCard($candidateId: ID!, $afterIndex: DisplayOrder, $beforeIndex: DisplayOrder, $destinationStatusId: ID) {
  moveCandidate(candidateId: $candidateId, afterIndex: $afterIndex, beforeIndex: $beforeIndex, destinationStatusId: $destinationStatusId) {
    id
    email
    jobId
    position
    displayOrder
    statusId
  }
}

`
