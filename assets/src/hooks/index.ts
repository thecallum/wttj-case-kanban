import { useQuery } from 'react-query'
import { getCandidates, getJob, getStatuses } from '../api'

// export const useJobs = () => {
//   const { isLoading, error, data } = useQuery({
//     queryKey: ['jobs'],
//     queryFn: getJobs,
//   })

//   return { isLoading, error, jobs: data }
// }

export const useJob = (jobId?: string) => {
  const { isLoading, error, data } = useQuery({
    queryKey: ['job', jobId],
    queryFn: () => getJob(jobId),
    enabled: !!jobId,
  })

  return { isLoading, error, job: data }
}

export const useCandidates = (jobId?: string) => {
  const { isLoading, error, data } = useQuery({
    queryKey: ['candidates', jobId],
    queryFn: () => getCandidates(jobId),
    enabled: !!jobId,
  })

  return { isLoading, error, candidates: data }
}


export const useStatuses = (jobId?: string) => {
  const { isLoading, error, data } = useQuery({
    queryKey: ['statuses', jobId],
    queryFn: () => getStatuses(jobId),
    enabled: !!jobId,
  })

  return { isLoading, error, statuses: data }
}