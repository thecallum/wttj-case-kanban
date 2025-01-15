import { useQuery } from '@apollo/client'
import { Job } from '../api'
import { GET_JOBS } from '../graphql/queries/jobs'

export const useJobs = () => {
  const { loading, error, data } = useQuery<{
    jobs: Job[]
  }>(GET_JOBS)

  return {
    loading,
    error,
    jobs: data?.jobs || [],
  }
}
