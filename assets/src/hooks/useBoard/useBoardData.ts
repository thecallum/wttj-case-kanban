import { Candidate, Job, Column } from '../../types'
import { GET_BOARD } from '../../graphql/queries/getBoard'
import { useQuery } from '@apollo/client'
import { useSortedCandidates } from './useSortedCandidates'
import { useState } from 'react'

export const useBoardData = (jobId: string) => {
  const { loading, error } = useQuery<{
    job: Job
    candidates: Candidate[]
    columns: Column[]
  }>(GET_BOARD, {
    variables: { jobId },
    onCompleted(data) {
      setJob(() => data?.job ?? null)
      setCandidates(() => data?.candidates || [])
      setColumns(() => data?.columns || [])
    },
  })

  const [job, setJob] = useState<Job | null>(null)
  const [candidates, setCandidates] = useState<Candidate[]>([])
  const [columns, setColumns] = useState<Column[]>([])

  const updateCandidatePosition = (candidateId: number, displayOrder: string, columnId: number) => {
    setCandidates(data => {
      return data.map(x => {
        if (x.id != candidateId) return x

        return {
          ...x,
          displayOrder,
          columnId,
        }
      })
    })
  }

  const updateColumnVersion = (columnId: number, newVersion: number) => {
    setColumns(data => {
      return data.map(x => {
        if (x.id !== columnId) return x

        return {
          ...x,
          lockVersion: newVersion,
        }
      })
    })
  }

  const sortedCandidates = useSortedCandidates(candidates, columns)

  const columnsById = columns.reduce<{ [key: number]: Column }>((acc, column: Column) => {
    acc[column.id] = column

    return acc
  }, {})

  return {
    loading,
    error,
    sortedCandidates,
    columns,
    columnsById,
    job,
    updateCandidatePosition,
    updateColumnVersion,
  }
}
