export type Job = {
  id: string
  name: string
}

export type Column = {
  id: number
  label: number
  position: number
  lockVersion: number
}

export type Candidate = {
  id: number
  email: string
  columnId: number
  displayOrder: string
}
