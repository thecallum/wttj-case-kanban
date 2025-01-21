import { Candidate } from '../../types'
import { useRef } from 'react'
import { DropResult } from '@hello-pangea/dnd'
import {
  calculateTempNewDisplayPosition,
  getSibblingCandidates,
  verifyCandidateMoved,
} from './helpers'
import { useCandidateMovedSubscription } from './useCandidateMovedSubscription'
import { useBoardData as useBoardData } from './useBoardData'
import { useMoveCandidate } from './useMoveCandidate'

export const useBoard = (jobId: string) => {
  const clientId = useRef(Math.random().toString(36).substr(2, 9))

  const {
    loading,
    error,
    sortedCandidates,
    job,
    columns,
    columnsById,
    updateCandidatePosition,
    updateColumnVersion,
  } = useBoardData(jobId)

  useCandidateMovedSubscription(
    jobId,
    clientId.current,
    (candidate: Candidate) => {
      updateCandidatePosition(candidate.id, candidate.displayOrder, candidate.columnId)
    },
    updateColumnVersion
  )

  const { handleUpdateCandidate, updateError } = useMoveCandidate(
    clientId.current,
    updateCandidatePosition, // callback when update is successful, or reverted back to snapshot
    updateColumnVersion
  )

  const handleOnDragEnd = (dropResult: DropResult) => {
    const { destination, source } = dropResult

    if (!verifyCandidateMoved(source, destination)) return

    const candidate = sortedCandidates[source.droppableId][source.index]
    const { tempNewDisplayPosition, destinationColumnId, beforeIndex, afterIndex } =
      calculateNewDisplayPosition(dropResult, destination!.droppableId)

    updateCandidatePosition(candidate.id, tempNewDisplayPosition, destinationColumnId)

    const sourceColumn = columnsById[parseInt(source.droppableId)]
    const destinationColumn = destination ? columnsById[parseInt(destination!.droppableId)] : null

    handleUpdateCandidate(
      candidate,
      beforeIndex,
      afterIndex,
      destinationColumnId,
      sourceColumn,
      destinationColumn
    )
  }

  const calculateNewDisplayPosition = (dropResult: DropResult, columnId: string) => {
    const { previousCandidate, nextCandidate } = getSibblingCandidates(sortedCandidates, dropResult)

    // We're using optimistic UI updates. This means, the UI will be updated before we get a response
    // We dont know what the new display posiiton will be yet, so we're setting a temporary one
    // If the update is successful, it will be overwritten
    // Else, it will be reverted
    const tempNewDisplayPosition = calculateTempNewDisplayPosition(previousCandidate, nextCandidate)

    const destinationColumnId = parseInt(columnId)
    const beforeIndex = previousCandidate?.displayOrder ?? null
    const afterIndex = nextCandidate?.displayOrder ?? null

    return {
      tempNewDisplayPosition,
      destinationColumnId,
      beforeIndex,
      afterIndex,
    }
  }

  return {
    loading,
    error,
    job,
    columns,
    sortedCandidates,
    handleOnDragEnd,
    updateError,
  }
}
