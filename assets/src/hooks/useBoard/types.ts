import { Candidate } from "../../types";

export interface SortedCandidates {
  [key: string]: Candidate[]
}


export interface CandidateMoved {
  candidateMoved: {
    clientId: string,
    candidate: Candidate
  }
}