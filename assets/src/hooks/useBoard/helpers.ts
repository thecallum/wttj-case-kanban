import { DraggableLocation, DropResult } from '@hello-pangea/dnd'
import { SortedCandidates } from './types'
import { Candidate } from '../../types'

export const verifyCandidateMoved = (
  source: DraggableLocation<string>,
  destination: DraggableLocation<string> | null
) => {
  if (destination == null) return false

  // card dropped at original position
  if (source.droppableId == destination.droppableId && source.index == destination.index) {
    return false
  }

  return true
}

export const calculateTempNewDisplayPosition = (
  previousCandidate: Candidate | null,
  nextCandidate: Candidate | null
) => {
  if (previousCandidate === null && nextCandidate === null) {
    return 1
  }

  if (previousCandidate === null) {
    // Move to top of list
    return parseFloat(nextCandidate!.displayOrder) / 2
  }

  if (nextCandidate === null) {
    // Move to bottom of list
    return parseFloat(previousCandidate!.displayOrder) + 1
  }

  // Calculate middle point between before and after
  return (parseFloat(previousCandidate?.displayOrder) + parseFloat(nextCandidate?.displayOrder)) / 2
}

export const getSibblingCandidates = (
  sortedCandidates: SortedCandidates,
  dropResult: DropResult
) => {
  const { destination, source } = dropResult
  const { index: destinationIndex, droppableId: destinationColumnId } = destination!

  if (!sortedCandidates[destinationColumnId]) {
    return { previousCandidate: null, nextCandidate: null }
  }

  const destinationList = sortedCandidates[destinationColumnId]

  const indexOffset = calculateIndexOffset(source, destination)

  const previousCandidateIndex = destinationIndex! + indexOffset - 1
  const nextCandidateIndex = destinationIndex! + indexOffset

  return {
    previousCandidate: getCandidateAtIndex(destinationList, previousCandidateIndex),
    nextCandidate: getCandidateAtIndex(destinationList, nextCandidateIndex),
  }
}

const calculateIndexOffset = (
  source: DraggableLocation<string>,
  destination: DraggableLocation<string> | null
) => {
  const isMovingDown = destination!.index > source.index
  const isMovingToSameList = source.droppableId === destination?.droppableId

  const indexOffset = isMovingDown && isMovingToSameList ? 1 : 0
  // When moving down within the same list, we need to take into account the
  // index of the item being moved (its still in sortedCandidates)

  return indexOffset
}

const getCandidateAtIndex = (candidateList: Candidate[], index: number) => {
  return Object.prototype.hasOwnProperty.call(candidateList, index) ? candidateList[index] : null
}
