import { useQuery } from '@apollo/client'
import { GET_BOARD } from '../../graphql/queries/getBoard'
import { Candidate, Job, Status } from '../../types'
import { useEffect, useMemo, useState } from 'react'
import { DropResult } from '@hello-pangea/dnd'
import { SortedCandidates } from './types'
import { calculateTempNewDisplayPosition, verifyCandidateMoved } from './helpers'

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

  const handleOnDragEnd = (dropResult: DropResult) => {
    const { destination, source, draggableId } = dropResult

    if (!verifyCandidateMoved(source, destination)) return

    const newDisplayOrder = calculateTempNewDisplayPosition(sortedCandidates, dropResult)
    updateCandidatePosition(
      parseInt(draggableId),
      newDisplayOrder,
      parseInt(destination!.droppableId)
    )
  }

  return {
    loading,
    error,
    job,
    statuses,
    sortedCandidates,
    handleOnDragEnd,
  }
}
