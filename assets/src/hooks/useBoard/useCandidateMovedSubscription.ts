import { OnDataOptions, useSubscription } from '@apollo/client'
import { CandidateMovedSubscription } from './types'
import { CANDIDATE_MOVED } from '../../graphql/subscriptions/candidateMoved'
import { Candidate } from '../../types'

export const useCandidateMovedSubscription = (
  jobId: string,
  clientId: string,
  onCandidateMoved: (candidate: Candidate) => void,
  onStatusUpdate: (columnId: number, newVersion: number) => void
) => {
  const handleOnSubscriptionData = (data: OnDataOptions<CandidateMovedSubscription>) => {
    const candidateMoved = data.data.data!.candidateMoved

    // hide echos (events triggered by this client)
    if (clientId === candidateMoved.clientId) return

    onCandidateMoved(candidateMoved.candidate)

    const { sourceColumn, destinationColumn } = candidateMoved
    onStatusUpdate(sourceColumn.id, sourceColumn.lockVersion)
    onStatusUpdate(destinationColumn.id, destinationColumn.lockVersion)
  }

  useSubscription<CandidateMovedSubscription>(CANDIDATE_MOVED, {
    variables: {
      jobId,
    },
    onData: handleOnSubscriptionData,
  })

  return {}
}
