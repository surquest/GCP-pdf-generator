variable "services" {

  type = object({

    IAM = object({
      serviceAccounts = map(
        object({
          name  = string
          desc  = string
          roles = list(string)
        })
      )
    })

    run = object({
      services = map(object({
        container = object({
          image = string
          ports = object({
            containerPort = string 
          })
        })
        serviceAccount = string
      })) 
    })

    storage = object({
      buckets = map(
        object({
          desc      = string
          lifecycle = object({
            action = object({
              type = string
              storageClass = optional(string)
            })
            condition = object({
              age        = number
            })
          })
          access = list(
            object({
              role  = string
              type  = string
              key = optional(string)
              email = optional(string)
            })
          )
        })
      )
    })

  })
}