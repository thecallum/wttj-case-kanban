import { ApolloError, useMutation } from '@apollo/client'
import { MoveCandidateMutation } from './types'
import { MOVE_CANDIDATE } from '../../graphql/mutations/moveCandidate'
import { useState } from 'react'
import { Candidate, Column } from '../../types'

export const useMoveCandidate = (
  clientId: string,
  updateCandidatePosition: (id: number, displayOrder: string, columnId: number) => void,
  updateColumnVersion: (columnId: number, newVersion: number) => void
) => {
  const handleOnUpdateSuccess = (data: MoveCandidateMutation) => {
    // reset error
    setUpdateError(null)

    const { id, displayOrder, columnId } = data.moveCandidate.candidate
    updateCandidatePosition(id, displayOrder, columnId)

    const {sourceColumn, destinationColumn } = data.moveCandidate
    
    updateColumnVersion(sourceColumn.id, sourceColumn.lockVersion)
    updateColumnVersion(destinationColumn.id, destinationColumn.lockVersion)
  }

  const handleOnUpdateError = (error: ApolloError) => {
    console.error('New error occurred when updating candidate', { error })

    setUpdateError(error.message)

    // revert candidate back to previous position
    const { id, displayOrder, columnId } = candidateSnapshot!
    updateCandidatePosition(id, displayOrder, columnId)
  }

  const [updateCandiate] = useMutation<MoveCandidateMutation>(MOVE_CANDIDATE, {
    onCompleted: handleOnUpdateSuccess,
    onError: handleOnUpdateError,
  })

  const handleUpdateCandidate = (
    candidate: Candidate,
    previousCandidateDisplayOrder: string | null,
    nextCandidateDisplayOrder: string | null,
    destinationColumnId: number,
    sourceColumn: Column,
    destinationColumn: Column | null
  ) => {
    // store snapshot of current state, so candidate can be reverted
    // if update fails
    setCandidateSnapshot(candidate)

    const variables = {
      candidateId: candidate.id,
      destinationColumnId,
      previousCandidateDisplayOrder,
      nextCandidateDisplayOrder,
      clientId: clientId,
      sourceColumnVersion: sourceColumn.lockVersion,
      destinationColumnVersion: destinationColumn?.lockVersion ?? null,
    }


    updateCandiate({
      variables,
    })
  }

  // Used to revert candidate when an error occurs
  const [candidateSnapshot, setCandidateSnapshot] = useState<Candidate | null>(null)
  const [updateError, setUpdateError] = useState<string | null>(null)

  return {
    handleUpdateCandidate,
    updateError,
  }
}
