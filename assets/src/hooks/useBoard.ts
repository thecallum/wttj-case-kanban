import { useQuery } from '@apollo/client'
import { Candidate, Job, Status } from '../api'
import { GET_BOARD } from '../graphql/queries/getBoard'

export const useBoard = (jobId: string) => {
  const { loading, error, data } = useQuery<{
    job: Job
    candidates: Candidate[]
    statuses: Status[]
  }>(GET_BOARD, {
    variables: { jobId },
  })

  return {
    loading,
    error,
    job: data?.job || null,
    candidates: data?.candidates || [],
    statuses: data?.statuses || [],
  }
}
