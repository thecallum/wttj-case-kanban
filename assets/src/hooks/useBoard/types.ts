import { Candidate, Status } from '../../types'

export interface SortedCandidates {
  [key: string]: Candidate[]
}

export interface CandidateMovedSubscription {
  candidateMoved: {
    clientId: string
    candidate: Candidate
    sourceStatus: Status
    destinationStatus: Status
  }
}

export interface MoveCandidateMutation {
  moveCandidate: {
    candidate: Candidate
    sourceStatus: Status
    destinationStatus: Status
  }
}
