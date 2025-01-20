import { Candidate } from '../../types'

export interface SortedCandidates {
  [key: string]: Candidate[]
}

export interface CandidateMovedSubscription {
  candidateMoved: {
    clientId: string
    candidate: Candidate
  }
}

export interface MoveCandidateMutation {
  moveCandidate: Candidate
}
