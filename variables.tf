# variables without Default values
################################################
variable "key_name" {
  description = "Your AWS Auth Key name"
  type        = string
 #default     = "xyz_key"
  /* Use your own key name */
}

variable "zone_id" {
  description = "AWS Route 53 Zone id from your DNS provider"
  type        = string
 #default     = "12345678912345678"
  /* Use your own zone id from your DNS service provider*/
}

variable "dns_name" {
  description = "DNS Name Example:proxy01.yourdomain.xyz"
  type        = string
 #default     = "proxy01.yourdomain.org"
  /* Use your own registered DNS name to link with public IP*/

}
#######################################################


# Variables with default values

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "availability_zone_public" {
  type    = string
  default = "us-east-2b"
}

variable "availability_zone_private" {
  type    = string
  default = "us-east-2a"
}


variable "image_id" {
  description = "The id of the machine image (AMI) to use for the server."
  type        = string
  default     = "ami-063760b9d8c69067a"
}


variable "instance_type" {
  description = "instance type"
  type        = string
  default     = "t2.micro"
}
