import { gql } from '@apollo/client'

export const GET_BOARD = gql`
  query GetBoard($jobId: ID!) {
    job(jobId: $jobId) {
      id
      name
    }
    candidates(jobId: $jobId) {
      email
      id
      jobId
      statusId
      displayOrder
    }
    statuses(jobId: $jobId) {
      id
      jobId
      position
      label
    }
  }
`
