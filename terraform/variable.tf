variable "instance_config" {
  type = object({
    image_id      = string
    instance_type = string
    key_address   = string
    Ports         = list(number)
  })
}
  

# variable "Ports" {
#   type = list(number)
# }

# variable "image_id" {
#   type = string
# }

# variable "instance_type" {
#   type = string
# }

# variable "key_address" {
#   type = string
# }