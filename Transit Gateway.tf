## Variables
# Routing Helpers
variable "Transit_Gateway" {
  type        = object({ id = string, tags = map(string) })
  description = "The Transit Gateway resource which this hub will be connected to."
}

variable "Transit_Gateway_Spoke_to_Hub_Routing_Table_ID" {
  type        = string
  description = "The ID of the Transit Gateway Routing Table to attach to this spoke's attachment."
  validation {
    condition     = can(regex("^tgw-rtb-[0-9a-f]+", var.Transit_Gateway_Spoke_to_Hub_Routing_Table_ID))
    error_message = "Transit Gateway Routing Tables must match the specific naming convention."
  }
}

variable "Transit_Gateway_Hub_to_Spoke_Routing_Table_ID" {
  type        = string
  description = "The ID of the Transit Gateway Routing Table which is attached to the hub's attachment."
  validation {
    condition     = can(regex("^tgw-rtb-[0-9a-f]+", var.Transit_Gateway_Hub_to_Spoke_Routing_Table_ID))
    error_message = "Transit Gateway Routing Tables must match the specific naming convention."
  }
}

variable "Transit_Gateway_Hub_To_Gateway_Attachment_ID" {
  type        = string
  description = "The ID of the attachment from the Hub VPC to the Transit Gateway."
  validation {
    condition     = can(regex("^tgw-attach-[0-9a-f]+", var.Transit_Gateway_Hub_To_Gateway_Attachment_ID))
    error_message = "Transit Gateway Routing Tables must match the specific naming convention."
  }
}

variable "Hub_Inspect_Routing_Table_ID" {
  type        = string
  description = "The ID of the Routing Table to update with this spoke's CIDR."
  validation {
    condition     = can(regex("^rtb-[0-9a-f]+", var.Hub_Inspect_Routing_Table_ID))
    error_message = "Transit Gateway Routing Tables must match the specific naming convention."
  }
}

## Resources
# Routing, Route Propogation and Routing Table Associations
resource "aws_route" "to_transit_gateway" {
  route_table_id         = aws_route_table.spoke.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.Transit_Gateway.id
}

resource "aws_route" "inspect_spokes" {
  route_table_id         = var.Hub_Inspect_Routing_Table_ID
  destination_cidr_block = aws_vpc.vpc.cidr_block
  transit_gateway_id     = var.Transit_Gateway.id
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke_to_hub" {
  transit_gateway_route_table_id = var.Transit_Gateway_Spoke_to_Hub_Routing_Table_ID
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "hub_to_spoke" {
  transit_gateway_route_table_id = var.Transit_Gateway_Hub_to_Spoke_Routing_Table_ID
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
}

# Transit Gateway Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  subnet_ids         = [aws_subnet.az1.id, aws_subnet.az2.id]
  transit_gateway_id = var.Transit_Gateway.id
  vpc_id             = aws_vpc.vpc.id

  tags = {
    Name = "${var.Transit_Gateway.tags.Name}-attach-${aws_vpc.vpc.tags.Name}"
  }
}

## Outputs
output "aws_ec2_transit_gateway_vpc_attachment_spoke" {
  value = aws_ec2_transit_gateway_vpc_attachment.spoke
}
output "aws_ec2_transit_gateway_vpc_attachment_spoke_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.spoke.id
}