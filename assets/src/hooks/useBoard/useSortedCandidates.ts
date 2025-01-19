import { useMemo } from 'react'
import { Candidate, Status } from '../../types'
import { SortedCandidates } from './types'

export const useSortedCandidates = (candidates: Candidate[], statuses: Status[]) => {
  return useMemo(() => {
    if (!candidates) return {}

    const statusesById: { [key: number]: Status } = {}
    statuses?.forEach(status => {
      statusesById[status.id] = status
    })

    return candidates.reduce<SortedCandidates>((acc, c: Candidate) => {
      acc[c.statusId] = [...(acc[c.statusId] || []), c].sort((left, right) => {
        return parseFloat(left.displayOrder!) - parseFloat(right.displayOrder!)
      })
      return acc
    }, {})
  }, [candidates])
}
