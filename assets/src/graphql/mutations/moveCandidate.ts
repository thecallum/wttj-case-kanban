import { gql } from '@apollo/client'

export const MOVE_CANDIDATE = gql`
mutation MoveCandidate(
  $candidateId: ID!, 
  $nextCandidateDisplayOrder: DisplayOrder, 
  $previousCandidateDisplayOrder: DisplayOrder, 
  $destinationColumnId: ID,
  $clientId: String!,
  $sourceColumnVersion: Int!,
  $destinationColumnVersion: Int) {
  moveCandidate(
    candidateId: $candidateId, 
    nextCandidateDisplayOrder: $nextCandidateDisplayOrder, 
    previousCandidateDisplayOrder: $previousCandidateDisplayOrder, 
    destinationColumnId: $destinationColumnId,
    clientId: $clientId,
    sourceColumnVersion: $sourceColumnVersion,
    destinationColumnVersion: $destinationColumnVersion) {
    candidate {
      id
      email
      jobId
      displayOrder
      columnId
    }
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
