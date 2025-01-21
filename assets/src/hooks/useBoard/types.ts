import { Candidate, Column } from '../../types'

export interface SortedCandidates {
  [key: string]: Candidate[]
}

export interface CandidateMovedSubscription {
  candidateMoved: {
    clientId: string
    candidate: Candidate
    sourceColumn: Column
    destinationColumn: Column
  }
}

export interface MoveCandidateMutation {
  moveCandidate: {
    candidate: Candidate
    sourceColumn: Column
    destinationColumn: Column
  }
}
