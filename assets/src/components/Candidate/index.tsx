import { Card } from '@welcome-ui/card'
import { Candidate } from '../../types'

function CandidateCard({ candidate }: { candidate: Candidate }) {
  return (
    <Card mb={10}>
      <Card.Body style={{whiteSpace: "nowrap"}}>{candidate.email} [{candidate.displayOrder}]</Card.Body>
    </Card>
  )
}

export default CandidateCard
