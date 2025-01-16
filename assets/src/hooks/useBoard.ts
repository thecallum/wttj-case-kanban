import { useQuery } from '@apollo/client'
import { GET_BOARD } from '../graphql/queries/getBoard'
import { Candidate, Job, Status } from '../types'
import { useEffect, useState } from 'react'

export const useBoard = (jobId: string) => {
  const [internalJob, setInternalJob] = useState<Job | null>(null)
  const [internalCandidates, setInternalCandidates] = useState<Candidate[]>([])
  const [internalStatuses, setInternalStatuses] = useState<Status[]>([])

  const { loading, error, data } = useQuery<{
    job: Job
    candidates: Candidate[]
    statuses: Status[]
  }>(GET_BOARD, {
    variables: { jobId },
  })

  useEffect(() => {
    if (data) {
      setInternalJob(data.job || null)
      setInternalCandidates(data.candidates || [])
      setInternalStatuses(data.statuses || [])
    }
  }, [data])

  return {
    loading,
    error,
    job: internalJob,
    candidates: internalCandidates,
    statuses: internalStatuses,
  }
}
