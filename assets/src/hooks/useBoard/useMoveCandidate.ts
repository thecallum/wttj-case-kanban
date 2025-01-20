import { ApolloError, useMutation } from '@apollo/client'
import { MoveCandidateMutation } from './types'
import { MOVE_CANDIDATE } from '../../graphql/mutations/moveCandidate'
import { useState } from 'react'
import { Candidate, Status } from '../../types'

export const useMoveCandidate = (
  clientId: string,
  updateCandidatePosition: (id: number, displayOrder: string, statusId: number) => void,
  updateStatusVersion: (statusId: number, newVersion: number) => void
) => {
  const handleOnUpdateSuccess = (data: MoveCandidateMutation) => {
    // reset error
    setUpdateError(null)

    const { id, displayOrder, statusId } = data.moveCandidate.candidate
    updateCandidatePosition(id, displayOrder, statusId)

    const {sourceStatus, destinationStatus } = data.moveCandidate
    
    updateStatusVersion(sourceStatus.id, sourceStatus.lockVersion)
    updateStatusVersion(destinationStatus.id, destinationStatus.lockVersion)
  }

  const handleOnUpdateError = (error: ApolloError) => {
    console.error('New error occurred when updating candidate', { error })

    setUpdateError(error.message)

    // revert candidate back to previous position
    const { id, displayOrder, statusId } = candidateSnapshot!
    updateCandidatePosition(id, displayOrder, statusId)
  }

  const [updateCandiate] = useMutation<MoveCandidateMutation>(MOVE_CANDIDATE, {
    onCompleted: handleOnUpdateSuccess,
    onError: handleOnUpdateError,
  })

  const handleUpdateCandidate = (
    candidate: Candidate,
    beforeIndex: string | null,
    afterIndex: string | null,
    destinationStatusId: number,
    sourceStatus: Status,
    destinationStatus: Status | null
  ) => {
    // store snapshot of current state, so candidate can be reverted
    // if update fails
    setCandidateSnapshot(candidate)

    const variables = {
      candidateId: candidate.id,
      destinationStatusId,
      beforeIndex,
      afterIndex,
      clientId: clientId,
      sourceStatusVersion: sourceStatus.lockVersion,
      destinationStatusVersion: destinationStatus?.lockVersion ?? null,
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
