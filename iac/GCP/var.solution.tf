# Declare variables

variable "solution" {
  type = object({
    name = string
    desc = string
    slug = string
    version = optional(string)
  })
}
