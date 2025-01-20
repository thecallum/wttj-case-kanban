import { Candidate, Job, Status } from '../../types'
import { GET_BOARD } from '../../graphql/queries/getBoard'
import { useQuery } from '@apollo/client'
import { useSortedCandidates } from './useSortedCandidates'
import { useEffect, useState } from 'react'

export const useBoardLayout = (jobId: string) => {
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

  const sortedCandidates = useSortedCandidates(candidates, statuses)

  return {
    loading,
    error,
    sortedCandidates,
    statuses,
    job,
    updateCandidatePosition,
  }
}
