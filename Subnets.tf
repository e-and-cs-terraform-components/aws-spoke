## Data
# Local processing
data "null_data_source" "subnets" {
  inputs = {
    Subnet_CIDR_AZ1 = var.Subnet_CIDR_AZ1 != null && var.Subnet_CIDR_AZ1 != "" ? var.Subnet_CIDR_AZ1 : cidrsubnet(var.VPC_CIDR, 1, 0)
    Subnet_CIDR_AZ2 = var.Subnet_CIDR_AZ2 != null && var.Subnet_CIDR_AZ2 != "" ? var.Subnet_CIDR_AZ2 : cidrsubnet(var.VPC_CIDR, 1, 1)
  }
}

## Variables
# Naming
variable "Subnet_Suffix" {
  type        = string
  default     = "subnet"
  description = "The string to add to the name of the Subnets after the project prefix and a hyphen, but before the AZ (e.g. 'demo-subnet_aza')"
}
# IP Addressing
variable "Subnet_CIDR_AZ1" {
  type        = string
  default     = ""
  description = "The CIDR for the AZ1 subnet in the VPC. Leave blank to automatically subdivide into 1/2th of the VPC CIDR"
  validation {
    condition     = var.Subnet_CIDR_AZ1 == null || var.Subnet_CIDR_AZ1 == "" || can(regex("^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9][0-9]|[0-9])\\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9][0-9]|[0-9])\\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9][0-9]|[0-9])\\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9][0-9]|[0-9])\\/(1[7-9]|2[0-8]))$", var.Subnet_CIDR_AZ1))
    error_message = "Must be a valid IPv4 CIDR with a CIDR Mask between 17 and 28 bits (/17-/28)."
  }
}
variable "Subnet_CIDR_AZ2" {
  type        = string
  default     = ""
  description = "The CIDR for the AZ2 subnet in the VPC. Leave blank to automatically subdivide into 1/2th of the VPC CIDR"
  validation {
    condition     = var.Subnet_CIDR_AZ2 == null || var.Subnet_CIDR_AZ2 == "" || can(regex("^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9][0-9]|[0-9])\\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9][0-9]|[0-9])\\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9][0-9]|[0-9])\\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9][0-9]|[0-9])\\/(1[7-9]|2[0-8]))$", var.Subnet_CIDR_AZ2))
    error_message = "Must be a valid IPv4 CIDR with a CIDR Mask between 17 and 28 bits (/17-/28)."
  }
}

## Resources
#  Subnets
resource "aws_subnet" "az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = data.null_data_source.subnets.outputs["Subnet_CIDR_AZ1"]
  availability_zone = "${data.aws_region.current.name}${var.AZ1}"

  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-${var.Subnet_Suffix}-az${var.AZ1}"
  }
}
resource "aws_subnet" "az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = data.null_data_source.subnets.outputs["Subnet_CIDR_AZ2"]
  availability_zone = "${data.aws_region.current.name}${var.AZ2}"

  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-${var.Subnet_Suffix}-az${var.AZ2}"
  }
}

#  Route Tables
resource "aws_route_table" "spoke" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-${var.Subnet_Suffix}-rt"
  }
}

# Routing Table Associations
resource "aws_route_table_association" "az1" {
  subnet_id      = aws_subnet.az1.id
  route_table_id = aws_route_table.spoke.id
}

resource "aws_route_table_association" "az2" {
  subnet_id      = aws_subnet.az2.id
  route_table_id = aws_route_table.spoke.id
}

## Outputs
output "aws_subnet_az1" {
  value = aws_subnet.az1
}
output "aws_subnet_az1_id" {
  value = aws_subnet.az1.id
}
output "aws_subnet_az2" {
  value = aws_subnet.az2
}
output "aws_subnet_az2_id" {
  value = aws_subnet.az2.id
}
output "aws_route_table_spoke" {
  value = aws_route_table.spoke
}
output "aws_route_table_spoke_id" {
  value = aws_route_table.spoke.id
}