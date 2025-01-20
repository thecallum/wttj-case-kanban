import { Candidate, Job, Status } from '../../types'
import { GET_BOARD } from '../../graphql/queries/getBoard'
import { useQuery } from '@apollo/client'
import { useSortedCandidates } from './useSortedCandidates'
import { useState } from 'react'

export const useBoardData = (jobId: string) => {
  const { loading, error } = useQuery<{
    job: Job
    candidates: Candidate[]
    statuses: Status[]
  }>(GET_BOARD, {
    variables: { jobId },
    onCompleted(data) {
      setJob(() => data?.job ?? null)
      setCandidates(() => data?.candidates || [])
      setStatuses(() => data?.statuses || [])
    },
  })

  const [job, setJob] = useState<Job | null>(null)
  const [candidates, setCandidates] = useState<Candidate[]>([])
  const [statuses, setStatuses] = useState<Status[]>([])

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

  const updateStatusVersion = (statusId: number, newVersion: number) => {
    setStatuses(data => {
      return data.map(x => {
        if (x.id !== statusId) return x

        return {
          ...x,
          lockVersion: newVersion,
        }
      })
    })
  }

  const sortedCandidates = useSortedCandidates(candidates, statuses)

  const statusesById = statuses.reduce<{ [key: number]: Status }>((acc, status: Status) => {
    acc[status.id] = status

    return acc
  }, {})

  return {
    loading,
    error,
    sortedCandidates,
    statuses,
    statusesById,
    job,
    updateCandidatePosition,
    updateStatusVersion,
  }
}
