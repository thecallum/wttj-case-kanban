import { Link as RouterLink } from 'react-router-dom'
import { Link } from '@welcome-ui/link'
import { useJobs } from '../../hooks/useJobs'

function JobIndex() {
  const { loading, error, jobs } = useJobs()

  if (error) return <p>Error : {error.message}</p>

  if (loading) {
    return null
  }

  return (
    <ul>
      {jobs.map(job => (
        <li key={job.id}>
          <Link as={RouterLink} to={`/jobs/${job.id}`}>
            {job.name}
          </Link>
        </li>
      ))}
    </ul>
  )
}

export default JobIndex
