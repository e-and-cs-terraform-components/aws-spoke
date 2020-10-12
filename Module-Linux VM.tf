## Variables
variable "Create_Demo_VMs" {
  type        = bool
  default     = false
  description = "Should this spoke contain a demo VM in each subnet? Defaults to false"
}
variable "Key_Name" {
  default     = null
  description = "The name of the SSH Key to be provided from the AWS APIs. Left blank creates the virtual machine with no SSH key authentication."
}

## Modules
module "Demo_VM_AZ1" {
  count = var.Create_Demo_VMs ? 1 : 0

  source          = "./Linux Machine"
  Project_Prefix  = aws_subnet.az1.tags.Name
  Hostname_Suffix = "-demovm"
  # Access and Licenses
  Key_Name = var.Key_Name != "" ? var.Key_Name : null
  # Network location and addressing
  Subnet_ID = aws_subnet.az1.id
}

module "Demo_VM_AZ2" {
  count = var.Create_Demo_VMs ? 1 : 0

  source          = "./Linux Machine"
  Project_Prefix  = aws_subnet.az2.tags.Name
  Hostname_Suffix = "-demovm"
  # Access and Licenses
  Key_Name = var.Key_Name != "" ? var.Key_Name : null
  # Network location and addressing
  Subnet_ID = aws_subnet.az2.id
}

## Outputs
output "Demo_VM_IPs" {
  value = "%{for m in module.Demo_VM_AZ1}${m.name} = ${m.ip}, %{endfor}%{for m in module.Demo_VM_AZ2}${m.name} = ${m.ip}%{endfor}"
}