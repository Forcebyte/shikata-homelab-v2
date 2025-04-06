variable "k8s_api_server" {
  description = "The URL to the Kubernetes API server"
  type        = string
}

variable "k8s_api_token" {
  description = "The Kubernetes API token for authentication"
  type        = string
  sensitive   = true
}

variable "ca_certificate" {
  description = "The CA certificate for the Kubernetes cluster (base64-encoded)"
  type        = string
  sensitive   = true
}


variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "github_ssh_key" {
  description = "Github PAT (https://github.com/settings/tokens)"
  type        = string
  sensitive   = true
}


variable "known_hosts_ssh" {
  description = "Known hosts for github.com"
  type = string
  default = "Z2l0aHViLmNvbSBzc2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFEQVFBQkFBQUJnUUNqN25kTnhRb3dnY1FuanNoY0xycVBFaWlwaG50K1ZUVHZEUDZtSEJMOWoxYU5Va1k0VWUxZ3Z3bkdMVmxPaEdlWXJuWmFNZ1JLNitQS0NVWGFEYkM3cXRiVzhnSWtoTDdhR0NzT3IvQzU2U0pNeS9CQ1pmeGQxbld6QU94U0RQZ1ZzbWVyT0JZZk5xbHRWOS9oV0NxQnl3SU5JUis1ZElnNkpUSjcycGNFcEVqY1lnWGtFMllFRlhWMUpIbnNLZ2JMV05saFNjcWIyVW15UmtReXl0Ukx0TCszOFRHeGt4Q2ZsbU8rNVo4Q1NTTlk3R2lkak1JWjdRNHpNakEybjFuR3JsVERrendEQ3N3K3dxRlBHUUExNzljbmZHV09XUlZydWoxNno2WHl2eHZqSndiejB3UVo3NVhLNXRLU2I3Rk55ZUlFczRUVDRqaytTNGRoUGVBVUM1eStiRFlpcllnTTRHQzd1RW56dG5aeWFWV1E3QjM4MUFLNFFkcnd0NTFacUV4S2JRcFRVTm4rRWpxb1R3dnFOajRrcXg1UVVDSTBUaFMvWWtPeEpDWG1QVVdaYmhqcENnNTZpKzJhQjZDbUsySkdobjU3SzVtajBNTmRCWEE0L1dud0g2WG9QV0p6SzVOeXUyekIzbkFacCtTNWhwUXMrcDF2TjEvd3Nqaz0KZ2l0aHViLmNvbSBlY2RzYS1zaGEyLW5pc3RwMjU2IEFBQUFFMlZqWkhOaExYTm9ZVEl0Ym1semRIQXlOVFlBQUFBSWJtbHpkSEF5TlRZQUFBQkJCRW1LU0VOalFFZXpPbXhrWk15N29wS2d3RkI5bmt0NVlScllNak51RzVOODd1UmdnNkNMcmJvNXdB"
}


