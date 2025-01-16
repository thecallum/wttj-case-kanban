export type Job = {
  id: string
  name: string
}

export type Status = {
  id: number
  label: number
  position: number
}

export type Candidate = {
  id: number
  email: string
  statusId: number
  displayOrder: string
}
