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
  sortedCandidates: SortedCandidates,
  dropResult: DropResult
) => {
  const { destination, source } = dropResult
  const { index: destinationIndex, droppableId: destinationColumnId } = destination!

  if (!Object.prototype.hasOwnProperty.call(sortedCandidates, destinationColumnId)) {
    //  empty column, set as 1
    return 1
  }

  const destinationList = sortedCandidates[destinationColumnId]

  const isMovingDown = destinationIndex! > source.index
  const isMovingToSameList = source.droppableId === destination?.droppableId
  // When moving down within the same list, we need to take into account the
  // index of the item being moved (its still in sortedCandidates)
  const indexOffset = isMovingDown && isMovingToSameList ? 1 : 0

  const { nextCandidate, previousCandidate } = getSibblingCandidates(
    destinationList,
    destinationIndex! + indexOffset
  )

  // Move to bottom of list
  if (nextCandidate == null) return parseFloat(previousCandidate!.displayOrder) + 1
  // Move to top of list
  if (previousCandidate == null) return parseFloat(nextCandidate!.displayOrder) / 2

  // Calculate middle point between before and after
  return (parseFloat(previousCandidate?.displayOrder) + parseFloat(nextCandidate?.displayOrder)) / 2
}

const getSibblingCandidates = (destinationList: Candidate[], destinationIndex: number) => {
  const previousCandidateIndex = destinationIndex! - 1
  const nextCandidateIndex = destinationIndex!

  const previousCandidate = Object.prototype.hasOwnProperty.call(
    destinationList,
    previousCandidateIndex
  )
    ? destinationList[previousCandidateIndex]
    : null
  const nextCandidate = Object.prototype.hasOwnProperty.call(destinationList, nextCandidateIndex)
    ? destinationList[nextCandidateIndex]
    : null

  return { previousCandidate, nextCandidate }
}
