import { useQuery } from '@apollo/client'
import { GET_BOARD } from '../graphql/queries/getBoard'
import { Candidate, Job, Status } from '../types'
import { useEffect, useState } from 'react'

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

  return {
    loading,
    error,

    job,
    candidates,
    statuses,
  }
}
