import { Candidate } from '../../types'
import { useRef } from 'react'
import { DropResult } from '@hello-pangea/dnd'
import {
  calculateTempNewDisplayPosition,
  getSibblingCandidates,
  verifyCandidateMoved,
} from './helpers'
import { useCandidateMovedSubscription } from './useCandidateMovedSubscription'
import { useBoardLayout } from './useBoardLayout'
import { useMoveCandidate } from './useMoveCandidate'

export const useBoard = (jobId: string) => {
  const clientId = useRef(Math.random().toString(36).substr(2, 9))

  const { loading, error, sortedCandidates, job, statuses, updateCandidatePosition } =
    useBoardLayout(jobId)

  useCandidateMovedSubscription(jobId, clientId.current, (candidate: Candidate) => {
    updateCandidatePosition(candidate.id, candidate.displayOrder, candidate.statusId)
  })

  const { handleUpdateCandidate, updateError } = useMoveCandidate(
    clientId.current,
    updateCandidatePosition // callback when update is successful, or reverted back to snapshot
  )

  const handleOnDragEnd = (dropResult: DropResult) => {
    const { destination, source } = dropResult

    if (!verifyCandidateMoved(source, destination)) return

    const candidate = sortedCandidates[source.droppableId][source.index]
    const { tempNewDisplayPosition, destinationStatusId, beforeIndex, afterIndex } =
      calculateNewDisplayPosition(dropResult, destination!.droppableId)

    updateCandidatePosition(candidate.id, tempNewDisplayPosition, destinationStatusId)

    handleUpdateCandidate(candidate, beforeIndex, afterIndex, destinationStatusId)
  }

  const calculateNewDisplayPosition = (dropResult: DropResult, statusId: string) => {
    const { previousCandidate, nextCandidate } = getSibblingCandidates(sortedCandidates, dropResult)

    // We're using optimistic UI updates. This means, the UI will be updated before we get a response
    // We dont know what the new display posiiton will be yet, so we're setting a temporary one
    // If the update is successful, it will be overwritten
    // Else, it will be reverted
    const tempNewDisplayPosition = calculateTempNewDisplayPosition(previousCandidate, nextCandidate)

    const destinationStatusId = parseInt(statusId)
    const beforeIndex = previousCandidate?.displayOrder ?? null
    const afterIndex = nextCandidate?.displayOrder ?? null

    return {
      tempNewDisplayPosition,
      destinationStatusId,
      beforeIndex,
      afterIndex,
    }
  }

  return {
    loading,
    error,
    job,
    statuses,
    sortedCandidates,
    handleOnDragEnd,
    updateError,
  }
}
