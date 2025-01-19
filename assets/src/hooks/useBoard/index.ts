import { ApolloError, useMutation, useQuery } from '@apollo/client'
import { GET_BOARD } from '../../graphql/queries/getBoard'
import { Candidate, Job, Status } from '../../types'
import { useEffect, useMemo, useState } from 'react'
import { DropResult } from '@hello-pangea/dnd'
import {
  calculateTempNewDisplayPosition,
  getSibblingCandidates,
  verifyCandidateMoved,
} from './helpers'
import { UPDATE_CANDIDATE } from '../../graphql/queries/updateCandiate'
import { useSortedCandidates } from './useSortedCandidates'

export const useBoard = (jobId: string) => {
  const { loading, error, data } = useQuery<{
    job: Job
    candidates: Candidate[]
    statuses: Status[]
  }>(GET_BOARD, {
    variables: { jobId },
  })

  const handleOnUpdateError = (error: ApolloError) => {
    console.error('New error occurred when updating candidate', { error })

    setUpdateError(error.message)

    // revert candidate back to previous position
    updateCandidatePosition(
      candidateSnapshot!.id,
      candidateSnapshot!.displayOrder,
      candidateSnapshot!.statusId
    )
  }

  const handleOnUpdateSuccess = (data: { moveCandidate: Candidate }) => {
    // reset error
    setUpdateError(null)

    const { id, displayOrder, statusId } = data.moveCandidate

    updateCandidatePosition(id, displayOrder, statusId)
  }

  const [updateCandiate] = useMutation<{
    moveCandidate: Candidate
  }>(UPDATE_CANDIDATE, {
    onCompleted: handleOnUpdateSuccess,
    onError: handleOnUpdateError,
  })

  useEffect(() => {
    setJob(() => data?.job ?? null)
    setCandidates(() => data?.candidates || [])
    setStatuses(() => data?.statuses || [])
  }, [data])

  const [job, setJob] = useState<Job | null>(null)
  const [candidates, setCandidates] = useState<Candidate[]>([])
  const [statuses, setStatuses] = useState<Status[]>([])

  // Used to revert candidate when an error occurs
  const [candidateSnapshot, setCandidateSnapshot] = useState<Candidate | null>(null)
  const [updateError, setUpdateError] = useState<string | null>(null)

  const sortedCandidates = useSortedCandidates(candidates, statuses)

  const updateCandidatePosition = (candidateId: number, displayOrder: string, statusId: number) => {
    setCandidates(data => {
      return data.map(x => {
        if (x.id != candidateId) return x

        return {
          ...x,
          displayOrder,
          statusId,
        }
      })
    })
  }

  const handleOnDragEnd = (dropResult: DropResult) => {
    const { destination, source, draggableId } = dropResult

    if (!verifyCandidateMoved(source, destination)) return

    const { previousCandidate, nextCandidate } = getSibblingCandidates(sortedCandidates, dropResult)

    // store snapshot of current state, so candidate can be reverted
    // if update fails
    const candidate = sortedCandidates[source.droppableId][source.index]
    setCandidateSnapshot(candidate)

    // We're using optimistic UI updates. This means, the UI will be updated before we get a response
    // We dont know what the new display posiiton will be yet, so we're setting a temporary one
    // If the update is successful, it will be overwritten
    // Else, it will be reverted
    const tempNewDisplayPosition = calculateTempNewDisplayPosition(previousCandidate, nextCandidate)

    const candidateId = parseInt(draggableId)
    const destinationStatusId = parseInt(destination!.droppableId)
    const beforeIndex = previousCandidate?.displayOrder ?? null
    const afterIndex = nextCandidate?.displayOrder ?? null

    updateCandidatePosition(candidateId, tempNewDisplayPosition, destinationStatusId)

    // ToDo - remove me
    // Added to simulate occasional errors
    const randomCauseError = Math.random() < 0.25

    updateCandiate({
      variables: {
        candidateId: randomCauseError ? 123123 : candidateId,
        destinationStatusId,
        beforeIndex,
        afterIndex,
      },
    })
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
