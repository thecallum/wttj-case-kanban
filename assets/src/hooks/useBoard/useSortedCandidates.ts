import { useMemo } from 'react'
import { Candidate, Column } from '../../types'
import { SortedCandidates } from './types'

export const useSortedCandidates = (candidates: Candidate[], columns: Column[]) => {
  return useMemo(() => {
    if (!candidates) return {}

    const columnsById: { [key: number]: Column } = {}
    columns?.forEach(column => {
      columnsById[column.id] = column
    })

    return candidates.reduce<SortedCandidates>((acc, c: Candidate) => {
      acc[c.columnId] = [...(acc[c.columnId] || []), c].sort((left, right) => {
        return parseFloat(left.displayOrder!) - parseFloat(right.displayOrder!)
      })
      return acc
    }, {})
  }, [candidates])
}
