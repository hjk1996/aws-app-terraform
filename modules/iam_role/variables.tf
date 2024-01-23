variable "lambda_trust_policy" {
  type = string
}

variable "eks_trust_policy" {
  type = string
}

variable "nsfw_detect_lambda_policy_arns" {
  type = list(string)
}