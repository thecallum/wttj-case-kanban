import { useParams } from 'react-router-dom'
import { Text } from '@welcome-ui/text'
import { Flex } from '@welcome-ui/flex'
import { Box } from '@welcome-ui/box'
import { useMemo } from 'react'
import { Candidate, Status } from '../../types'
import CandidateCard from '../../components/Candidate'
import { Badge } from '@welcome-ui/badge'
import { useBoard } from '../../hooks/useBoard'

interface SortedCandidates {
  [key: string]: Candidate[]
}

function JobShow() {
  const { jobId } = useParams()

  const { loading, error, job, candidates, statuses } = useBoard(jobId!)

  const sortedCandidates: SortedCandidates = useMemo(() => {
    if (!candidates) return {}

    const statusesById: {[key: number]: Status} = {}
    statuses?.forEach(status => {
      statusesById[status.id] = status
    });

    return candidates.reduce<SortedCandidates>((acc, c: Candidate) => {
      acc[c.statusId] = [...(acc[c.statusId] || []), c].sort((a, b) => a.position - b.position)
      return acc
    }, {})
  }, [candidates])



  if (loading) {
    return null
  }

  if (error) return <p>Error : {error.message}</p>

  return (
    <>
      <Box backgroundColor="neutral-70" p={20} alignItems="center">
        <Text variant="h5" color="white" m={0}>
          {job?.name}
        </Text>
      </Box>

      <Box p={20}>
        <Flex gap={10}>
          {statuses?.map(status => (
            <Box
              w={300}
              border={1}
              backgroundColor="white"
              borderColor="neutral-30"
              borderRadius="md"
              overflow="hidden"
            >
              <Flex
                p={10}
                borderBottom={1}
                borderColor="neutral-30"
                alignItems="center"
                justify="space-between"
              >
                <Text color="black" m={0} textTransform="capitalize">
                  {status.label}
                </Text>
                <Badge>{(sortedCandidates[status.id] || []).length}</Badge>
              </Flex>
              <Flex direction="column" p={10} pb={0}>
                {sortedCandidates[status.id]?.map((candidate: Candidate) => (
                  <CandidateCard candidate={candidate} />
                ))}
              </Flex>
            </Box>
          ))}
        </Flex>
      </Box>
    </>
  )
}

export default JobShow
