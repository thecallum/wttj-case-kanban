import { useQuery } from '@apollo/client'
import { GET_BOARD } from '../graphql/queries/getBoard'
import { Candidate, Job, Status } from '../types'
import { useEffect, useMemo, useState } from 'react'
import { DraggableLocation, DropResult } from '@hello-pangea/dnd'

interface SortedCandidates {
  [key: string]: Candidate[]
}

export const useBoard = (jobId: string) => {
  const { loading, error, data } = useQuery<{
    job: Job
    candidates: Candidate[]
    statuses: Status[]
  }>(GET_BOARD, {
    variables: { jobId },
  })

  useEffect(() => {
    setJob(() => data?.job ?? null)
    setCandidates(() => data?.candidates || [])
    setStatuses(() => data?.statuses || [])
  }, [data])

  const [job, setJob] = useState<Job | null>(null)
  const [candidates, setCandidates] = useState<Candidate[]>([])
  const [statuses, setStatuses] = useState<Status[]>([])

  const sortedCandidates: SortedCandidates = useMemo(() => {
    if (!candidates) return {}

    const statusesById: { [key: number]: Status } = {}
    statuses?.forEach(status => {
      statusesById[status.id] = status
    })

    return candidates.reduce<SortedCandidates>((acc, c: Candidate) => {
      acc[c.statusId] = [...(acc[c.statusId] || []), c].sort((left, right) => {
        return parseFloat(left.displayOrder!) - parseFloat(right.displayOrder!)
      })
      return acc
    }, {})
  }, [candidates])

  const updateCandidatePosition = (candidateId: number, displayOrder: number, statusId: number) => {
    setCandidates(data => {
      return data.map(x => {
        if (x.id != candidateId) return x

        return {
          ...x,
          displayOrder: displayOrder.toString(),
          statusId,
        }
      })
    })
  }

  const verifyCandidateMoved = (
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

  const calculateTempNewDisplayPosition = (
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
    return (
      (parseFloat(previousCandidate?.displayOrder) + parseFloat(nextCandidate?.displayOrder)) / 2
    )
  }

  const handleOnDragEnd = (dropResult: DropResult) => {
    const { destination, source, draggableId } = dropResult

    if (!verifyCandidateMoved(source, destination)) return

    const newDisplayOrder = calculateTempNewDisplayPosition(sortedCandidates, dropResult)
    updateCandidatePosition(parseInt(draggableId), newDisplayOrder, destination?.droppableId)

    return
  }

  return {
    loading,
    error,

    job,
    candidates,
    statuses,
    sortedCandidates,
    handleOnDragEnd,
  }
}
