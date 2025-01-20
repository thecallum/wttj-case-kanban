import { useParams } from 'react-router-dom'
import { Text } from '@welcome-ui/text'
import { Flex } from '@welcome-ui/flex'
import { Box } from '@welcome-ui/box'
import { Candidate, Status } from '../../types'
import CandidateCard from '../../components/Candidate'
import { Badge } from '@welcome-ui/badge'
import { useBoard } from '../../hooks/useBoard'
import { DragDropContext, Draggable, Droppable } from '@hello-pangea/dnd'

function JobShow() {
  const { jobId } = useParams<{ jobId: string }>()
  const { loading, error, job, sortedCandidates, statuses, handleOnDragEnd, updateError } =
    useBoard(jobId!)

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

      <DragDropContext onDragEnd={handleOnDragEnd}>
        <Box p={20}>
          <Flex gap={10}>
            {Array.from(statuses)
              .sort((a, b) => a.position - b.position)
              .map((status: Status) => (
                <Box
                  w={300}
                  border={1}
                  backgroundColor="white"
                  borderColor="neutral-30"
                  borderRadius="md"
                  overflow="hidden"
                  key={status.id}
                >
                  <Flex
                    p={10}
                    borderBottom={1}
                    borderColor="neutral-30"
                    alignItems="center"
                    justify="space-between"
                  >
                    <Text color="black" m={0} textTransform="capitalize">
                      {status.label} - Version {status.lockVersion}
                    </Text>
                    <Badge>{(sortedCandidates[status.id] || []).length}</Badge>
                  </Flex>

                  <Droppable droppableId={`${status.id}`}>
                    {provided => (
                      <div {...provided.droppableProps} ref={provided.innerRef}>
                        <Flex direction="column" p={10} pb={0}>
                          {sortedCandidates[status.id]?.map(
                            (candidate: Candidate, index: number) => (
                              <Draggable
                                key={candidate.id}
                                draggableId={`${candidate.id}`}
                                index={index}
                              >
                                {provided => (
                                  <div
                                    ref={provided.innerRef}
                                    {...provided.draggableProps}
                                    {...provided.dragHandleProps}
                                    style={provided.draggableProps.style}
                                  >
                                    <CandidateCard candidate={candidate} />
                                  </div>
                                )}
                              </Draggable>
                            )
                          )}
                        </Flex>
                        {provided.placeholder}
                      </div>
                    )}
                  </Droppable>
                </Box>
              ))}
          </Flex>
        </Box>
      </DragDropContext>

      {updateError && (
        <div
          style={{
            background: '#fecaca',
            display: 'inline-block',
            marginLeft: 20,
            padding: '5px 10px',
            borderRadius: 5,
            color: '#dc2626',
          }}
        >
          An error occurred updating candidate: "{updateError}"
        </div>
      )}
    </>
  )
}

export default JobShow
