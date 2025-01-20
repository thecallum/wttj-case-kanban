import { gql } from '@apollo/client'

export const MOVE_CANDIDATE = gql`
mutation MoveCandidate(
  $candidateId: ID!, 
  $afterIndex: DisplayOrder, 
  $beforeIndex: DisplayOrder, 
  $destinationStatusId: ID,
  $clientId: String!,
  $sourceStatusVersion: Int!,
  $destinationStatusVersion: Int) {
  moveCandidate(
    candidateId: $candidateId, 
    afterIndex: $afterIndex, 
    beforeIndex: $beforeIndex, 
    destinationStatusId: $destinationStatusId,
    clientId: $clientId,
    sourceStatusVersion: $sourceStatusVersion,
    destinationStatusVersion: $destinationStatusVersion) {
    candidate {
      id
      email
      jobId
      position
      displayOrder
      statusId
    }
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
