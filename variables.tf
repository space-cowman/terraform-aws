variable "cidr" {
  default = "10.0.0.0/16"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name (pass with -var)"
  type        = string
  default     = "change-me-unique-bucket-name"
}
