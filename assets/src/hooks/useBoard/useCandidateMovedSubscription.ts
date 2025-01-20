import { OnDataOptions, useSubscription } from '@apollo/client'
import { CandidateMovedSubscription } from './types'
import { CANDIDATE_MOVED } from '../../graphql/subscriptions/candidateMoved'
import { Candidate } from '../../types'

export const useCandidateMovedSubscription = (
  jobId: string,
  clientId: string,
  onCandidateMoved: (candidate: Candidate) => void,
  onStatusUpdate: (statusId: number, newVersion: number) => void
) => {
  const handleOnSubscriptionData = (data: OnDataOptions<CandidateMovedSubscription>) => {
    const candidateMoved = data.data.data!.candidateMoved

    // hide echos (events triggered by this client)
    if (clientId === candidateMoved.clientId) return

    onCandidateMoved(candidateMoved.candidate)

    const { sourceStatus, destinationStatus } = candidateMoved
    onStatusUpdate(sourceStatus.id, sourceStatus.lockVersion)
    onStatusUpdate(destinationStatus.id, destinationStatus.lockVersion)
  }

  useSubscription<CandidateMovedSubscription>(CANDIDATE_MOVED, {
    variables: {
      jobId,
    },
    onData: handleOnSubscriptionData,
  })

  return {}
}
